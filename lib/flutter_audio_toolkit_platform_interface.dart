import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_audio_toolkit_method_channel.dart';
import 'flutter_audio_toolkit.dart';

abstract class FlutterAudioToolkitPlatform extends PlatformInterface {
  /// Constructs a FlutterAudioToolkitPlatform.
  FlutterAudioToolkitPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterAudioToolkitPlatform _instance =
      MethodChannelFlutterAudioToolkit();

  /// The default instance of [FlutterAudioToolkitPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterAudioToolkit].
  static FlutterAudioToolkitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterAudioToolkitPlatform] when
  /// they register themselves.
  static set instance(FlutterAudioToolkitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Converts an audio file to the specified format
  Future<ConversionResult> convertAudio({
    required String inputPath,
    required String outputPath,
    required AudioFormat format,
    int bitRate = 128,
    int sampleRate = 44100,
    ProgressCallback? onProgress,
  }) {
    throw UnimplementedError('convertAudio() has not been implemented.');
  }

  /// Extracts waveform data from an audio file
  Future<WaveformData> extractWaveform({
    required String inputPath,
    int samplesPerSecond = 100,
    ProgressCallback? onProgress,
  }) {
    throw UnimplementedError('extractWaveform() has not been implemented.');
  }

  /// Checks if the given audio format is supported for conversion
  Future<bool> isFormatSupported(String inputPath) {
    throw UnimplementedError('isFormatSupported() has not been implemented.');
  }

  /// Gets audio file information without conversion
  Future<Map<String, dynamic>> getAudioInfo(String inputPath) {
    throw UnimplementedError('getAudioInfo() has not been implemented.');
  }

  /// Trims an audio file to the specified time range
  Future<ConversionResult> trimAudio({
    required String inputPath,
    required String outputPath,
    required int startTimeMs,
    required int endTimeMs,
    required AudioFormat format,
    int bitRate = 128,
    int sampleRate = 44100,
    ProgressCallback? onProgress,
  }) {
    throw UnimplementedError('trimAudio() has not been implemented.');
  }
}
