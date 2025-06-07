import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';

/// Helper class for waveform pattern descriptions
class PatternHelper {
  /// Returns a user-friendly description for each waveform pattern
  static String getPatternDescription(WaveformPattern pattern) {
    switch (pattern) {
      case WaveformPattern.sine:
        return 'Sine Wave - Smooth sinusoidal pattern';
      case WaveformPattern.random:
        return 'Random - Random amplitude values';
      case WaveformPattern.music:
        return 'Music - Music-like with beats and dynamics';
      case WaveformPattern.speech:
        return 'Speech - Speech-like with pauses';
      case WaveformPattern.pulse:
        return 'Pulse - Rhythmic pulse/beat pattern';
      case WaveformPattern.fade:
        return 'Fade - Gradual fade in/out';
      case WaveformPattern.burst:
        return 'Burst - Sudden bursts with quiet periods';
    }
  }
}
