import 'flutter_audio_toolkit_platform_interface.dart';
import 'dart:math';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Audio formats supported for conversion
enum AudioFormat {
  aac, // Convert to AAC (lossy)
  m4a, // Convert to M4A (lossy)
  copy, // Keep original format (lossless)
}

/// Waveform generation patterns for fake waveform data
enum WaveformPattern {
  sine, // Smooth sine wave pattern
  random, // Random amplitude values
  music, // Music-like pattern with peaks and valleys
  speech, // Speech-like pattern with pauses
  pulse, // Pulse/beat pattern
  fade, // Gradual fade in/out pattern
  burst, // Burst pattern with quiet periods
}

/// Represents the result of an audio conversion operation
class ConversionResult {
  final String outputPath;
  final int durationMs;
  final int bitRate;
  final int sampleRate;

  ConversionResult({
    required this.outputPath,
    required this.durationMs,
    required this.bitRate,
    required this.sampleRate,
  });
}

/// Represents waveform data extracted from an audio file
class WaveformData {
  final List<double> amplitudes;
  final int sampleRate;
  final int durationMs;
  final int channels;

  WaveformData({required this.amplitudes, required this.sampleRate, required this.durationMs, required this.channels});
}

/// Progress callback for conversion operations
typedef ProgressCallback = void Function(double progress);

/// Main class for audio conversion and waveform extraction
class FlutterAudioToolkit {
  /// Gets the platform version
  Future<String?> getPlatformVersion() {
    return FlutterAudioToolkitPlatform.instance.getPlatformVersion();
  }

  /// Converts an audio file to the specified format
  ///
  /// [inputPath] - Path to the input audio file (mp3, wav, ogg)
  /// [outputPath] - Path where the converted file will be saved
  /// [format] - Target audio format (aac or m4a)
  /// [bitRate] - Target bit rate in kbps (default: 128)
  /// [sampleRate] - Target sample rate in Hz (default: 44100)
  /// [onProgress] - Optional callback for conversion progress
  Future<ConversionResult> convertAudio({
    required String inputPath,
    required String outputPath,
    required AudioFormat format,
    int bitRate = 128,
    int sampleRate = 44100,
    ProgressCallback? onProgress,
  }) {
    return FlutterAudioToolkitPlatform.instance.convertAudio(
      inputPath: inputPath,
      outputPath: outputPath,
      format: format,
      bitRate: bitRate,
      sampleRate: sampleRate,
      onProgress: onProgress,
    );
  }

  /// Extracts waveform data from an audio file
  ///
  /// [inputPath] - Path to the input audio file
  /// [samplesPerSecond] - Number of amplitude samples per second (default: 100)
  /// [onProgress] - Optional callback for extraction progress
  Future<WaveformData> extractWaveform({
    required String inputPath,
    int samplesPerSecond = 100,
    ProgressCallback? onProgress,
  }) {
    return FlutterAudioToolkitPlatform.instance.extractWaveform(
      inputPath: inputPath,
      samplesPerSecond: samplesPerSecond,
      onProgress: onProgress,
    );
  }

  /// Checks if the given audio format is supported for conversion
  Future<bool> isFormatSupported(String inputPath) {
    return FlutterAudioToolkitPlatform.instance.isFormatSupported(inputPath);
  }

  /// Gets audio file information without conversion
  Future<Map<String, dynamic>> getAudioInfo(String inputPath) {
    return FlutterAudioToolkitPlatform.instance.getAudioInfo(inputPath);
  }

  /// Trims an audio file to the specified time range
  ///
  /// [inputPath] - Path to the input audio file
  /// [outputPath] - Path where the trimmed file will be saved
  /// [startTimeMs] - Start time in milliseconds
  /// [endTimeMs] - End time in milliseconds
  /// [format] - Target audio format (aac or m4a)
  /// [bitRate] - Target bit rate in kbps (default: 128)
  /// [sampleRate] - Target sample rate in Hz (default: 44100)
  /// [onProgress] - Optional callback for trimming progress
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
    return FlutterAudioToolkitPlatform.instance.trimAudio(
      inputPath: inputPath,
      outputPath: outputPath,
      startTimeMs: startTimeMs,
      endTimeMs: endTimeMs,
      format: format,
      bitRate: bitRate,
      sampleRate: sampleRate,
      onProgress: onProgress,
    );
  }

  /// Generates fake waveform data for testing or preview purposes
  ///
  /// [pattern] - Waveform pattern to generate
  /// [durationMs] - Duration of the waveform in milliseconds (default: 30000 = 30 seconds)
  /// [samplesPerSecond] - Number of amplitude samples per second (default: 100)
  /// [frequency] - Base frequency for pattern generation (default: 440.0 Hz)
  /// [sampleRate] - Sample rate in Hz (default: 44100)
  /// [channels] - Number of audio channels (default: 2 for stereo)
  ///
  /// Returns a [WaveformData] object containing the generated waveform
  WaveformData generateFakeWaveform({
    required WaveformPattern pattern,
    int durationMs = 30000, // 30 seconds default
    int samplesPerSecond = 100,
    double frequency = 440.0,
    int sampleRate = 44100,
    int channels = 2,
  }) {
    final random = Random();
    final totalSamples = (durationMs / 1000.0 * samplesPerSecond).round();
    final amplitudes = <double>[];

    for (int i = 0; i < totalSamples; i++) {
      final timeRatio = i / totalSamples;
      final t = timeRatio * durationMs / 1000.0; // Time in seconds

      double amplitude;

      switch (pattern) {
        case WaveformPattern.sine:
          // Smooth sine wave with slight variations
          amplitude = 0.5 + 0.3 * sin(2 * pi * frequency * t / 1000) + 0.1 * sin(2 * pi * frequency * t / 300);
          break;

        case WaveformPattern.random:
          // Purely random amplitude values
          amplitude = random.nextDouble();
          break;
        case WaveformPattern.music:
          // Music-like pattern with beats, crescendos, and variations
          final bassFreq = 60 + 40 * sin(2 * pi * t / 8); // 8-second bass cycle
          final midFreq = 200 + 100 * sin(2 * pi * t / 4); // 4-second mid cycle
          final highFreq = 800 + 400 * sin(2 * pi * t / 2); // 2-second high cycle

          final bass = 0.6 * sin(2 * pi * bassFreq * t / 100);
          final mid = 0.4 * sin(2 * pi * midFreq * t / 100);
          final high = 0.2 * sin(2 * pi * highFreq * t / 100);

          amplitude = (bass.abs() + mid.abs() + high.abs()) / 3;

          // Ensure some minimum amplitude for music
          amplitude = amplitude * 0.7 + 0.3;

          // Add some dynamics
          if (timeRatio < 0.1 || timeRatio > 0.9) {
            amplitude *= timeRatio < 0.1 ? timeRatio * 10 : (1 - timeRatio) * 10; // Fade in/out
          }
          break;

        case WaveformPattern.speech:
          // Speech-like pattern with pauses and varying intensity
          final speechCycle = (t * 3) % 1; // 3 speech cycles per second

          if (speechCycle < 0.3) {
            // Silence (pause between words)
            amplitude = 0.05 + random.nextDouble() * 0.05; // Very low background noise
          } else if (speechCycle < 0.7) {
            // Speech segment with consonants and vowels
            final intensity = 0.3 + 0.4 * sin(2 * pi * speechCycle * 5);
            amplitude = intensity * (0.8 + 0.2 * random.nextDouble());
          } else {
            // Transition to silence
            amplitude = 0.2 * (1 - (speechCycle - 0.7) / 0.3);
          }
          break;

        case WaveformPattern.pulse:
          // Rhythmic pulse pattern like a heartbeat or drum
          final pulseRate = 1.2; // 1.2 beats per second (72 BPM)
          final pulseCycle = (t * pulseRate) % 1;

          if (pulseCycle < 0.1) {
            amplitude = 0.9; // Strong beat
          } else if (pulseCycle < 0.2) {
            amplitude = 0.3; // Quick decay
          } else if (pulseCycle < 0.5) {
            amplitude = 0.1; // Low level
          } else if (pulseCycle < 0.6) {
            amplitude = 0.6; // Secondary beat
          } else {
            amplitude = 0.05; // Near silence
          }

          // Add some variation
          amplitude *= 0.8 + 0.4 * random.nextDouble();
          break;

        case WaveformPattern.fade:
          // Gradual fade in and out pattern
          final fadeCycle = (t / (durationMs / 1000.0)); // 0 to 1 over full duration
          final baseWave = 0.5 + 0.3 * sin(2 * pi * frequency * t / 100);

          if (fadeCycle < 0.3) {
            // Fade in
            amplitude = baseWave * (fadeCycle / 0.3);
          } else if (fadeCycle < 0.7) {
            // Sustain
            amplitude = baseWave;
          } else {
            // Fade out
            amplitude = baseWave * (1 - (fadeCycle - 0.7) / 0.3);
          }
          break;

        case WaveformPattern.burst:
          // Sudden bursts of activity followed by quiet periods
          final burstCycle = (t * 0.5) % 1; // 0.5 bursts per second

          if (burstCycle < 0.2) {
            // Intense burst
            amplitude = 0.7 + 0.3 * random.nextDouble();
          } else if (burstCycle < 0.4) {
            // Quick decay
            amplitude = 0.5 * (1 - (burstCycle - 0.2) / 0.2);
          } else {
            // Quiet period with occasional small spikes
            amplitude = random.nextDouble() < 0.05 ? 0.3 * random.nextDouble() : 0.02;
          }
          break;
      }

      // Ensure amplitude is between 0.0 and 1.0
      amplitude = amplitude.clamp(0.0, 1.0);
      amplitudes.add(amplitude);
    }

    return WaveformData(amplitudes: amplitudes, sampleRate: sampleRate, durationMs: durationMs, channels: channels);
  }

  /// Downloads an audio file from a network URL and extracts its waveform
  ///
  /// [url] - URL of the audio file to download
  /// [localPath] - Local path where the downloaded file will be saved temporarily
  /// [samplesPerSecond] - Number of amplitude samples per second (default: 100)
  /// [onDownloadProgress] - Optional callback for download progress (0.0 to 0.5)
  /// [onExtractionProgress] - Optional callback for waveform extraction progress (0.5 to 1.0)
  ///
  /// Returns a [WaveformData] object containing the extracted waveform
  Future<WaveformData> extractWaveformFromUrl({
    required String url,
    required String localPath,
    int samplesPerSecond = 100,
    ProgressCallback? onDownloadProgress,
    ProgressCallback? onExtractionProgress,
  }) async {
    try {
      // Download the file with progress tracking
      await _downloadFile(
        url,
        localPath,
        onProgress: (progress) {
          onDownloadProgress?.call(progress * 0.5); // Download takes 50% of total progress
        },
      );

      // Extract waveform from the downloaded file
      final waveformData = await extractWaveform(
        inputPath: localPath,
        samplesPerSecond: samplesPerSecond,
        onProgress: (progress) {
          onExtractionProgress?.call(0.5 + progress * 0.5); // Extraction takes remaining 50%
        },
      );

      // Clean up the temporary file
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }

      return waveformData;
    } catch (e) {
      // Clean up temporary file on error
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    }
  }

  /// Generates a fake waveform for a network audio file without downloading
  /// This is useful for quick previews or when you want to show a waveform
  /// without the overhead of downloading and processing the actual file
  ///
  /// [url] - URL of the audio file (used for consistent pattern generation)
  /// [pattern] - Waveform pattern to generate
  /// [estimatedDurationMs] - Estimated duration in milliseconds (default: 180000 = 3 minutes)  /// [samplesPerSecond] - Number of amplitude samples per second (default: 100)
  ///
  /// Returns a [WaveformData] object with fake but realistic-looking waveform data
  WaveformData generateFakeWaveformForUrl({
    required String url,
    required WaveformPattern pattern,
    int estimatedDurationMs = 180000, // 3 minutes default
    int samplesPerSecond = 100,
  }) {
    // Use URL hash to make the fake waveform consistent for the same URL
    final urlHash = url.hashCode.abs();
    final frequency = 440.0 + (urlHash % 200); // Vary frequency based on URL

    // Create a seeded random generator for consistent results
    final seededRandom = Random(urlHash);

    // Modify the pattern generation to use the seeded random
    final totalSamples = (estimatedDurationMs / 1000.0 * samplesPerSecond).round();
    final amplitudes = <double>[];

    for (int i = 0; i < totalSamples; i++) {
      final timeRatio = i / totalSamples;
      final t = timeRatio * estimatedDurationMs / 1000.0; // Time in seconds

      double amplitude;

      switch (pattern) {
        case WaveformPattern.sine:
          amplitude = 0.5 + 0.3 * sin(2 * pi * frequency * t / 100) + 0.1 * sin(2 * pi * frequency * t / 30);
          // Add URL-specific variation
          amplitude += 0.1 * seededRandom.nextDouble() - 0.05;
          break;

        case WaveformPattern.random:
          amplitude = seededRandom.nextDouble();
          break;

        case WaveformPattern.music:
          final bassFreq = 60 + 40 * sin(2 * pi * t / 8);
          final midFreq = 200 + 100 * sin(2 * pi * t / 4);
          final highFreq = 800 + 400 * sin(2 * pi * t / 2);

          final bass = 0.6 * sin(2 * pi * (bassFreq + urlHash % 50) * t / 100);
          final mid = 0.4 * sin(2 * pi * (midFreq + urlHash % 100) * t / 100);
          final high = 0.2 * sin(2 * pi * (highFreq + urlHash % 200) * t / 100);

          amplitude = (bass.abs() + mid.abs() + high.abs()) / 3;
          amplitude = amplitude * 0.7 + 0.3;

          // Add URL-specific variation
          amplitude += 0.1 * seededRandom.nextDouble() - 0.05;
          break;

        case WaveformPattern.speech:
          final speechCycle = (t * 3) % 1;
          if (speechCycle < 0.3) {
            amplitude = 0.05 + seededRandom.nextDouble() * 0.05;
          } else if (speechCycle < 0.7) {
            final intensity = 0.3 + 0.4 * sin(2 * pi * speechCycle * 5);
            amplitude = intensity * (0.8 + 0.2 * seededRandom.nextDouble());
          } else {
            amplitude = 0.2 * (1 - (speechCycle - 0.7) / 0.3);
          }
          break;

        case WaveformPattern.pulse:
          final pulseRate = 1.2;
          final pulseCycle = (t * pulseRate) % 1;

          if (pulseCycle < 0.1) {
            amplitude = 0.9;
          } else if (pulseCycle < 0.2) {
            amplitude = 0.3;
          } else if (pulseCycle < 0.5) {
            amplitude = 0.1;
          } else if (pulseCycle < 0.6) {
            amplitude = 0.6;
          } else {
            amplitude = 0.05;
          }

          amplitude *= 0.8 + 0.4 * seededRandom.nextDouble();
          break;

        case WaveformPattern.fade:
          final fadeCycle = (t / (estimatedDurationMs / 1000.0));
          final baseWave = 0.5 + 0.3 * sin(2 * pi * frequency * t / 100);

          if (fadeCycle < 0.3) {
            amplitude = baseWave * (fadeCycle / 0.3);
          } else if (fadeCycle < 0.7) {
            amplitude = baseWave;
          } else {
            amplitude = baseWave * (1 - (fadeCycle - 0.7) / 0.3);
          }

          // Add URL-specific variation
          amplitude += 0.1 * seededRandom.nextDouble() - 0.05;
          break;

        case WaveformPattern.burst:
          final burstCycle = (t * 0.5) % 1;

          if (burstCycle < 0.2) {
            amplitude = 0.7 + 0.3 * seededRandom.nextDouble();
          } else if (burstCycle < 0.4) {
            amplitude = 0.5 * (1 - (burstCycle - 0.2) / 0.2);
          } else {
            amplitude = seededRandom.nextDouble() < 0.05 ? 0.3 * seededRandom.nextDouble() : 0.02;
          }
          break;
      }

      amplitude = amplitude.clamp(0.0, 1.0);
      amplitudes.add(amplitude);
    }

    return WaveformData(amplitudes: amplitudes, sampleRate: 44100, durationMs: estimatedDurationMs, channels: 2);
  }

  /// Private helper method to download a file from URL with progress tracking
  Future<void> _downloadFile(String url, String outputPath, {ProgressCallback? onProgress}) async {
    final uri = Uri.parse(url);
    final request = http.Request('GET', uri);
    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to download file: HTTP ${response.statusCode}');
    }

    final file = File(outputPath);
    await file.parent.create(recursive: true);

    final sink = file.openWrite();
    int downloadedBytes = 0;
    final totalBytes = response.contentLength ?? 0;

    await response.stream
        .listen(
          (List<int> chunk) {
            sink.add(chunk);
            downloadedBytes += chunk.length;

            if (totalBytes > 0 && onProgress != null) {
              onProgress(downloadedBytes / totalBytes);
            }
          },
          onDone: () async {
            await sink.close();
            onProgress?.call(1.0);
          },
          onError: (error) async {
            await sink.close();
            throw error;
          },
        )
        .asFuture();
  }

  /// Downloads an audio file from the given URL and saves it to the local file system
  ///
  /// [url] - URL of the audio file to download
  /// [outputPath] - Local path where the downloaded file will be saved
  /// [onProgress] - Optional callback for download progress
  Future<String> downloadFile(String url, String outputPath, {ProgressCallback? onProgress}) async {
    await _downloadFile(url, outputPath, onProgress: onProgress);
    return outputPath;
  }
}
