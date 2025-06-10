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
      case WaveformPattern.square:
        return 'Square Wave - Sharp transitions between high/low';
      case WaveformPattern.sawtooth:
        return 'Sawtooth - Linear ramp up pattern';
      case WaveformPattern.triangle:
        return 'Triangle - Symmetric up/down ramps';
      case WaveformPattern.electronic:
        return 'Electronic - EDM with beats and drops';
      case WaveformPattern.classical:
        return 'Classical - Orchestral dynamics';
      case WaveformPattern.rock:
        return 'Rock - Heavy beats and guitar riffs';
      case WaveformPattern.jazz:
        return 'Jazz - Swing rhythm and improvisation';
      case WaveformPattern.ambient:
        return 'Ambient - Slow evolving textures';
      case WaveformPattern.podcast:
        return 'Podcast - Clear speech with pauses';
      case WaveformPattern.audiobook:
        return 'Audiobook - Consistent narration';
      case WaveformPattern.whiteNoise:
        return 'White Noise - Random sound masking';
      case WaveformPattern.pinkNoise:
        return 'Pink Noise - Frequency-dependent noise';
      case WaveformPattern.heartbeat:
        return 'Heartbeat - Realistic heart rhythm';
      case WaveformPattern.ocean:
        return 'Ocean Waves - Multiple wave frequencies';
      case WaveformPattern.rain:
        return 'Rain - Varying intensity rainfall';
      case WaveformPattern.binauralBeats:
        return 'Binaural Beats - Meditation frequency patterns';
    }
  }

  /// Returns category for organizing patterns in UI
  static String getPatternCategory(WaveformPattern pattern) {
    switch (pattern) {
      case WaveformPattern.sine:
      case WaveformPattern.square:
      case WaveformPattern.sawtooth:
      case WaveformPattern.triangle:
      case WaveformPattern.random:
      case WaveformPattern.pulse:
      case WaveformPattern.fade:
      case WaveformPattern.burst:
        return 'Basic Waveforms';

      case WaveformPattern.music:
      case WaveformPattern.electronic:
      case WaveformPattern.classical:
      case WaveformPattern.rock:
      case WaveformPattern.jazz:
      case WaveformPattern.ambient:
        return 'Musical';

      case WaveformPattern.speech:
      case WaveformPattern.podcast:
      case WaveformPattern.audiobook:
        return 'Voice & Speech';

      case WaveformPattern.whiteNoise:
      case WaveformPattern.pinkNoise:
      case WaveformPattern.heartbeat:
      case WaveformPattern.ocean:
      case WaveformPattern.rain:
      case WaveformPattern.binauralBeats:
        return 'Nature & Relaxation';
    }
  }

  /// Gets all patterns grouped by category
  static Map<String, List<WaveformPattern>> getPatternsByCategory() {
    final Map<String, List<WaveformPattern>> categories = {};

    for (final pattern in WaveformPattern.values) {
      final category = getPatternCategory(pattern);
      categories[category] ??= [];
      categories[category]!.add(pattern);
    }

    return categories;
  }
}
