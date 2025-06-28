import 'package:flutter/material.dart';
import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';

/// Widget that wraps the true waveform audio player with proper configuration
class TrueWaveformPlayerWidget extends StatelessWidget {
  final String audioPath;
  final WaveformData waveformData;

  const TrueWaveformPlayerWidget({
    super.key,
    required this.audioPath,
    required this.waveformData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TrueWaveformAudioPlayer(
          audioPath: audioPath,
          waveformConfig: WaveformVisualizationConfig(
            style: WaveformStyle(
              primaryColor: Colors.blue,
              lineWidth: 2.0,
              useGradient: true,
            ),
            height: 120,
            showPosition: true,
            positionIndicatorColor: Colors.red,
            positionIndicatorWidth: 2,
            interactive: true,
            showProgress: true,
            playedColor: Colors.blue.shade200,
          ),
          controlsConfig: const AudioPlayerControlsConfig(
            showPlayPause: true,
            showProgress: true,
            showTimeLabels: true,
            showVolumeControl: true,
            buttonSize: 56,
            controlsPosition: ControlsPosition.bottom,
            colors: AudioPlayerColors(
              playButtonColor: Colors.blue,
              playIconColor: Colors.white,
              progressActiveColor: Colors.blue,
              progressInactiveColor: Colors.grey,
              timeLabelColor: Colors.black87,
            ),
          ),
          callbacks: AudioPlayerCallbacks(
            onError: (error) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Player error: $error')));
            },
          ),
        ),
      ),
    );
  }

  /// Creates a placeholder widget when no file is selected or waveform is not extracted
  static Widget placeholder(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.audiotrack, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Select an audio file and extract waveform to use the True Waveform Player',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
