import 'package:flutter/material.dart';

/// Widget for displaying file selection UI and waveform extraction controls
class FileSelectionWidget extends StatelessWidget {
  final String? selectedFilePath;
  final bool isExtracting;
  final VoidCallback? onExtractWaveform;

  const FileSelectionWidget({
    super.key,
    required this.selectedFilePath,
    required this.isExtracting,
    this.onExtractWaveform,
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
              'Selected Audio File:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              selectedFilePath ??
                  'No file selected. Please use "Pick Audio File" above.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selectedFilePath != null ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  selectedFilePath != null && !isExtracting
                      ? onExtractWaveform
                      : null,
              child:
                  isExtracting
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Extract Waveform'),
            ),
          ],
        ),
      ),
    );
  }
}
