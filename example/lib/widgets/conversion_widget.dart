import 'package:flutter/material.dart';
import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';
import '../models/app_state.dart';
import '../services/audio_service.dart';

/// Widget for audio conversion controls
class ConversionWidget extends StatelessWidget {
  final AppState appState;
  final VoidCallback onStateChanged;

  const ConversionWidget({
    super.key,
    required this.appState,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (appState.selectedFilePath == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audio Conversion',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        appState.isConverting
                            ? null
                            : () => _convertAudio(AudioFormat.aac),
                    child: const Text('Convert to AAC'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        appState.isConverting
                            ? null
                            : () => _convertAudio(AudioFormat.m4a),
                    child: const Text('Convert to M4A'),
                  ),
                ),
              ],
            ),
            if (appState.isConverting) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: appState.conversionProgress),
              const SizedBox(height: 8),
              Text(
                'Converting: ${(appState.conversionProgress * 100).toStringAsFixed(1)}%',
              ),
            ],
            if (appState.convertedFilePath != null) ...[
              const SizedBox(height: 16),
              Text(
                'Converted file: ${appState.convertedFilePath!.split('/').last}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _convertAudio(AudioFormat format) async {
    await AudioService.convertAudio(appState, format);
    onStateChanged();
  }
}
