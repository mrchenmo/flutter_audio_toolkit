import 'package:flutter/material.dart';
import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';

/// Enhanced demo widget showing fake waveform audio player with both local and remote URLs
class RemoteAudioDemoWidget extends StatefulWidget {
  final String? localAudioPath;

  const RemoteAudioDemoWidget({super.key, this.localAudioPath});

  @override
  State<RemoteAudioDemoWidget> createState() => _RemoteAudioDemoWidgetState();
}

class _RemoteAudioDemoWidgetState extends State<RemoteAudioDemoWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WaveformPattern _selectedPattern = WaveformPattern.edmDrop;
  int _samplesPerSecond = 100;
  // Sample remote audio URLs for demonstration
  static const List<Map<String, String>> _remoteAudioSamples = [
    {
      'title': '🎵 Sample Music Track',
      'url': 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      'description': 'A short bell sound for testing',
    },
    {
      'title': '🌊 Ocean Waves',
      'url':
          'https://file-examples.com/storage/fe68c8c7c66c4d6420c5b3a/2017/11/file_example_WAV_1MG.wav',
      'description': 'Relaxing ocean wave sounds',
    },
    {
      'title': '🎹 Piano Sample',
      'url': 'https://www.kozco.com/tech/LRMonoPhase4.wav',
      'description': 'Classical piano melody',
    },
  ];

  // Available patterns with user-friendly names - featuring modern & eye-catching patterns
  static const Map<WaveformPattern, String> _patternNames = {
    // 🎨 Modern & Eye-Catching Patterns (Featured)
    WaveformPattern.edmDrop: '🎵 EDM Drop',
    WaveformPattern.trapBeat: '🎤 Trap Beat',
    WaveformPattern.futureBass: '🚀 Future Bass',
    WaveformPattern.dubstep: '🔊 Dubstep',
    WaveformPattern.synthwave: '🌅 Synthwave',
    WaveformPattern.retrowave: '🌺 Retrowave',
    WaveformPattern.vaporwave: '💜 Vaporwave',
    WaveformPattern.cyberpunk: '🤖 Cyberpunk',
    WaveformPattern.neonLights: '💡 Neon Lights',
    WaveformPattern.lofiHipHop: '🎧 Lo-fi Hip Hop',
    WaveformPattern.ambient: '🌌 Ambient',
    WaveformPattern.darkAmbient: '🌑 Dark Ambient',
    WaveformPattern.chillWave: '🌊 Chill Wave',
    WaveformPattern.gaming: '🎮 Gaming',
    WaveformPattern.digitalGlitch: '📺 Digital Glitch',
    WaveformPattern.crystalClear: '💎 Crystal Clear',
    WaveformPattern.phonk: '👻 Phonk',
    WaveformPattern.houseMusic: '🏠 House Music',
    WaveformPattern.techno: '🔧 Techno',
    // 🎤 Voice & Speech Patterns
    WaveformPattern.speech: '🗣️ Speech',
    // 🌊 Basic Waveforms
    WaveformPattern.sine: '🌊 Sine Wave',
    WaveformPattern.random: '🎲 Random',
    WaveformPattern.pulse: '💓 Pulse',
    // 🌿 Nature & Relaxation
    WaveformPattern.heartbeat: '💓 Heartbeat',
    WaveformPattern.ocean: '🌊 Ocean Waves',
    WaveformPattern.rain: '🌧️ Rain',
    WaveformPattern.whiteNoise: '⚪ White Noise',
    WaveformPattern.pinkNoise: '🌸 Pink Noise',
    WaveformPattern.binauralBeats: '🧘 Binaural Beats',
  };
  int _selectedRemoteIndex = 0; // Will show our test MP4 by default

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.animateTo(1); // Start on the Remote URL tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.cloud_download,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Remote Audio Demo',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Demonstrate fake waveform audio player with both local files and remote URLs',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.file_present), text: 'Local File'),
                Tab(icon: Icon(Icons.cloud), text: 'Remote URL'),
              ],
            ),
            const SizedBox(height: 16),

            // Pattern and settings controls
            _buildSettingsControls(),
            const SizedBox(height: 16),

            // Tab view content
            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [_buildLocalFileTab(), _buildRemoteUrlTab()],
              ),
            ),

            // Info section
            const SizedBox(height: 16),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsControls() {
    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Waveform Settings',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pattern:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      DropdownButton<WaveformPattern>(
                        value: _selectedPattern,
                        isExpanded: true,
                        items:
                            _patternNames.entries.map((entry) {
                              return DropdownMenuItem(
                                value: entry.key,
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                        onChanged: (pattern) {
                          if (pattern != null) {
                            setState(() {
                              _selectedPattern = pattern;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Samples/sec:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      DropdownButton<int>(
                        value: _samplesPerSecond,
                        isExpanded: true,
                        items:
                            [50, 75, 100, 150, 200].map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text('$value'),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _samplesPerSecond = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalFileTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Local Audio File',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (widget.localAudioPath != null) ...[
          Text(
            'File: ${widget.localAudioPath!.split('/').last}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FakeWaveformAudioPlayer(
              key: ValueKey(
                'local_${widget.localAudioPath}_${_selectedPattern.name}_$_samplesPerSecond',
              ),
              audioPath: widget.localAudioPath!,
              waveformPattern: _selectedPattern,
              samplesPerSecond: _samplesPerSecond,
              waveformConfig: WaveformVisualizationConfig(
                style: WaveformStyle(
                  primaryColor: Theme.of(context).primaryColor,
                  lineWidth: 2.0,
                  useGradient: true,
                ),
                height: 120,
                showPosition: true,
                positionIndicatorColor: Theme.of(context).colorScheme.secondary,
                positionIndicatorWidth: 2,
                interactive: true,
                showProgress: true,
                playedColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.3),
              ),
              controlsConfig: AudioPlayerControlsConfig(
                showPlayPause: true,
                showProgress: true,
                showTimeLabels: true,
                showVolumeControl: true,
                buttonSize: 56,
                controlsPosition: ControlsPosition.bottom,
                colors: AudioPlayerColors(
                  playButtonColor: Theme.of(context).primaryColor,
                  playIconColor: Colors.white,
                  progressActiveColor: Theme.of(context).primaryColor,
                  progressInactiveColor: Colors.grey,
                ),
              ),
              autoLoad: true,
            ),
          ),
        ] else ...[
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.file_present, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No local file selected',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select an audio file in the main app to see it here',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRemoteUrlTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remote Audio URL',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // URL selector
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a sample URL:',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(_remoteAudioSamples.length, (index) {
                  final sample = _remoteAudioSamples[index];
                  return RadioListTile<int>(
                    dense: true,
                    title: Text(
                      sample['title']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      sample['description']!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    value: index,
                    groupValue: _selectedRemoteIndex,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRemoteIndex = value;
                        });
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16), // Remote audio player
        Expanded(
          child: FakeWaveformAudioPlayer(
            key: ValueKey(
              'remote_${_remoteAudioSamples[_selectedRemoteIndex]['url']}_${_selectedPattern.name}_$_samplesPerSecond',
            ),
            audioPath: _remoteAudioSamples[_selectedRemoteIndex]['url']!,
            waveformPattern: _selectedPattern,
            samplesPerSecond: _samplesPerSecond,
            waveformConfig: WaveformVisualizationConfig(
              style: WaveformStyle(
                primaryColor: Theme.of(context).primaryColor,
                lineWidth: 2.0,
                useGradient: true,
              ),
              height: 120,
              showPosition: true,
              positionIndicatorColor: Theme.of(context).colorScheme.secondary,
              positionIndicatorWidth: 2,
              interactive: true,
              showProgress: true,
              playedColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.3),
            ),
            controlsConfig: AudioPlayerControlsConfig(
              showPlayPause: true,
              showProgress: true,
              showTimeLabels: true,
              showVolumeControl: true,
              buttonSize: 56,
              controlsPosition: ControlsPosition.bottom,
              colors: AudioPlayerColors(
                playButtonColor: Theme.of(context).primaryColor,
                playIconColor: Colors.white,
                progressActiveColor: Theme.of(context).primaryColor,
                progressInactiveColor: Colors.grey,
              ),
            ),
            autoLoad: true,
            loadingWidget: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Downloading remote audio...'),
                  ],
                ),
              ),
            ),
            errorWidget: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 32),
                    SizedBox(height: 8),
                    Text('Failed to load remote audio'),
                    Text(
                      'Check your internet connection',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border.all(color: Colors.amber[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Demo Information',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Local Tab: Shows fake waveform player with locally selected files\n'
            '• Remote Tab: Demonstrates downloading and playing audio from URLs\n'
            '• Both tabs support all waveform patterns and customization options\n'
            '• Remote files are downloaded to temporary storage automatically\n'
            '• Pattern changes apply to both local and remote audio sources',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.amber[800]),
          ),
        ],
      ),
    );
  }
}
