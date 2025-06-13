import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

// Import our modular components
import 'models/app_state.dart';
import 'services/audio_service.dart';
import 'widgets/file_picker_widget.dart';
import 'widgets/audio_info_widget.dart';
import 'widgets/conversion_widget.dart';
import 'widgets/waveform_widget.dart';
import 'widgets/trimming_widget.dart';
import 'widgets/noise_detection_widget.dart';
import 'widgets/audio_player_demo_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Audio Toolkit Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChangeNotifierProvider(
        create: (context) => AppState(),
        child: const AudioToolkitHome(),
      ),
    );
  }
}

class AudioToolkitHome extends StatefulWidget {
  const AudioToolkitHome({super.key});

  @override
  State<AudioToolkitHome> createState() => _AudioToolkitHomeState();
}

class _AudioToolkitHomeState extends State<AudioToolkitHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await _requestPermissions();
    await _initPlatformState(appState);
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await [
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.audio,
        Permission.microphone,
      ].request();
    }
  }

  Future<void> _initPlatformState(AppState appState) async {
    try {
      final platformVersion = await AudioService.getPlatformVersion(appState);
      appState.platformVersion = platformVersion;
    } on PlatformException {
      appState.platformVersion = 'Failed to get platform version.';
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Audio Converter & Waveform'),
            backgroundColor: Colors.blue,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // File Picker and URL Input Section
                FilePickerWidget(
                  appState: appState,
                  onError: () => _showError('Failed to select or process file'),
                ),

                // Audio Information Section
                AudioInfoWidget(appState: appState),

                // Audio Conversion Section
                if (appState.selectedFilePath != null) ...[
                  const SizedBox(height: 16),
                  ConversionWidget(
                    appState: appState,
                    onStateChanged: _onStateChanged,
                  ),

                  // Waveform Extraction Section
                  const SizedBox(height: 16),
                  WaveformWidget(
                    appState: appState,
                    onStateChanged: _onStateChanged,
                  ), // Audio Trimming Section                  const SizedBox(height: 16),
                  TrimmingWidget(
                    appState: appState,
                    onStateChanged: _onStateChanged,
                  ), // Noise Detection & Analysis Section
                  const SizedBox(height: 16),
                  NoiseDetectionWidget(
                    appState: appState,
                    onStateChanged: _onStateChanged,
                  ), // Audio Player Demo Section
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 600, // Fixed height for tab view
                    child: AudioPlayerDemoWidget(appState: appState),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
