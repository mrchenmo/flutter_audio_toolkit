import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_audio_toolkit_platform_interface.dart';
import 'flutter_audio_toolkit.dart';

/// An implementation of [FlutterAudioToolkitPlatform] that uses method channels.
class MethodChannelFlutterAudioToolkit extends FlutterAudioToolkitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_audio_toolkit');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<ConversionResult> convertAudio({
    required String inputPath,
    required String outputPath,
    required AudioFormat format,
    int bitRate = 128,
    int sampleRate = 44100,
    ProgressCallback? onProgress,
  }) async {
    final Map<String, dynamic> arguments = {
      'inputPath': inputPath,
      'outputPath': outputPath,
      'format': format.name,
      'bitRate': bitRate,
      'sampleRate': sampleRate,
    };
    if (onProgress != null) {
      // Set up progress listener
      const EventChannel('flutter_audio_toolkit/progress').receiveBroadcastStream().listen((dynamic data) {
        if (data is Map && data['operation'] == 'convert') {
          onProgress(data['progress']?.toDouble() ?? 0.0);
        }
      });
    }
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>('convertAudio', arguments);
    final Map<String, dynamic> conversionResult = Map<String, dynamic>.from(result ?? {});

    return ConversionResult(
      outputPath: conversionResult['outputPath'],
      durationMs: conversionResult['durationMs'],
      bitRate: conversionResult['bitRate'],
      sampleRate: conversionResult['sampleRate'],
    );
  }

  @override
  Future<WaveformData> extractWaveform({
    required String inputPath,
    int samplesPerSecond = 100,
    ProgressCallback? onProgress,
  }) async {
    final Map<String, dynamic> arguments = {'inputPath': inputPath, 'samplesPerSecond': samplesPerSecond};
    if (onProgress != null) {
      // Set up progress listener
      const EventChannel('flutter_audio_toolkit/progress').receiveBroadcastStream().listen((dynamic data) {
        if (data is Map && data['operation'] == 'waveform') {
          onProgress(data['progress']?.toDouble() ?? 0.0);
        }
      });
    }
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>('extractWaveform', arguments);
    final Map<String, dynamic> waveformResult = Map<String, dynamic>.from(result ?? {});

    return WaveformData(
      amplitudes: List<double>.from(waveformResult['amplitudes']),
      sampleRate: waveformResult['sampleRate'],
      durationMs: waveformResult['durationMs'],
      channels: waveformResult['channels'],
    );
  }

  @override
  Future<bool> isFormatSupported(String inputPath) async {
    final bool result = await methodChannel.invokeMethod('isFormatSupported', {'inputPath': inputPath});
    return result;
  }

  @override
  Future<Map<String, dynamic>> getAudioInfo(String inputPath) async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>('getAudioInfo', {'inputPath': inputPath});
    return Map<String, dynamic>.from(result ?? {});
  }

  @override
  Future<ConversionResult> trimAudio({
    required String inputPath,
    required String outputPath,
    required int startTimeMs,
    required int endTimeMs,
    required AudioFormat format,
    int bitRate = 128,
    int sampleRate = 44100,
    ProgressCallback? onProgress,
  }) async {
    final Map<String, dynamic> arguments = {
      'inputPath': inputPath,
      'outputPath': outputPath,
      'startTimeMs': startTimeMs,
      'endTimeMs': endTimeMs,
      'format': format.name,
      'bitRate': bitRate,
      'sampleRate': sampleRate,
    };
    if (onProgress != null) {
      // Set up progress listener
      const EventChannel('flutter_audio_toolkit/progress').receiveBroadcastStream().listen((dynamic data) {
        if (data is Map && data['operation'] == 'trim') {
          onProgress(data['progress']?.toDouble() ?? 0.0);
        }
      });
    }
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>('trimAudio', arguments);
    final Map<String, dynamic> trimResult = Map<String, dynamic>.from(result ?? {});

    return ConversionResult(
      outputPath: trimResult['outputPath'],
      durationMs: trimResult['durationMs'],
      bitRate: trimResult['bitRate'],
      sampleRate: trimResult['sampleRate'],
    );
  }
}
