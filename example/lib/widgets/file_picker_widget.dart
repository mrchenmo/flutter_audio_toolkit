import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/app_state.dart';
import '../services/audio_service.dart';
import '../services/validation_service.dart';

/// Widget for file picking and URL input
class FilePickerWidget extends StatelessWidget {
  final AppState appState;
  final VoidCallback onError;

  const FilePickerWidget({
    super.key,
    required this.appState,
    required this.onError,
  });

  Future<void> _pickAudioFile() async {
    // Request permissions first
    if (!await ValidationService.validateStoragePermissions()) {
      onError();
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg', 'm4a', 'aac'],
    );

    if (result != null) {
      final selectedPath = result.files.single.path;

      // Validate the selected file
      if (selectedPath == null) {
        onError();
        return;
      }

      final file = File(selectedPath);
      if (!await file.exists()) {
        onError();
        return;
      }

      // Check if file has audio data (basic check)
      final fileSize = await file.length();
      if (fileSize == 0) {
        onError();
        return;
      }

      appState.selectedFilePath = selectedPath;
      appState.resetForNewFile();

      if (appState.selectedFilePath != null) {
        // Validate format support first
        if (await ValidationService.validateFormatSupport(appState)) {
          await AudioService.getAudioInfo(appState);
          // Initialize trim end time to audio duration
          if (appState.audioInfo != null &&
              appState.audioInfo!['durationMs'] != null) {
            appState.trimEndMs = appState.audioInfo!['durationMs'] as int;
          }
        }
      }
    }
  }

  Future<void> _processUrlFile() async {
    try {
      await AudioService.processUrlFile(appState);
    } catch (e) {
      onError();
    }
  }

  Future<void> _generateFakeWaveformFromUrl() async {
    try {
      await AudioService.generateFakeWaveformFromUrl(appState);
    } catch (e) {
      onError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Platform: ${appState.platformVersion}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickAudioFile,
              child: const Text('Pick Audio File'),
            ),
            if (appState.selectedFilePath != null) ...[
              const SizedBox(height: 8),
              Text('Selected: ${appState.selectedFilePath!.split('/').last}'),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Or process from Network URL:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(
                text:
                    'https://ro-prod-content.blr1.cdn.digitaloceanspaces.com/dolby/previews/fr_marchingband_a.mp4',
              ), // appState.urlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com/audio.mp3',
                labelText: 'Audio File URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              enabled: !appState.isDownloading && !appState.isExtracting,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        (appState.isDownloading ||
                                appState.isExtracting ||
                                appState.urlController.text.trim().isEmpty)
                            ? null
                            : _processUrlFile,
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Extract Real Waveform'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        (appState.isExtracting ||
                                appState.urlController.text.trim().isEmpty)
                            ? null
                            : _generateFakeWaveformFromUrl,
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Generate Fake'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade100,
                      foregroundColor: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),

            if (appState.isDownloading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: appState.downloadProgress),
              const SizedBox(height: 8),
              Text(
                'Downloading: ${(appState.downloadProgress * 100).toStringAsFixed(1)}%',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
