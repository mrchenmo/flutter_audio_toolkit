import 'package:flutter/material.dart';
import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';
import '../services/example_audio_player_service.dart';
import 'audio_waveform_painter.dart' as custom;

/// Custom fake waveform player that uses real audio playback
class CustomFakeWaveformPlayer extends StatefulWidget {
  final String audioPath;
  final WaveformData? waveformData;

  const CustomFakeWaveformPlayer({
    super.key,
    required this.audioPath,
    this.waveformData,
  });

  @override
  State<CustomFakeWaveformPlayer> createState() =>
      _CustomFakeWaveformPlayerState();

  /// Creates a placeholder widget when no file is selected
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
                'Select an audio file to use the Fake Waveform Player',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This player uses generated waveform patterns with real audio playback',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomFakeWaveformPlayerState extends State<CustomFakeWaveformPlayer> {
  AudioPlayerState _playerState = AudioPlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLoading = false;
  ExampleAudioPlayerService? _playerService;
  WaveformData? _localWaveformData;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _playerService?.dispose();
    super.dispose();
  }

  void _initializePlayer() async {
    if (widget.audioPath.isEmpty || widget.audioPath == 'demo_audio.mp3') {
      debugPrint('No valid audio file selected for fake waveform player');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create a dedicated player service for this fake waveform player
      _playerService = ExampleAudioPlayerService.create(
        playerId: 'fake_waveform_player',
      );

      // Setup callbacks
      _playerService!.addStateCallback(_onStateChanged);
      _playerService!.addPositionCallback(_onPositionChanged);
      _playerService!.addDurationCallback(_onDurationChanged);
      _playerService!.addErrorCallback(_onError);

      debugPrint(
        'Loading audio file in fake waveform player: ${widget.audioPath}',
      );

      // Load the actual audio file
      await _playerService!.loadAudio(widget.audioPath);

      setState(() {
        _isLoading = false;
        _duration = _playerService!.duration;
        _position = _playerService!.position;
        _playerState = _playerService!.state;
      });

      debugPrint(
        'Audio loaded successfully in fake waveform player. Duration: $_duration',
      );

      // Now generate a new fake waveform with the correct duration if current one doesn't match
      if (widget.waveformData == null ||
          widget.waveformData!.durationMs != _duration.inMilliseconds) {
        debugPrint(
          'Generating new fake waveform with duration: ${_duration.inMilliseconds}ms',
        );
        _generateFakeWaveformForDuration(_duration.inMilliseconds);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Failed to load audio in fake waveform player: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load audio: $e')));
      }
    }
  }

  void _generateFakeWaveformForDuration(int durationMs) {
    try {
      final toolkit = FlutterAudioToolkit();
      final newWaveform = toolkit.generateFakeWaveform(
        pattern: WaveformPattern.music,
        durationMs: durationMs,
        samplesPerSecond: 100,
      );

      // Store this in a local variable since widget.waveformData is immutable
      setState(() {
        _localWaveformData = newWaveform;
      });

      debugPrint(
        'Generated fake waveform with actual duration: ${durationMs}ms',
      );
    } catch (e) {
      debugPrint('Failed to generate fake waveform: $e');
    }
  }

  void _onStateChanged(AudioPlayerState state) {
    if (mounted) {
      setState(() {
        _playerState = state;
      });
    }
  }

  void _onPositionChanged(Duration position) {
    if (mounted) {
      setState(() {
        _position = position;
      });
    }
  }

  void _onDurationChanged(Duration duration) {
    if (mounted) {
      setState(() {
        _duration = duration;
      });
    }
  }

  void _onError(String error) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Player error: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading audio...'),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Waveform display
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: CustomPaint(
            painter: custom.WaveformPainter(
              waveformData: _localWaveformData ?? widget.waveformData,
              progress:
                  _duration.inMilliseconds > 0
                      ? _position.inMilliseconds / _duration.inMilliseconds
                      : 0.0,
              primaryColor: Colors.green,
              playedColor: Colors.green.shade200,
              positionIndicatorColor: Colors.orange,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Play/Pause button
            IconButton(
              iconSize: 48,
              onPressed: _isLoading ? null : _togglePlayPause,
              icon: Container(
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _playerState == AudioPlayerState.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Stop button
            IconButton(
              iconSize: 32,
              onPressed: _isLoading ? null : _stop,
              icon: const Icon(Icons.stop, color: Colors.grey),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Progress bar
        Slider(
          value:
              _duration.inMilliseconds > 0
                  ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(
                    0.0,
                    1.0,
                  )
                  : 0.0,
          onChanged: _isLoading ? null : _onSeek,
          activeColor: Colors.green,
          inactiveColor: Colors.grey[300],
        ),

        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: const TextStyle(color: Colors.black87, fontSize: 12),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(color: Colors.black87, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _togglePlayPause() async {
    try {
      await _playerService?.togglePlayPause();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Playback error: $e')));
      }
    }
  }

  void _stop() async {
    try {
      await _playerService?.stop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Stop error: $e')));
      }
    }
  }

  void _onSeek(double value) async {
    if (_duration.inMilliseconds > 0) {
      final position = Duration(
        milliseconds: (value * _duration.inMilliseconds).round(),
      );
      try {
        await _playerService?.seekTo(position);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Seek error: $e')));
        }
      }
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
