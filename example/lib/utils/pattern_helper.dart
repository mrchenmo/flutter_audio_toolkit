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
      case WaveformPattern.ambient:
        return 'Ambient - Slow evolving textures';

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
      default:
        return 'Modern Audio Pattern - Contemporary style waveform';
    }
  }

  /// Returns category for organizing patterns in UI
  static String getPatternCategory(WaveformPattern pattern) {
    switch (pattern) {
      case WaveformPattern.sine:
      case WaveformPattern.random:
      case WaveformPattern.pulse:
        return 'Basic Waveforms';

      case WaveformPattern.music:
      case WaveformPattern.ambient:
        return 'Musical';

      case WaveformPattern.speech:
        return 'Voice & Speech';

      case WaveformPattern.whiteNoise:
      case WaveformPattern.pinkNoise:
      case WaveformPattern.heartbeat:
      case WaveformPattern.ocean:
      case WaveformPattern.rain:
      case WaveformPattern.binauralBeats:
        return 'Nature & Relaxation';
      case WaveformPattern.trapBeat:
      case WaveformPattern.edmDrop:
      case WaveformPattern.lofiHipHop:
      case WaveformPattern.synthwave:
      case WaveformPattern.futureBass:
      case WaveformPattern.dubstep:
      case WaveformPattern.houseMusic:
      case WaveformPattern.techno:
      case WaveformPattern.vaporwave:
      case WaveformPattern.phonk:
      case WaveformPattern.retrowave:
      case WaveformPattern.cyberpunk:
      case WaveformPattern.neonLights:
      case WaveformPattern.gaming:
      case WaveformPattern.cinematicEpic:
      case WaveformPattern.digitalGlitch:
      case WaveformPattern.crystalClear:
      case WaveformPattern.deepBass:
      case WaveformPattern.highEnergy:
      case WaveformPattern.darkAmbient:
      case WaveformPattern.chillWave:
        return 'Modern';
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
