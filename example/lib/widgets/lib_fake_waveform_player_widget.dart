import 'package:flutter/material.dart';
import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';

/// Widget that uses the actual FakeWaveformAudioPlayer from the lib with pattern selection
class LibFakeWaveformPlayerWidget extends StatefulWidget {
  final String audioPath;

  const LibFakeWaveformPlayerWidget({super.key, required this.audioPath});

  @override
  State<LibFakeWaveformPlayerWidget> createState() =>
      _LibFakeWaveformPlayerWidgetState();

  /// Creates a placeholder widget when no file is selected
  static Widget placeholder(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.library_music, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Select an audio file to use the Lib Fake Waveform Player',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This player uses the official FakeWaveformAudioPlayer from the lib',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibFakeWaveformPlayerWidgetState
    extends State<LibFakeWaveformPlayerWidget> {
  WaveformPattern _selectedPattern = WaveformPattern.edmDrop;
  int _samplesPerSecond = 100;

  // Available patterns with user-friendly names - featuring modern & eye-catching patterns
  static const Map<WaveformPattern, String> _patternNames = {
    // 🎨 Modern & Eye-Catching Patterns (Featured)
    WaveformPattern.edmDrop: '🎵 EDM Drop',
    WaveformPattern.trapBeat: '🎤 Trap Beat',
    WaveformPattern.synthwave: '🌊 Synthwave',
    WaveformPattern.futureBass: '🔊 Future Bass',
    WaveformPattern.dubstep: '💥 Dubstep',
    WaveformPattern.lofiHipHop: '🎧 Lo-fi Hip Hop',
    WaveformPattern.cyberpunk: '🤖 Cyberpunk',
    WaveformPattern.neonLights: '💡 Neon Lights',
    WaveformPattern.retrowave: '📼 Retrowave',
    WaveformPattern.vaporwave: '🌴 Vaporwave',
    WaveformPattern.phonk: '🏎️ Phonk',
    WaveformPattern.gaming: '🎮 Gaming',
    WaveformPattern.cinematicEpic: '🎬 Cinematic Epic',
    WaveformPattern.digitalGlitch: '⚡ Digital Glitch',
    WaveformPattern.crystalClear: '💎 Crystal Clear',
    WaveformPattern.deepBass: '🔊 Deep Bass',
    WaveformPattern.highEnergy: '⚡ High Energy',

    // 🎵 Music Genre Patterns
    WaveformPattern.music: '🎵 Music',
    WaveformPattern.ambient: '🌌 Ambient',
    WaveformPattern.houseMusic: '🏠 House Music',
    WaveformPattern.techno: '🔧 Techno',
    // 🎤 Voice & Speech Patterns
    WaveformPattern.speech: '🗣️ Speech',

    // 🌊 Basic Waveforms
    WaveformPattern.sine: '🌊 Sine Wave',
    WaveformPattern.random: '🎲 Random',
    WaveformPattern.pulse: '💓 Pulse',

    // 🌿 Nature & Relaxation
    WaveformPattern.heartbeat: '💓 Heartbeat',
    WaveformPattern.ocean: '🌊 Ocean Waves',
    WaveformPattern.rain: '🌧️ Rain',
    WaveformPattern.whiteNoise: '⚪ White Noise',
    WaveformPattern.pinkNoise: '🌸 Pink Noise',
    WaveformPattern.binauralBeats: '🧘 Binaural Beats',
  };

  @override
  Widget build(BuildContext context) {
    if (widget.audioPath.isEmpty || widget.audioPath == 'demo_audio.mp3') {
      return LibFakeWaveformPlayerWidget.placeholder(context);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.library_music, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Lib Fake Waveform Player',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Pattern Selection
            Text(
              'Waveform Pattern:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Pattern Dropdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<WaveformPattern>(
                  value: _selectedPattern,
                  isExpanded: true,
                  onChanged: (WaveformPattern? newPattern) {
                    if (newPattern != null) {
                      setState(() {
                        _selectedPattern = newPattern;
                      });
                    }
                  },
                  items:
                      _patternNames.entries.map((entry) {
                        return DropdownMenuItem<WaveformPattern>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Samples per second selection
            Text(
              'Samples per Second: $_samplesPerSecond',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _samplesPerSecond.toDouble(),
              min: 50,
              max: 200,
              divisions: 15,
              label: '$_samplesPerSecond',
              onChanged: (double value) {
                setState(() {
                  _samplesPerSecond = value.round();
                });
              },
            ),

            const SizedBox(height: 16),

            // Audio Player
            FakeWaveformAudioPlayer(
              key: ValueKey(
                '${widget.audioPath}_${_selectedPattern.name}_$_samplesPerSecond',
              ), // Force rebuild when parameters change
              audioPath: widget.audioPath,
              waveformPattern: _selectedPattern,
              samplesPerSecond: _samplesPerSecond,
              waveformConfig: WaveformVisualizationConfig(
                style: WaveformStyle(
                  primaryColor: Colors.purple,
                  lineWidth: 2.0,
                  useGradient: true,
                ),
                height: 120,
                showPosition: true,
                positionIndicatorColor: Colors.orange,
                positionIndicatorWidth: 2,
                interactive: true,
                showProgress: true,
                playedColor: Colors.purple.shade200,
              ),
              controlsConfig: const AudioPlayerControlsConfig(
                showPlayPause: true,
                showProgress: true,
                showTimeLabels: true,
                showVolumeControl: true,
                buttonSize: 56,
                controlsPosition: ControlsPosition.bottom,
                colors: AudioPlayerColors(
                  playButtonColor: Colors.purple,
                  playIconColor: Colors.white,
                  progressActiveColor: Colors.purple,
                  progressInactiveColor: Colors.grey,
                  timeLabelColor: Colors.black87,
                  backgroundColor:
                      Colors
                          .transparent, // Explicitly set transparent background
                ),
              ),
              callbacks: AudioPlayerCallbacks(
                onStateChanged: (state) {},
                onPositionChanged: (position) {},
                onDurationChanged: (duration) {},
                onSeek: (position) {},
                onVolumeChanged: (volume) {},
                onError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lib Fake Player error: $error')),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Pattern Description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.purple.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getPatternDescription(_selectedPattern),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPatternDescription(WaveformPattern pattern) {
    switch (pattern) {
      // 🎨 Modern & Eye-Catching Patterns
      case WaveformPattern.edmDrop:
        return 'Electronic Dance Music with explosive drops and energy builds';
      case WaveformPattern.trapBeat:
        return 'Modern trap/hip-hop with heavy bass drops and snares';
      case WaveformPattern.synthwave:
        return 'Retro 80s style with neon-soaked nostalgia and synths';
      case WaveformPattern.futureBass:
        return 'Melodic drops with emotional builds and future vibes';
      case WaveformPattern.dubstep:
        return 'Heavy wobbles, drops, and electronic mayhem';
      case WaveformPattern.lofiHipHop:
        return 'Chill, relaxed vibes with vinyl crackle aesthetic';
      case WaveformPattern.cyberpunk:
        return 'Dystopian, futuristic vibes with digital rebellion';
      case WaveformPattern.neonLights:
        return 'Pulsing, colorful rhythms like city neon signs';
      case WaveformPattern.retrowave:
        return 'Throwback classic vibes with vintage synthesizers';
      case WaveformPattern.vaporwave:
        return 'Dreamy, nostalgic aesthetics with slowed-down melodies';
      case WaveformPattern.phonk:
        return 'Dark, aggressive Memphis rap style with cowbells';
      case WaveformPattern.gaming:
        return 'Optimized for video game soundtracks and effects';
      case WaveformPattern.cinematicEpic:
        return 'Movie trailer style with dramatic orchestral builds';
      case WaveformPattern.digitalGlitch:
        return 'Glitchy artifacts with digital corruption effects';
      case WaveformPattern.crystalClear:
        return 'Pristine, bell-like tones with perfect clarity';
      case WaveformPattern.deepBass:
        return 'Emphasizes low-frequency content and sub-bass';
      case WaveformPattern.highEnergy:
        return 'Intense, driving rhythms with maximum impact';

      // 🎵 Music Genre Patterns
      case WaveformPattern.music:
        return 'General music pattern with dynamic peaks and valleys';
      case WaveformPattern.ambient:
        return 'Ambient/drone pattern with sustained tones';
      case WaveformPattern.houseMusic:
        return 'Steady 4/4 beats perfect for dancing';
      case WaveformPattern.techno:
        return 'Driving repetitive beats with mechanical precision';

      // 🎤 Voice & Speech Patterns
      case WaveformPattern.speech:
        return 'Speech pattern with pauses and varying amplitude';
      // 🌊 Basic Waveforms
      case WaveformPattern.sine:
        return 'Smooth sine wave pattern';
      case WaveformPattern.random:
        return 'Random amplitude values';
      case WaveformPattern.pulse:
        return 'Pulse/beat pattern with regular intervals';

      // 🌿 Nature & Relaxation
      case WaveformPattern.heartbeat:
        return 'Heartbeat pattern for relaxation';
      case WaveformPattern.ocean:
        return 'Ocean waves pattern for nature sounds';
      case WaveformPattern.rain:
        return 'Rain pattern for ambient sound';
      case WaveformPattern.whiteNoise:
        return 'White noise for sound masking';
      case WaveformPattern.pinkNoise:
        return 'Pink noise with frequency-dependent amplitude';
      case WaveformPattern.binauralBeats:
        return 'Binaural beats pattern for meditation';

      // 🎨 Creative & Artistic
      case WaveformPattern.darkAmbient:
        return 'Mysterious, haunting tones with dark atmosphere';

      // Default for any new patterns not yet described
      default:
        return 'Unique waveform pattern with distinctive characteristics';
    }
  }
}
