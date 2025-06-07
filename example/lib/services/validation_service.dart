import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/app_state.dart';

/// Service class for validation methods
class ValidationService {
  /// Validates if a file is selected and exists
  static Future<bool> validateSelectedFile(AppState appState) async {
    if (appState.selectedFilePath == null) {
      return false;
    }

    // Check if file exists
    final file = File(appState.selectedFilePath!);
    if (!await file.exists()) {
      return false;
    }

    // Check file size (warn if > 50MB)
    final fileSize = await file.length();
    if (fileSize > 50 * 1024 * 1024) {
      if (kDebugMode) {
        print('Warning: Large file (${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB) may take longer to process');
      }
    }

    return true;
  }

  /// Validates if the audio format is supported
  static Future<bool> validateFormatSupport(AppState appState) async {
    if (appState.selectedFilePath == null) return false;

    try {
      final isSupported = await appState.audioToolkit.isFormatSupported(appState.selectedFilePath!);
      return isSupported;
    } catch (e) {
      if (kDebugMode) {
        print('Unable to verify format support: $e');
      }
      return false;
    }
  }

  /// Validates if audio info is loaded and valid
  static bool validateAudioInfoLoaded(AppState appState) {
    if (appState.audioInfo == null) {
      return false;
    }

    if (appState.audioInfo!['isValid'] == false) {
      final error = appState.audioInfo!['error'] ?? 'Unknown error';
      final details = appState.audioInfo!['details'] ?? 'The selected file cannot be processed';
      if (kDebugMode) {
        print('Invalid audio file: $error. $details');
      }
      return false;
    }

    return true;
  }

  /// Validates trim range settings
  static bool validateTrimRange(AppState appState) {
    if (appState.audioInfo == null) return false;

    final durationMs = appState.audioInfo!['durationMs'] as int? ?? 0;

    if (appState.trimStartMs < 0) {
      if (kDebugMode) {
        print('Start time cannot be negative');
      }
      return false;
    }

    if (appState.trimEndMs <= appState.trimStartMs) {
      if (kDebugMode) {
        print('End time must be greater than start time');
      }
      return false;
    }

    if (appState.trimStartMs >= durationMs) {
      if (kDebugMode) {
        print('Start time cannot exceed audio duration');
      }
      return false;
    }

    if (appState.trimEndMs > durationMs) {
      if (kDebugMode) {
        print('End time cannot exceed audio duration');
      }
      return false;
    }

    final trimDurationMs = appState.trimEndMs - appState.trimStartMs;
    if (trimDurationMs < 1000) {
      if (kDebugMode) {
        print('Trim duration must be at least 1 second');
      }
      return false;
    }

    return true;
  }

  /// Validates trim format settings
  static bool validateTrimFormat(AppState appState) {
    // Check if lossless trimming is selected but not supported
    if (appState.selectedTrimFormat == AudioFormat.copy) {
      final supportedForLossless = appState.audioInfo!['supportedForLosslessTrimming'] == true;
      if (!supportedForLossless) {
        final mime = appState.audioInfo!['mime'] ?? 'unknown';
        if (kDebugMode) {
          print(
            'Lossless trimming not supported for this format ($mime). '
            'MP3, WAV, and OGG files require conversion. '
            'Please select AAC or M4A format for trimming.',
          );
        }
        return false;
      }
    }
    return true;
  }

  /// Validates storage permissions (Android specific)
  static Future<bool> validateStoragePermissions() async {
    if (Platform.isAndroid) {
      final hasStoragePermission = await Permission.storage.isGranted;
      final hasManageStoragePermission = await Permission.manageExternalStorage.isGranted;

      if (!hasStoragePermission && !hasManageStoragePermission) {
        if (kDebugMode) {
          print('Storage permission is required for audio processing');
        }
        return false;
      }
    }
    return true;
  }
}
