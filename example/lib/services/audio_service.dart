import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';
import '../models/app_state.dart';
import 'validation_service.dart';

/// Service class for audio processing operations
class AudioService {
  /// Gets platform version
  static Future<String> getPlatformVersion(AppState appState) async {
    try {
      return await appState.audioToolkit.getPlatformVersion() ?? 'Unknown platform version';
    } catch (e) {
      return 'Failed to get platform version.';
    }
  }

  /// Gets audio file information
  static Future<void> getAudioInfo(AppState appState) async {
    if (appState.selectedFilePath == null) return;

    try {
      final info = await appState.audioToolkit.getAudioInfo(appState.selectedFilePath!);
      appState.audioInfo = info;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get audio info: $e');
      }
    }
  }

  /// Converts audio to specified format
  static Future<void> convertAudio(AppState appState, AudioFormat format) async {
    // Perform comprehensive validations
    if (!await ValidationService.validateSelectedFile(appState)) return;
    if (!await ValidationService.validateFormatSupport(appState)) return;
    if (!await ValidationService.validateStoragePermissions()) return;

    appState.isConverting = true;
    appState.conversionProgress = 0.0;

    try {
      // Save to Downloads folder where user can access files
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final fileName = 'converted_audio_${DateTime.now().millisecondsSinceEpoch}.${format.name}';
      final outputPath = '${directory.path}/$fileName';

      if (kDebugMode) {
        print('Converting audio to: $outputPath');
      }

      final result = await appState.audioToolkit.convertAudio(
        inputPath: appState.selectedFilePath!,
        outputPath: outputPath,
        format: format,
        onProgress: (progress) {
          appState.conversionProgress = progress;
        },
      );

      appState.convertedFilePath = result.outputPath;
      appState.isConverting = false;

      if (kDebugMode) {
        print('Audio converted successfully! File saved to: ${result.outputPath}');
      }
    } catch (e) {
      appState.isConverting = false;
      if (kDebugMode) {
        print('Conversion failed: $e');
      }
      rethrow;
    }
  }

  /// Extracts real waveform from selected audio file
  static Future<void> extractWaveform(AppState appState) async {
    if (!await ValidationService.validateSelectedFile(appState)) return;
    if (!await ValidationService.validateStoragePermissions()) return;

    appState.isExtracting = true;
    appState.waveformProgress = 0.0;
    appState.isFakeWaveformMode = false;

    try {
      if (kDebugMode) {
        print('Extracting waveform from: ${appState.selectedFilePath}');
      }
      final waveformData = await appState.audioToolkit.extractWaveform(
        inputPath: appState.selectedFilePath!,
        samplesPerSecond: 100,
        onProgress: (progress) {
          appState.waveformProgress = progress;
        },
      );

      appState.waveformData = waveformData;
      appState.isExtracting = false;

      if (kDebugMode) {
        print('Waveform extracted successfully!');
      }
    } catch (e) {
      appState.isExtracting = false;
      if (kDebugMode) {
        print('Waveform extraction failed: $e');
      }
      rethrow;
    }
  }

  /// Generates fake waveform for selected audio file
  static Future<void> generateFakeWaveform(AppState appState) async {
    if (!await ValidationService.validateSelectedFile(appState)) return;

    appState.isExtracting = true;
    appState.waveformProgress = 0.0;
    appState.isFakeWaveformMode = true;

    try {
      // Simulate progress for user feedback
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 50));
        appState.waveformProgress = i / 100.0;
      }

      // Use audio info duration if available, otherwise estimate
      int estimatedDurationMs = 180000; // 3 minutes default
      if (appState.audioInfo != null && appState.audioInfo!['durationMs'] != null) {
        estimatedDurationMs = appState.audioInfo!['durationMs'];
      }

      final fakeWaveform = appState.audioToolkit.generateFakeWaveform(
        pattern: appState.selectedWaveformPattern,
        durationMs: estimatedDurationMs,
        samplesPerSecond: 100,
      );

      appState.waveformData = fakeWaveform;
      appState.isExtracting = false;
      appState.waveformProgress = 1.0;

      if (kDebugMode) {
        print('Fake waveform generated (${appState.selectedWaveformPattern.name.toUpperCase()} pattern)!');
      }
    } catch (e) {
      appState.isExtracting = false;
      appState.isFakeWaveformMode = false;
      if (kDebugMode) {
        print('Failed to generate fake waveform: $e');
      }
      rethrow;
    }
  }

  /// Trims audio file
  static Future<void> trimAudio(AppState appState) async {
    // Perform comprehensive validations
    if (!await ValidationService.validateSelectedFile(appState)) return;
    if (!await ValidationService.validateFormatSupport(appState)) return;
    if (!ValidationService.validateAudioInfoLoaded(appState)) return;
    if (!ValidationService.validateTrimRange(appState)) return;
    if (!ValidationService.validateTrimFormat(appState)) return;
    if (!await ValidationService.validateStoragePermissions()) return;

    appState.isTrimming = true;
    appState.trimProgress = 0.0;

    try {
      // Save to Downloads folder where user can access files
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Determine file extension based on selected format
      String fileExtension;
      switch (appState.selectedTrimFormat) {
        case AudioFormat.aac:
          fileExtension = 'aac';
          break;
        case AudioFormat.m4a:
          fileExtension = 'm4a';
          break;
        case AudioFormat.copy:
          // Keep original extension for lossless copy
          final originalFile = File(appState.selectedFilePath!);
          fileExtension = originalFile.path.split('.').last;
          break;
      }

      final fileName = 'trimmed_audio_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final outputPath = '${directory.path}/$fileName';

      if (kDebugMode) {
        print('Trimming audio to: $outputPath (format: ${appState.selectedTrimFormat.name})');
      }

      final result = await appState.audioToolkit.trimAudio(
        inputPath: appState.selectedFilePath!,
        outputPath: outputPath,
        startTimeMs: appState.trimStartMs,
        endTimeMs: appState.trimEndMs,
        format: appState.selectedTrimFormat,
        onProgress: (progress) {
          appState.trimProgress = progress;
        },
      );

      appState.trimmedFilePath = result.outputPath;
      appState.isTrimming = false;

      if (kDebugMode) {
        print(
          'Audio trimmed successfully (${appState.selectedTrimFormat.name.toUpperCase()})! File saved to: ${result.outputPath}',
        );
      }
    } catch (e) {
      appState.isTrimming = false;
      if (kDebugMode) {
        print('Trimming failed: $e');
      }
      rethrow;
    }
  }

  /// Processes URL file for real waveform extraction
  static Future<void> processUrlFile(AppState appState) async {
    final url = appState.urlController.text.trim();
    if (url.isEmpty) {
      throw Exception('Please enter a valid URL');
    }

    appState.isDownloading = true;
    appState.downloadProgress = 0.0;
    appState.isFakeWaveformMode = false;

    try {
      final tempDir = Directory.systemTemp;
      final fileName = url.split('/').last.split('?').first;
      final localPath = '${tempDir.path}/downloaded_$fileName';

      final waveformData = await appState.audioToolkit.extractWaveformFromUrl(
        url: url,
        localPath: localPath,
        samplesPerSecond: 100,
        onDownloadProgress: (progress) {
          appState.downloadProgress = progress;
        },
        onExtractionProgress: (progress) {
          appState.waveformProgress = progress;
        },
      );

      appState.waveformData = waveformData;
      appState.isDownloading = false;
      appState.isExtracting = false;
      appState.downloadProgress = 1.0;
      appState.waveformProgress = 1.0;

      if (kDebugMode) {
        print('Waveform extracted from network file!');
      }
    } catch (e) {
      appState.isDownloading = false;
      appState.isExtracting = false;
      if (kDebugMode) {
        print('Failed to process network file: $e');
      }
      rethrow;
    }
  }

  /// Generates fake waveform from URL
  static Future<void> generateFakeWaveformFromUrl(AppState appState) async {
    final url = appState.urlController.text.trim();
    if (url.isEmpty) {
      throw Exception('Please enter a valid URL');
    }

    appState.isExtracting = true;
    appState.waveformProgress = 0.0;
    appState.isFakeWaveformMode = true;

    try {
      // Simulate progress for user feedback
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 50));
        appState.waveformProgress = i / 100.0;
      }

      final fakeWaveform = appState.audioToolkit.generateFakeWaveformForUrl(
        url: url,
        pattern: appState.selectedWaveformPattern,
        estimatedDurationMs: 180000, // 3 minutes
        samplesPerSecond: 100,
      );

      appState.waveformData = fakeWaveform;
      appState.isExtracting = false;
      appState.waveformProgress = 1.0;

      if (kDebugMode) {
        print('Fake waveform generated for URL (${appState.selectedWaveformPattern.name.toUpperCase()} pattern)!');
      }
    } catch (e) {
      appState.isExtracting = false;
      appState.isFakeWaveformMode = false;
      if (kDebugMode) {
        print('Failed to generate fake waveform from URL: $e');
      }
      rethrow;
    }
  }
}
