import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';
import 'dart:ui';

void main() {
  group('Enhanced Waveform Generation Tests', () {
    late FlutterAudioToolkit plugin;

    setUp(() {
      plugin = FlutterAudioToolkit();
    });

    test('generates all waveform patterns successfully', () {
      for (final pattern in WaveformPattern.values) {
        final waveform = plugin.generateFakeWaveform(
          pattern: pattern,
          durationMs: 5000, // 5 seconds for faster testing
          samplesPerSecond: 50,
        );

        expect(
          waveform.amplitudes.isNotEmpty,
          true,
          reason: 'Pattern $pattern should generate amplitudes',
        );
        expect(
          waveform.durationMs,
          5000,
          reason: 'Pattern $pattern should have correct duration',
        );
        expect(
          waveform.amplitudes.every((amp) => amp >= 0.0 && amp <= 1.0),
          true,
          reason: 'Pattern $pattern should have normalized amplitudes',
        );
      }
    });

    test('generates styled waveforms correctly', () {
      const style = WaveformColorSchemes.neon;
      final waveform = plugin.generateStyledWaveform(
        pattern: WaveformPattern.electronic,
        style: style,
        durationMs: 3000,
      );

      expect(waveform.style, equals(style));
      expect(waveform.amplitudes.isNotEmpty, true);
      expect(waveform.durationMs, 3000);
    });

    test('generates themed waveforms with automatic styling', () {
      final waveform = plugin.generateThemedWaveform(
        pattern: WaveformPattern.jazz,
        durationMs: 2000,
      );

      expect(waveform.style, isNotNull);
      expect(waveform.amplitudes.isNotEmpty, true);
      expect(waveform.durationMs, 2000);
    });

    test('different patterns produce different waveforms', () {
      final sineWave = plugin.generateFakeWaveform(
        pattern: WaveformPattern.sine,
        durationMs: 1000,
        samplesPerSecond: 20,
      );

      final squareWave = plugin.generateFakeWaveform(
        pattern: WaveformPattern.square,
        durationMs: 1000,
        samplesPerSecond: 20,
      );

      // Waves should be different
      expect(sineWave.amplitudes, isNot(equals(squareWave.amplitudes)));
    });

    test('music patterns have appropriate characteristics', () {
      final electronicWave = plugin.generateFakeWaveform(
        pattern: WaveformPattern.electronic,
        durationMs: 10000,
        samplesPerSecond: 100,
      );

      final classicalWave = plugin.generateFakeWaveform(
        pattern: WaveformPattern.classical,
        durationMs: 10000,
        samplesPerSecond: 100,
      );

      // Both should have reasonable amplitude ranges for music
      expect(electronicWave.peakAmplitude, greaterThan(0.3));
      expect(classicalWave.peakAmplitude, greaterThan(0.2));
      expect(electronicWave.averageAmplitude, greaterThan(0.1));
      expect(classicalWave.averageAmplitude, greaterThan(0.1));
    });

    test('speech patterns have appropriate characteristics', () {
      final speechWave = plugin.generateFakeWaveform(
        pattern: WaveformPattern.speech,
        durationMs: 5000,
        samplesPerSecond: 100,
      );

      final podcastWave = plugin.generateFakeWaveform(
        pattern: WaveformPattern.podcast,
        durationMs: 5000,
        samplesPerSecond: 100,
      );

      // Speech patterns should have some quiet periods (low amplitudes)
      final lowAmplitudeCount =
          speechWave.amplitudes.where((amp) => amp < 0.1).length;
      expect(
        lowAmplitudeCount,
        greaterThan(0),
        reason: 'Speech should have quiet periods',
      );

      final podcastLowCount =
          podcastWave.amplitudes.where((amp) => amp < 0.1).length;
      expect(
        podcastLowCount,
        greaterThan(0),
        reason: 'Podcast should have brief pauses',
      );
    });

    test('nature sounds have appropriate characteristics', () {
      final oceanWave = plugin.generateFakeWaveform(
        pattern: WaveformPattern.ocean,
        durationMs: 8000,
        samplesPerSecond: 50,
      );

      final rainWave = plugin.generateFakeWaveform(
        pattern: WaveformPattern.rain,
        durationMs: 8000,
        samplesPerSecond: 50,
      );

      // Nature sounds should have continuous activity (no complete silence)
      expect(oceanWave.amplitudes.every((amp) => amp > 0.05), true);
      expect(rainWave.amplitudes.every((amp) => amp > 0.0), true);

      // Should have reasonable average levels
      expect(oceanWave.averageAmplitude, greaterThan(0.2));
      expect(rainWave.averageAmplitude, greaterThan(0.1));
    });

    test('heartbeat pattern has rhythmic characteristics', () {
      final heartbeatWave = plugin.generateFakeWaveform(
        pattern: WaveformPattern.heartbeat,
        durationMs: 10000, // 10 seconds to capture multiple beats
        samplesPerSecond: 100,
      );

      // Should have clear peaks (heartbeats) and quiet periods
      final highAmplitudeCount =
          heartbeatWave.amplitudes.where((amp) => amp > 0.5).length;
      final lowAmplitudeCount =
          heartbeatWave.amplitudes.where((amp) => amp < 0.1).length;

      expect(
        highAmplitudeCount,
        greaterThan(0),
        reason: 'Should have heartbeat peaks',
      );
      expect(
        lowAmplitudeCount,
        greaterThan(0),
        reason: 'Should have quiet periods between beats',
      );
    });

    test('binaural beats pattern is stable', () {
      final binauralWave = plugin.generateFakeWaveform(
        pattern: WaveformPattern.binauralBeats,
        durationMs: 5000,
        samplesPerSecond: 100,
      );

      // Binaural beats should have consistent amplitude range
      expect(binauralWave.peakAmplitude, lessThan(0.8));
      expect(binauralWave.averageAmplitude, greaterThan(0.2));
      expect(binauralWave.averageAmplitude, lessThan(0.6));
    });

    test('waveform style copying works correctly', () {
      final originalWave = plugin.generateFakeWaveform(
        pattern: WaveformPattern.sine,
        durationMs: 1000,
      );

      const newStyle = WaveformColorSchemes.fire;
      final styledWave = originalWave.withStyle(newStyle);

      expect(styledWave.style, equals(newStyle));
      expect(styledWave.amplitudes, equals(originalWave.amplitudes));
      expect(styledWave.durationMs, equals(originalWave.durationMs));
    });
  });
  group('WaveformStyle Tests', () {
    test('predefined color schemes work correctly', () {
      expect(
        WaveformColorSchemes.classic.primaryColor,
        const Color(0xFF2196F3),
      );
      expect(WaveformColorSchemes.fire.useGradient, true);
      expect(WaveformColorSchemes.professional.showGrid, true);
    });

    test('style equality works correctly', () {
      const style1 = WaveformColorSchemes.classic;
      const style2 = WaveformColorSchemes.classic;
      const style3 = WaveformColorSchemes.fire;

      expect(style1, equals(style2));
      expect(style1, isNot(equals(style3)));
    });

    test('style copyWith works correctly', () {
      const original = WaveformColorSchemes.classic;
      final modified = original.copyWith(lineWidth: 5.0);

      expect(modified.lineWidth, 5.0);
      expect(modified.primaryColor, original.primaryColor);
      expect(modified, isNot(equals(original)));
    });
  });

  group('AudioMetadata Tests', () {
    test('metadata creation from map works correctly', () {
      final map = {
        'title': 'Test Song',
        'artist': 'Test Artist',
        'album': 'Test Album',
        'durationMs': 180000,
        'bitrate': 320,
        'sampleRate': 44100,
        'channels': 2,
        'format': 'mp3',
      };

      final metadata = AudioMetadata.fromMap(map);

      expect(metadata.title, 'Test Song');
      expect(metadata.artist, 'Test Artist');
      expect(metadata.durationMs, 180000);
      expect(metadata.durationFormatted, '03:00');
      expect(metadata.channelConfiguration, 'Stereo');
    });

    test('metadata formatted duration works correctly', () {
      final metadata1 = AudioMetadata(durationMs: 65000); // 1:05
      final metadata2 = AudioMetadata(durationMs: 3665000); // 1:01:05

      expect(metadata1.durationFormatted, '01:05');
      expect(metadata2.durationFormatted, '01:01:05');
    });

    test('metadata file size formatting works correctly', () {
      final metadata1 = AudioMetadata(fileSizeBytes: 1024); // 1 KB
      final metadata2 = AudioMetadata(fileSizeBytes: 1048576); // 1 MB
      final metadata3 = AudioMetadata(fileSizeBytes: 1073741824); // 1 GB

      expect(metadata1.fileSizeFormatted, '1.0 KB');
      expect(metadata2.fileSizeFormatted, '1.0 MB');
      expect(metadata3.fileSizeFormatted, '1.0 GB');
    });

    test('metadata to/from map conversion is symmetric', () {
      final original = AudioMetadata(
        title: 'Test',
        artist: 'Artist',
        durationMs: 120000,
        bitrate: 192,
        recordingDate: DateTime(2024, 1, 1),
      );

      final map = original.toMap();
      final restored = AudioMetadata.fromMap(map);

      expect(restored.title, original.title);
      expect(restored.artist, original.artist);
      expect(restored.durationMs, original.durationMs);
      expect(restored.bitrate, original.bitrate);
      expect(restored.recordingDate, original.recordingDate);
    });
  });
}
