import 'package:flutter/material.dart';
import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';
import '../models/app_state.dart';
import '../services/audio_service.dart';

/// Widget for audio trimming controls
class TrimmingWidget extends StatelessWidget {
  final AppState appState;
  final VoidCallback onStateChanged;

  const TrimmingWidget({super.key, required this.appState, required this.onStateChanged});

  @override
  Widget build(BuildContext context) {
    if (appState.selectedFilePath == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Audio Trimming', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Format selection
            Row(
              children: [
                const Text('Output Format: '),
                const SizedBox(width: 8),
                DropdownButton<AudioFormat>(
                  value: appState.selectedTrimFormat,
                  items: const [
                    DropdownMenuItem(value: AudioFormat.copy, child: Text('Copy (Lossless)')),
                    DropdownMenuItem(value: AudioFormat.aac, child: Text('AAC (Lossy)')),
                    DropdownMenuItem(value: AudioFormat.m4a, child: Text('M4A (Lossy)')),
                  ],
                  onChanged: (AudioFormat? value) {
                    if (value != null) {
                      appState.selectedTrimFormat = value;
                      onStateChanged();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (appState.selectedTrimFormat == AudioFormat.copy)
              const Text(
                'Copy mode preserves the original format and quality without any conversion.',
                style: TextStyle(fontSize: 12, color: Colors.green),
              )
            else
              const Text(
                'Conversion mode re-encodes the audio, which may reduce quality.',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            const SizedBox(height: 16),
            if (appState.audioInfo != null) ...[
              Text('Duration: ${(appState.audioInfo!['durationMs'] / 1000).toStringAsFixed(1)}s'),
              const SizedBox(height: 8),
              const Text('Start Time (seconds):'),
              Slider(
                value: (appState.trimStartMs / 1000).toDouble(),
                max: (appState.audioInfo!['durationMs'] / 1000).toDouble(),
                onChanged: (value) {
                  final newStartMs = (value * 1000).toInt();
                  final durationMs = appState.audioInfo!['durationMs'] as int;

                  // Ensure start time is within valid bounds
                  appState.trimStartMs = newStartMs.clamp(0, durationMs - 1000);

                  // Ensure end time maintains minimum 1 second gap
                  if (appState.trimEndMs <= appState.trimStartMs) {
                    appState.trimEndMs = (appState.trimStartMs + 1000).clamp(1000, durationMs);
                  }
                  onStateChanged();
                },
                label: '${(appState.trimStartMs / 1000).toStringAsFixed(1)}s',
              ),
              const Text('End Time (seconds):'),
              Slider(
                value: (appState.trimEndMs / 1000).toDouble(),
                max: (appState.audioInfo!['durationMs'] / 1000).toDouble(),
                onChanged: (value) {
                  final newEndMs = (value * 1000).toInt();
                  final durationMs = appState.audioInfo!['durationMs'] as int;

                  // Ensure end time is within valid bounds
                  appState.trimEndMs = newEndMs.clamp(1000, durationMs);

                  // Ensure start time maintains minimum 1 second gap
                  if (appState.trimStartMs >= appState.trimEndMs) {
                    appState.trimStartMs = (appState.trimEndMs - 1000).clamp(0, durationMs - 1000);
                  }
                  onStateChanged();
                },
                label: '${(appState.trimEndMs / 1000).toStringAsFixed(1)}s',
              ),
              const SizedBox(height: 8),
              Text(
                'Trim range: ${(appState.trimStartMs / 1000).toStringAsFixed(1)}s - ${(appState.trimEndMs / 1000).toStringAsFixed(1)}s',
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed:
                  (appState.isTrimming || appState.selectedFilePath == null || appState.audioInfo == null)
                      ? null
                      : _trimAudio,
              child: const Text('Trim Audio'),
            ),
            if (appState.isTrimming) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: appState.trimProgress),
              const SizedBox(height: 8),
              Text('Trimming: ${(appState.trimProgress * 100).toStringAsFixed(1)}%'),
            ],
            if (appState.trimmedFilePath != null) ...[
              const SizedBox(height: 16),
              Text('Trimmed file: ${appState.trimmedFilePath!.split('/').last}'),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _trimAudio() async {
    await AudioService.trimAudio(appState);
    onStateChanged();
  }
}
