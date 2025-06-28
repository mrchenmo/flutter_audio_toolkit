import 'package:flutter/material.dart';
import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';
import '../models/app_state.dart';
import '../services/example_audio_player_service.dart';
import 'file_selection_widget.dart';
import 'player_type_selector_widget.dart';
import 'true_waveform_player_widget.dart';
import 'custom_fake_waveform_player.dart';
import 'lib_fake_waveform_player_widget.dart';
import 'remote_audio_demo_widget.dart';
import 'audio_player_documentation_widget.dart';

/// Main audio player demo widget that coordinates all audio player components
class AudioPlayerDemoWidget extends StatefulWidget {
  final AppState appState;

  const AudioPlayerDemoWidget({super.key, required this.appState});

  @override
  State<AudioPlayerDemoWidget> createState() => _AudioPlayerDemoWidgetState();
}

class _AudioPlayerDemoWidgetState extends State<AudioPlayerDemoWidget>
    with SingleTickerProviderStateMixin {
  WaveformData? _extractedWaveform;
  bool _isExtracting = false;
  PlayerType _selectedPlayerType = PlayerType.libFakeWaveform;
  late TabController _tabController;

  // Example audio player service for real playback
  ExampleAudioPlayerService? _examplePlayerService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeExamplePlayer();
  }

  @override
  void dispose() {
    _examplePlayerService?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AudioPlayerDemoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When file changes, the custom players will handle their own reinitialization
    if (widget.appState.selectedFilePath !=
        oldWidget.appState.selectedFilePath) {}
  }

  void _initializeExamplePlayer() {
    _examplePlayerService = ExampleAudioPlayerService.create(
      playerId: 'demo_player',
    );
  }

  // Get the current selected file path from appState
  String? get _selectedAudioPath => widget.appState.selectedFilePath;

  Future<void> _extractWaveformFromFile() async {
    if (_selectedAudioPath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an audio file first')),
        );
      }
      return;
    }

    setState(() {
      _isExtracting = true;
    });

    try {
      final waveform = await FlutterAudioToolkit().extractWaveform(
        inputPath: _selectedAudioPath!,
        samplesPerSecond: 100,
        onProgress: (progress) {
          // Update extraction progress if needed
        },
      );

      if (mounted) {
        setState(() {
          _extractedWaveform = waveform;
          _isExtracting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Waveform extracted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExtracting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to extract waveform: $e')),
        );
      }
    }
  }

  void _onPlayerTypeChanged(PlayerType playerType) {
    setState(() {
      _selectedPlayerType = playerType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Audio Player Demo',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Explore different audio player types with local files and remote URLs',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Tab bar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.music_note), text: 'Player Types'),
            Tab(icon: Icon(Icons.cloud_download), text: 'Remote Audio'),
          ],
        ),

        // Tab view content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildPlayerTypesTab(), _buildRemoteAudioTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerTypesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File selection component
          FileSelectionWidget(
            selectedFilePath: _selectedAudioPath,
            isExtracting: _isExtracting,
            onExtractWaveform: _extractWaveformFromFile,
          ),

          const SizedBox(height: 24),

          // Player type selector component
          PlayerTypeSelectorWidget(
            selectedPlayerType: _selectedPlayerType,
            onPlayerTypeChanged: _onPlayerTypeChanged,
          ),

          const SizedBox(height: 24),

          // Display selected player
          _buildSelectedPlayer(),

          const SizedBox(height: 32),

          // Documentation component
          const AudioPlayerDocumentationWidget(),
        ],
      ),
    );
  }

  Widget _buildRemoteAudioTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: RemoteAudioDemoWidget(localAudioPath: _selectedAudioPath),
    );
  }

  Widget _buildSelectedPlayer() {
    switch (_selectedPlayerType) {
      case PlayerType.trueWaveform:
        return _buildTrueWaveformPlayer();
      case PlayerType.customFakeWaveform:
        return _buildCustomFakeWaveformPlayer();
      case PlayerType.libFakeWaveform:
        return _buildLibFakeWaveformPlayer();
    }
  }

  Widget _buildTrueWaveformPlayer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'True Waveform Audio Player',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (_extractedWaveform != null && _selectedAudioPath != null)
          TrueWaveformPlayerWidget(
            audioPath: _selectedAudioPath!,
            waveformData: _extractedWaveform!,
          )
        else
          TrueWaveformPlayerWidget.placeholder(context),
      ],
    );
  }

  Widget _buildCustomFakeWaveformPlayer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Fake Waveform Audio Player',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (_selectedAudioPath != null)
          CustomFakeWaveformPlayer(
            audioPath: _selectedAudioPath!,
            waveformData:
                null, // Let the custom player generate its own waveform
          )
        else
          CustomFakeWaveformPlayer.placeholder(context),
      ],
    );
  }

  Widget _buildLibFakeWaveformPlayer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lib Fake Waveform Audio Player',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (_selectedAudioPath != null)
          LibFakeWaveformPlayerWidget(audioPath: _selectedAudioPath!)
        else
          LibFakeWaveformPlayerWidget.placeholder(context),
      ],
    );
  }
}
