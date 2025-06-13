import 'package:flutter/material.dart';

/// Widget displaying documentation about audio player features
class AudioPlayerDocumentationWidget extends StatelessWidget {
  const AudioPlayerDocumentationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audio Player Features',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              '• True Waveform Player: Uses extracted waveform data from actual audio files',
            ),
            const Text(
              '• Fake Waveform Player: Uses generated waveform patterns for quick prototyping',
            ),
            const Text(
              '• Customizable controls: Play/pause, progress, time labels, volume',
            ),
            const Text('• Interactive waveform: Tap to seek to any position'),
            const Text(
              '• Visual progress: Shows played portion with different colors',
            ),
            const Text(
              '• Position indicator: Red line shows current playback position',
            ),
            const Text(
              '• Configurable styling: Colors, sizes, positions, and gradients',
            ),
            const Text(
              '• Event callbacks: State changes, position updates, errors',
            ),
            const Text(
              '• Multiple control layouts: Bottom, top, overlay, left, right',
            ),
            const SizedBox(height: 16),
            Text(
              'Implementation Notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            const Text('• Both players support the same configuration options'),
            const Text(
              '• True waveform requires actual audio file and extraction',
            ),
            const Text('• Fake waveform is ideal for demos and testing'),
            const Text('• All operations are performed on background threads'),
            const Text('• Memory efficient waveform rendering'),
            const Text('• Native audio playback on both Android and iOS'),
          ],
        ),
      ),
    );
  }
}
