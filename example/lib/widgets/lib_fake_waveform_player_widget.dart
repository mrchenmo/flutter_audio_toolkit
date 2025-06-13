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
  WaveformPattern _selectedPattern = WaveformPattern.music;
  int _samplesPerSecond = 100;

  // Available patterns with user-friendly names
  static const Map<WaveformPattern, String> _patternNames = {
    WaveformPattern.music: 'Music',
    WaveformPattern.speech: 'Speech',
    WaveformPattern.electronic: 'Electronic',
    WaveformPattern.classical: 'Classical',
    WaveformPattern.rock: 'Rock',
    WaveformPattern.jazz: 'Jazz',
    WaveformPattern.ambient: 'Ambient',
    WaveformPattern.podcast: 'Podcast',
    WaveformPattern.audiobook: 'Audiobook',
    WaveformPattern.sine: 'Sine Wave',
    WaveformPattern.random: 'Random',
    WaveformPattern.pulse: 'Pulse',
    WaveformPattern.fade: 'Fade',
    WaveformPattern.burst: 'Burst',
    WaveformPattern.square: 'Square Wave',
    WaveformPattern.sawtooth: 'Sawtooth',
    WaveformPattern.triangle: 'Triangle',
    WaveformPattern.whiteNoise: 'White Noise',
    WaveformPattern.pinkNoise: 'Pink Noise',
    WaveformPattern.heartbeat: 'Heartbeat',
    WaveformPattern.ocean: 'Ocean Waves',
    WaveformPattern.rain: 'Rain',
    WaveformPattern.binauralBeats: 'Binaural Beats',
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
                ),
              ),
              callbacks: AudioPlayerCallbacks(
                onStateChanged: (state) {
                  debugPrint('Lib Fake Player state changed: $state');
                },
                onPositionChanged: (position) {
                  debugPrint(
                    'Lib Fake Player position changed: ${position.inSeconds}s',
                  );
                },
                onDurationChanged: (duration) {
                  debugPrint(
                    'Lib Fake Player duration: ${duration.inSeconds}s',
                  );
                },
                onSeek: (position) {
                  debugPrint(
                    'Lib Fake Player seeked to: ${position.inSeconds}s',
                  );
                },
                onVolumeChanged: (volume) {
                  debugPrint('Lib Fake Player volume changed: $volume');
                },
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
      case WaveformPattern.music:
        return 'General music pattern with dynamic peaks and valleys';
      case WaveformPattern.speech:
        return 'Speech pattern with pauses and varying amplitude';
      case WaveformPattern.electronic:
        return 'Electronic/synthesized music with sharp transitions';
      case WaveformPattern.classical:
        return 'Classical music with orchestral dynamics';
      case WaveformPattern.rock:
        return 'Rock music with heavy beats and sustained notes';
      case WaveformPattern.jazz:
        return 'Jazz pattern with improvisation and swing rhythms';
      case WaveformPattern.ambient:
        return 'Ambient/drone pattern with sustained tones';
      case WaveformPattern.podcast:
        return 'Clear speech pattern suitable for podcasts';
      case WaveformPattern.audiobook:
        return 'Consistent speech flow for audiobooks';
      case WaveformPattern.sine:
        return 'Smooth sine wave pattern';
      case WaveformPattern.random:
        return 'Random amplitude values';
      case WaveformPattern.pulse:
        return 'Pulse/beat pattern with regular intervals';
      case WaveformPattern.fade:
        return 'Gradual fade in/out pattern';
      case WaveformPattern.burst:
        return 'Burst pattern with quiet periods';
      case WaveformPattern.square:
        return 'Square wave with sharp transitions';
      case WaveformPattern.sawtooth:
        return 'Sawtooth wave with linear ramps';
      case WaveformPattern.triangle:
        return 'Triangle wave with symmetric ramps';
      case WaveformPattern.whiteNoise:
        return 'White noise for sound masking';
      case WaveformPattern.pinkNoise:
        return 'Pink noise with frequency-dependent amplitude';
      case WaveformPattern.heartbeat:
        return 'Heartbeat pattern for relaxation';
      case WaveformPattern.ocean:
        return 'Ocean waves pattern for nature sounds';
      case WaveformPattern.rain:
        return 'Rain pattern for ambient sound';
      case WaveformPattern.binauralBeats:
        return 'Binaural beats pattern for meditation';
    }
  }
}
