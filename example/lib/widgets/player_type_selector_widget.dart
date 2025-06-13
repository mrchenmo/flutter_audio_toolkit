import 'package:flutter/material.dart';

enum PlayerType { trueWaveform, customFakeWaveform, libFakeWaveform }

/// Widget for selecting between different audio player types
class PlayerTypeSelectorWidget extends StatelessWidget {
  final PlayerType selectedPlayerType;
  final ValueChanged<PlayerType> onPlayerTypeChanged;

  const PlayerTypeSelectorWidget({
    super.key,
    required this.selectedPlayerType,
    required this.onPlayerTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Player Type:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // True Waveform Player
            RadioListTile<PlayerType>(
              value: PlayerType.trueWaveform,
              groupValue: selectedPlayerType,
              onChanged: (value) => onPlayerTypeChanged(value!),
              title: const Text('True Waveform Player'),
              subtitle: const Text('Uses actual extracted waveform data'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),

            // Custom Fake Waveform Player
            RadioListTile<PlayerType>(
              value: PlayerType.customFakeWaveform,
              groupValue: selectedPlayerType,
              onChanged: (value) => onPlayerTypeChanged(value!),
              title: const Text('Custom Fake Waveform Player'),
              subtitle: const Text('Custom implementation with real audio'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),

            // Lib Fake Waveform Player
            RadioListTile<PlayerType>(
              value: PlayerType.libFakeWaveform,
              groupValue: selectedPlayerType,
              onChanged: (value) => onPlayerTypeChanged(value!),
              title: const Text('Lib Fake Waveform Player'),
              subtitle: const Text(
                'Official FakeWaveformAudioPlayer with pattern selection',
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ],
        ),
      ),
    );
  }
}
