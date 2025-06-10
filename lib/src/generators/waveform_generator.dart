import 'dart:math';
import '../models/models.dart';

/// Generator for creating synthetic waveform data for testing and preview purposes
class WaveformGenerator {
  /// Default sample rate for generated audio
  static const int defaultSampleRate = 44100;

  /// Default number of channels for generated audio
  static const int defaultChannels = 2;

  /// Default frequency for wave generation
  static const double defaultFrequency = 440.0;

  /// Generates fake waveform data based on the specified pattern
  ///
  /// [pattern] - Waveform pattern to generate
  /// [durationMs] - Duration of the waveform in milliseconds (default: 30000 = 30 seconds)
  /// [samplesPerSecond] - Number of amplitude samples per second (default: 100)
  /// [frequency] - Base frequency for pattern generation (default: 440.0 Hz)
  /// [sampleRate] - Sample rate in Hz (default: 44100)
  /// [channels] - Number of audio channels (default: 2 for stereo)
  /// [random] - Optional random generator for consistent results (if null, creates new instance)
  ///
  /// Returns a [WaveformData] object containing the generated waveform
  static WaveformData generateFakeWaveform({
    required WaveformPattern pattern,
    int durationMs = 30000, // 30 seconds default
    int samplesPerSecond = 100,
    double frequency = defaultFrequency,
    int sampleRate = defaultSampleRate,
    int channels = defaultChannels,
    Random? random,
  }) {
    final randomGen = random ?? Random();
    final totalSamples = (durationMs / 1000.0 * samplesPerSecond).round();
    final amplitudes = <double>[];

    for (int i = 0; i < totalSamples; i++) {
      final timeRatio = i / totalSamples;
      final t = timeRatio * durationMs / 1000.0; // Time in seconds

      double amplitude = _generateAmplitudeForPattern(
        pattern,
        t,
        timeRatio,
        frequency,
        randomGen,
      );

      // Ensure amplitude is between 0.0 and 1.0
      amplitude = amplitude.clamp(0.0, 1.0);
      amplitudes.add(amplitude);
    }
    return WaveformData(
      amplitudes: amplitudes,
      sampleRate: sampleRate,
      durationMs: durationMs,
      channels: channels,
    );
  }

  /// Generates a styled waveform with a predefined color scheme
  ///
  /// [pattern] - Waveform pattern to generate
  /// [style] - Predefined style configuration
  /// [durationMs] - Duration of the waveform in milliseconds (default: 30000 = 30 seconds)
  /// [samplesPerSecond] - Number of amplitude samples per second (default: 100)
  /// [frequency] - Base frequency for pattern generation (default: 440.0 Hz)
  /// [sampleRate] - Sample rate in Hz (default: 44100)
  /// [channels] - Number of audio channels (default: 2 for stereo)
  ///
  /// Returns a [WaveformData] object with the specified style
  static WaveformData generateStyledWaveform({
    required WaveformPattern pattern,
    required WaveformStyle style,
    int durationMs = 30000,
    int samplesPerSecond = 100,
    double frequency = defaultFrequency,
    int sampleRate = defaultSampleRate,
    int channels = defaultChannels,
  }) {
    final waveformData = generateFakeWaveform(
      pattern: pattern,
      durationMs: durationMs,
      samplesPerSecond: samplesPerSecond,
      frequency: frequency,
      sampleRate: sampleRate,
      channels: channels,
    );

    return WaveformData(
      amplitudes: waveformData.amplitudes,
      sampleRate: waveformData.sampleRate,
      durationMs: waveformData.durationMs,
      channels: waveformData.channels,
      style: style,
    );
  }

  /// Generates a waveform that matches the pattern type with appropriate styling
  ///
  /// [pattern] - Waveform pattern to generate
  /// [durationMs] - Duration of the waveform in milliseconds (default: 30000 = 30 seconds)
  /// [samplesPerSecond] - Number of amplitude samples per second (default: 100)
  ///
  /// Returns a [WaveformData] object with automatically selected styling
  static WaveformData generateThemedWaveform({
    required WaveformPattern pattern,
    int durationMs = 30000,
    int samplesPerSecond = 100,
  }) {
    final style = _getStyleForPattern(pattern);
    final frequency = _getFrequencyForPattern(pattern);

    return generateStyledWaveform(
      pattern: pattern,
      style: style,
      durationMs: durationMs,
      samplesPerSecond: samplesPerSecond,
      frequency: frequency,
    );
  }

  /// Gets appropriate style for a pattern
  static WaveformStyle _getStyleForPattern(WaveformPattern pattern) {
    switch (pattern) {
      case WaveformPattern.music:
      case WaveformPattern.electronic:
      case WaveformPattern.rock:
        return WaveformColorSchemes.visualizer;
      case WaveformPattern.classical:
        return WaveformColorSchemes.professional;
      case WaveformPattern.jazz:
        return WaveformColorSchemes.sunset;
      case WaveformPattern.ambient:
      case WaveformPattern.ocean:
      case WaveformPattern.rain:
        return WaveformColorSchemes.ocean;
      case WaveformPattern.speech:
      case WaveformPattern.podcast:
      case WaveformPattern.audiobook:
        return WaveformColorSchemes.classic;
      case WaveformPattern.heartbeat:
        return WaveformColorSchemes.fire;
      case WaveformPattern.whiteNoise:
      case WaveformPattern.pinkNoise:
        return WaveformColorSchemes.monochrome;
      case WaveformPattern.binauralBeats:
        return WaveformColorSchemes.neon;
      default:
        return WaveformColorSchemes.classic;
    }
  }

  /// Gets appropriate frequency for a pattern
  static double _getFrequencyForPattern(WaveformPattern pattern) {
    switch (pattern) {
      case WaveformPattern.electronic:
        return 880.0; // Higher frequency for electronic
      case WaveformPattern.classical:
        return 440.0; // Standard A4
      case WaveformPattern.rock:
        return 220.0; // Lower frequency for rock
      case WaveformPattern.jazz:
        return 554.37; // C#5 for jazz
      case WaveformPattern.ambient:
        return 174.61; // F3 for ambient
      case WaveformPattern.heartbeat:
        return 60.0; // Low frequency for heartbeat
      case WaveformPattern.binauralBeats:
        return 440.0; // Standard for binaural beats
      default:
        return defaultFrequency;
    }
  }

  /// Generates a fake waveform for a network audio file without downloading
  /// This is useful for quick previews or when you want to show a waveform
  /// without the overhead of downloading and processing the actual file
  ///
  /// [url] - URL of the audio file (used for consistent pattern generation)
  /// [pattern] - Waveform pattern to generate
  /// [estimatedDurationMs] - Estimated duration in milliseconds (default: 180000 = 3 minutes)
  /// [samplesPerSecond] - Number of amplitude samples per second (default: 100)
  ///
  /// Returns a [WaveformData] object with fake but realistic-looking waveform data
  static WaveformData generateFakeWaveformForUrl({
    required String url,
    required WaveformPattern pattern,
    int estimatedDurationMs = 180000, // 3 minutes default
    int samplesPerSecond = 100,
  }) {
    // Use URL hash to make the fake waveform consistent for the same URL
    final urlHash = url.hashCode.abs();
    final frequency =
        defaultFrequency + (urlHash % 200); // Vary frequency based on URL

    // Create a seeded random generator for consistent results
    final seededRandom = Random(urlHash);

    return generateFakeWaveform(
      pattern: pattern,
      durationMs: estimatedDurationMs,
      samplesPerSecond: samplesPerSecond,
      frequency: frequency,
      random: seededRandom,
    );
  }

  /// Generates amplitude value for a specific pattern at a given time
  static double _generateAmplitudeForPattern(
    WaveformPattern pattern,
    double t,
    double timeRatio,
    double frequency,
    Random random,
  ) {
    switch (pattern) {
      case WaveformPattern.sine:
        return _generateSinePattern(t, frequency, random);
      case WaveformPattern.random:
        return _generateRandomPattern(random);
      case WaveformPattern.music:
        return _generateMusicPattern(t, timeRatio, random);
      case WaveformPattern.speech:
        return _generateSpeechPattern(t, random);
      case WaveformPattern.pulse:
        return _generatePulsePattern(t, random);
      case WaveformPattern.fade:
        return _generateFadePattern(t, timeRatio, frequency);
      case WaveformPattern.burst:
        return _generateBurstPattern(t, random);
      case WaveformPattern.square:
        return _generateSquarePattern(t, frequency);
      case WaveformPattern.sawtooth:
        return _generateSawtoothPattern(t, frequency);
      case WaveformPattern.triangle:
        return _generateTrianglePattern(t, frequency);
      case WaveformPattern.electronic:
        return _generateElectronicPattern(t, timeRatio, frequency, random);
      case WaveformPattern.classical:
        return _generateClassicalPattern(t, timeRatio, random);
      case WaveformPattern.rock:
        return _generateRockPattern(t, timeRatio, random);
      case WaveformPattern.jazz:
        return _generateJazzPattern(t, timeRatio, random);
      case WaveformPattern.ambient:
        return _generateAmbientPattern(t, timeRatio, frequency, random);
      case WaveformPattern.podcast:
        return _generatePodcastPattern(t, random);
      case WaveformPattern.audiobook:
        return _generateAudiobookPattern(t, random);
      case WaveformPattern.whiteNoise:
        return _generateWhiteNoisePattern(random);
      case WaveformPattern.pinkNoise:
        return _generatePinkNoisePattern(t, random);
      case WaveformPattern.heartbeat:
        return _generateHeartbeatPattern(t, random);
      case WaveformPattern.ocean:
        return _generateOceanPattern(t, random);
      case WaveformPattern.rain:
        return _generateRainPattern(t, random);
      case WaveformPattern.binauralBeats:
        return _generateBinauralBeatsPattern(t, frequency);
    }
  }

  /// Generates a smooth sine wave pattern with slight variations
  static double _generateSinePattern(
    double t,
    double frequency,
    Random random,
  ) {
    return 0.5 +
        0.3 * sin(2 * pi * frequency * t / 1000) +
        0.1 * sin(2 * pi * frequency * t / 300);
  }

  /// Generates purely random amplitude values
  static double _generateRandomPattern(Random random) {
    return random.nextDouble();
  }

  /// Generates music-like pattern with beats, crescendos, and variations
  static double _generateMusicPattern(
    double t,
    double timeRatio,
    Random random,
  ) {
    // Music-like pattern with beats, crescendos, and variations
    final bassFreq = 60 + 40 * sin(2 * pi * t / 8); // 8-second bass cycle
    final midFreq = 200 + 100 * sin(2 * pi * t / 4); // 4-second mid cycle
    final highFreq = 800 + 400 * sin(2 * pi * t / 2); // 2-second high cycle

    final bass = 0.6 * sin(2 * pi * bassFreq * t / 100);
    final mid = 0.4 * sin(2 * pi * midFreq * t / 100);
    final high = 0.2 * sin(2 * pi * highFreq * t / 100);

    double amplitude = (bass.abs() + mid.abs() + high.abs()) / 3;

    // Ensure some minimum amplitude for music
    amplitude = amplitude * 0.7 + 0.3;

    // Add some dynamics
    if (timeRatio < 0.1 || timeRatio > 0.9) {
      amplitude *=
          timeRatio < 0.1
              ? timeRatio * 10
              : (1 - timeRatio) * 10; // Fade in/out
    }

    // Add random variations to make different URLs produce different results
    amplitude += (random.nextDouble() - 0.5) * 0.1; // ±5% random variation

    return amplitude;
  }

  /// Generates speech-like pattern with pauses and varying intensity
  static double _generateSpeechPattern(double t, Random random) {
    final speechCycle = (t * 3) % 1; // 3 speech cycles per second

    if (speechCycle < 0.3) {
      // Silence (pause between words)
      return 0.05 + random.nextDouble() * 0.05; // Very low background noise
    } else if (speechCycle < 0.7) {
      // Speech segment with consonants and vowels
      final intensity = 0.3 + 0.4 * sin(2 * pi * speechCycle * 5);
      return intensity * (0.8 + 0.2 * random.nextDouble());
    } else {
      // Transition to silence
      return 0.2 * (1 - (speechCycle - 0.7) / 0.3);
    }
  }

  /// Generates rhythmic pulse pattern like a heartbeat or drum
  static double _generatePulsePattern(double t, Random random) {
    final pulseRate = 1.2; // 1.2 beats per second (72 BPM)
    final pulseCycle = (t * pulseRate) % 1;

    double amplitude;
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
    return amplitude * (0.8 + 0.4 * random.nextDouble());
  }

  /// Generates gradual fade in and out pattern
  static double _generateFadePattern(
    double t,
    double timeRatio,
    double frequency,
  ) {
    final baseWave = 0.5 + 0.3 * sin(2 * pi * frequency * t / 100);

    if (timeRatio < 0.3) {
      // Fade in
      return baseWave * (timeRatio / 0.3);
    } else if (timeRatio < 0.7) {
      // Sustain
      return baseWave;
    } else {
      // Fade out
      return baseWave * (1 - (timeRatio - 0.7) / 0.3);
    }
  }

  /// Generates sudden bursts of activity followed by quiet periods
  static double _generateBurstPattern(double t, Random random) {
    final burstCycle = (t * 0.5) % 1; // 0.5 bursts per second

    if (burstCycle < 0.2) {
      // Intense burst
      return 0.7 + 0.3 * random.nextDouble();
    } else if (burstCycle < 0.4) {
      // Quick decay
      return 0.5 * (1 - (burstCycle - 0.2) / 0.2);
    } else {
      // Quiet period with occasional small spikes
      return random.nextDouble() < 0.05 ? 0.3 * random.nextDouble() : 0.02;
    }
  }

  /// Generates square wave pattern with sharp transitions
  static double _generateSquarePattern(double t, double frequency) {
    final cycle = (t * frequency / 1000) % 1;
    return cycle < 0.5 ? 0.8 : 0.2;
  }

  /// Generates sawtooth wave pattern with linear ramps
  static double _generateSawtoothPattern(double t, double frequency) {
    final cycle = (t * frequency / 1000) % 1;
    return 0.2 + 0.6 * cycle;
  }

  /// Generates triangle wave pattern with symmetric ramps
  static double _generateTrianglePattern(double t, double frequency) {
    final cycle = (t * frequency / 1000) % 1;
    return cycle < 0.5 ? 0.2 + 1.2 * cycle : 1.4 - 1.2 * cycle;
  }

  /// Generates electronic/synthesized music pattern
  static double _generateElectronicPattern(
    double t,
    double timeRatio,
    double frequency,
    Random random,
  ) {
    // Electronic music with beats, drops, and synthesis
    final beatFreq = 4.0; // 4 beats per second (240 BPM)
    final beatCycle = (t * beatFreq) % 1;

    // Bass line
    final bassAmp = beatCycle < 0.1 ? 0.9 : 0.3 * sin(2 * pi * 60 * t / 1000);

    // Synth lead
    final synthFreq = frequency + 200 * sin(2 * pi * t / 4);
    final synthAmp = 0.4 * sin(2 * pi * synthFreq * t / 1000);

    // Add drops and builds
    double buildupMultiplier = 1.0;
    if (timeRatio > 0.7 && timeRatio < 0.8) {
      // Build up
      buildupMultiplier = 1.0 + 2.0 * (timeRatio - 0.7) / 0.1;
    } else if (timeRatio >= 0.8 && timeRatio < 0.85) {
      // Drop
      buildupMultiplier = 3.0;
    }

    return ((bassAmp.abs() + synthAmp.abs()) / 2) * buildupMultiplier;
  }

  /// Generates classical music with orchestral dynamics
  static double _generateClassicalPattern(
    double t,
    double timeRatio,
    Random random,
  ) {
    // Classical music with orchestral sections and dynamics
    final stringSection = 0.3 * sin(2 * pi * 200 * t / 1000);
    final woodwindSection = 0.2 * sin(2 * pi * 400 * t / 1000 + pi / 4);
    final brassSection = 0.4 * sin(2 * pi * 100 * t / 1000 + pi / 2);

    // Dynamic changes throughout the piece
    double dynamicLevel = 0.5;
    if (timeRatio < 0.2) {
      dynamicLevel = 0.3 + 0.4 * timeRatio / 0.2; // Gradual opening
    } else if (timeRatio > 0.6 && timeRatio < 0.8) {
      dynamicLevel =
          0.7 + 0.3 * sin(2 * pi * (timeRatio - 0.6) / 0.2); // Climax
    } else if (timeRatio > 0.9) {
      dynamicLevel = 0.7 * (1 - (timeRatio - 0.9) / 0.1); // Fade to end
    }

    final amplitude =
        (stringSection.abs() + woodwindSection.abs() + brassSection.abs()) / 3;
    return amplitude * dynamicLevel + 0.1;
  }

  /// Generates rock music with heavy beats and sustained notes
  static double _generateRockPattern(
    double t,
    double timeRatio,
    Random random,
  ) {
    // Rock music with strong beats and guitar riffs
    final drumBeat = _generatePulsePattern(t * 1.5, random); // Faster drum beat
    final bassGuitar = 0.5 * sin(2 * pi * 80 * t / 1000);
    final electricGuitar =
        0.6 * sin(2 * pi * 300 * t / 1000 + random.nextDouble());

    // Add power chord sections
    final powerChordCycle = (t * 0.25) % 1; // Every 4 seconds
    final powerChordAmp = powerChordCycle < 0.5 ? 0.8 : 0.4;

    return ((drumBeat + bassGuitar.abs() + electricGuitar.abs()) / 3) *
            powerChordAmp +
        0.2;
  }

  /// Generates jazz pattern with improvisation and swing
  static double _generateJazzPattern(
    double t,
    double timeRatio,
    Random random,
  ) {
    // Jazz with swing rhythm and improvisation
    final swingBeat = sin(2 * pi * 2.5 * t / 1000); // Swing tempo
    final pianoComping =
        0.3 * sin(2 * pi * 200 * t / 1000 + random.nextDouble());
    final bassWalk = 0.4 * sin(2 * pi * 60 * t / 1000);

    // Add improvisation sections with more variation
    final improSection =
        random.nextDouble() < 0.3 ? 0.5 * random.nextDouble() : 0.0;

    final baseAmplitude =
        (swingBeat.abs() + pianoComping.abs() + bassWalk.abs()) / 3;
    return baseAmplitude + improSection + 0.15;
  }

  /// Generates ambient/drone pattern with sustained tones
  static double _generateAmbientPattern(
    double t,
    double timeRatio,
    double frequency,
    Random random,
  ) {
    // Ambient music with slow evolving textures
    final drone1 =
        0.3 * sin(2 * pi * frequency * t / 2000); // Very slow oscillation
    final drone2 =
        0.2 * sin(2 * pi * (frequency + 5) * t / 3000); // Slight detuning
    final texture = 0.1 * sin(2 * pi * frequency * 2 * t / 5000);

    // Very slow evolution
    final evolution = 0.5 + 0.3 * sin(2 * pi * t / 30000); // 30-second cycle

    return (drone1.abs() + drone2.abs() + texture.abs()) * evolution + 0.1;
  }

  /// Generates podcast/radio pattern with clear speech
  static double _generatePodcastPattern(double t, Random random) {
    // Clear speech with consistent levels and occasional pauses
    final speechCycle = (t * 2.5) % 1; // Slightly faster than normal speech

    if (speechCycle < 0.1) {
      // Brief pause
      return 0.02 + random.nextDouble() * 0.03;
    } else if (speechCycle < 0.8) {
      // Clear, consistent speech
      final consonantVowelPattern = sin(2 * pi * speechCycle * 8);
      return 0.4 +
          0.2 * consonantVowelPattern.abs() +
          0.1 * random.nextDouble();
    } else {
      // End of sentence/thought
      return 0.3 * (1 - (speechCycle - 0.8) / 0.2);
    }
  }

  /// Generates audiobook pattern with consistent speech flow
  static double _generateAudiobookPattern(double t, Random random) {
    // Very consistent speech pattern for audiobooks
    final speechCycle = (t * 3) % 1; // Standard reading pace

    if (speechCycle < 0.05) {
      // Very brief pauses for punctuation
      return 0.05 + random.nextDouble() * 0.05;
    } else {
      // Consistent narration with slight variations
      final baseLevel = 0.5;
      final emphasis =
          0.1 * sin(2 * pi * speechCycle * 6); // Slight emphasis pattern
      final naturalVariation = 0.05 * (random.nextDouble() - 0.5);

      return baseLevel + emphasis + naturalVariation;
    }
  }

  /// Generates white noise pattern for sound masking
  static double _generateWhiteNoisePattern(Random random) {
    return 0.3 + 0.4 * random.nextDouble();
  }

  /// Generates pink noise pattern with frequency-dependent amplitude
  static double _generatePinkNoisePattern(double t, Random random) {
    // Pink noise with 1/f frequency distribution
    final lowFreq = 0.4 * sin(2 * pi * 50 * t / 1000);
    final midFreq = 0.2 * sin(2 * pi * 200 * t / 1000);
    final highFreq = 0.1 * sin(2 * pi * 800 * t / 1000);

    return (lowFreq.abs() + midFreq.abs() + highFreq.abs()) +
        0.2 * random.nextDouble();
  }

  /// Generates heartbeat pattern for relaxation
  static double _generateHeartbeatPattern(double t, Random random) {
    // Realistic heartbeat at ~70 BPM
    final heartRate = 1.17; // 70 BPM = 1.17 beats per second
    final heartCycle = (t * heartRate) % 1;

    if (heartCycle < 0.15) {
      // Systolic beat (lub)
      return 0.8 + 0.2 * random.nextDouble();
    } else if (heartCycle < 0.25) {
      // Quick decay
      return 0.3 * (1 - (heartCycle - 0.15) / 0.1);
    } else if (heartCycle < 0.4) {
      // Diastolic beat (dub)
      return 0.5 + 0.2 * random.nextDouble();
    } else if (heartCycle < 0.5) {
      // Quick decay
      return 0.2 * (1 - (heartCycle - 0.4) / 0.1);
    } else {
      // Quiet period
      return 0.02 + 0.03 * random.nextDouble();
    }
  }

  /// Generates ocean waves pattern for nature sounds
  static double _generateOceanPattern(double t, Random random) {
    // Ocean with multiple wave frequencies
    final bigWaves = 0.6 * sin(2 * pi * t / 8000); // 8-second waves
    final mediumWaves = 0.3 * sin(2 * pi * t / 3000); // 3-second waves
    final smallWaves = 0.2 * sin(2 * pi * t / 1000); // 1-second waves
    final foam = 0.1 * random.nextDouble(); // Random foam/bubbles

    final amplitude =
        (bigWaves.abs() + mediumWaves.abs() + smallWaves.abs()) / 3 + foam;
    return amplitude + 0.2; // Increased baseline for better audibility
  }

  /// Generates rain pattern for ambient sound
  static double _generateRainPattern(double t, Random random) {
    // Rain with varying intensity
    final baseIntensity =
        0.3 + 0.2 * sin(2 * pi * t / 10000); // 10-second intensity cycle
    final raindrops =
        random.nextDouble() < 0.8 ? random.nextDouble() * 0.3 : 0.0;
    final heavyDrops =
        random.nextDouble() < 0.1 ? random.nextDouble() * 0.4 : 0.0;

    return baseIntensity + raindrops + heavyDrops;
  }

  /// Generates binaural beats pattern for meditation
  static double _generateBinauralBeatsPattern(double t, double frequency) {
    // Binaural beats with slight frequency difference
    final leftFreq = frequency;
    final rightFreq = frequency + 10; // 10 Hz difference for alpha waves

    // Simulate the beating effect
    final beatFreq = (rightFreq - leftFreq).abs();
    final beatPattern = sin(2 * pi * beatFreq * t / 1000);
    final carrier = sin(2 * pi * leftFreq * t / 1000);

    return 0.3 + 0.2 * (carrier * beatPattern).abs();
  }
}
