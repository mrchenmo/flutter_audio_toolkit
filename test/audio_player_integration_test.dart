import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';

void main() {
  group('Audio Player Integration Tests', () {
    test('should export all audio player classes', () {
      // Test that all new audio player classes are accessible
      expect(TrueWaveformAudioPlayer, isNotNull);
      expect(FakeWaveformAudioPlayer, isNotNull);
      expect(AudioPlayerControls, isNotNull);
      expect(WaveformVisualizer, isNotNull);
      expect(AudioPlayerService, isNotNull);
    });

    test('should export all audio player configuration classes', () {
      // Test that all configuration classes are accessible
      expect(AudioPlayerControlsConfig, isNotNull);
      expect(AudioPlayerColors, isNotNull);
      expect(WaveformVisualizationConfig, isNotNull);
      expect(AudioPlayerCallbacks, isNotNull);
      expect(AudioPlayerStateManager, isNotNull);
    });

    test('should export all enums', () {
      // Test that enums are accessible
      expect(ControlsPosition.bottom, ControlsPosition.bottom);
      expect(AudioPlayerState.stopped, AudioPlayerState.stopped);
    });

    test('should create default configurations', () {
      // Test default configuration creation
      const controlsConfig = AudioPlayerControlsConfig();
      expect(controlsConfig.showPlayPause, true);
      expect(controlsConfig.showProgress, true);
      expect(controlsConfig.buttonSize, 48.0);

      const colors = AudioPlayerColors();
      expect(colors.playButtonColor, isNotNull);
      expect(colors.playIconColor, isNotNull);

      const callbacks = AudioPlayerCallbacks();
      expect(callbacks.onStateChanged, null);
      expect(callbacks.onPositionChanged, null);
    });

    test('should create waveform visualization config', () {
      const style = WaveformStyle(primaryColor: Colors.blue);
      const config = WaveformVisualizationConfig(style: style);

      expect(config.style.primaryColor, Colors.blue);
      expect(config.height, 80.0);
      expect(config.showPosition, true);
      expect(config.interactive, true);
    });
  });
}
