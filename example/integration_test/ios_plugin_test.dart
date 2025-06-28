import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';

void main() {
  group('Flutter Audio Toolkit iOS Integration Tests', () {
    late FlutterAudioToolkit audioToolkit;

    setUpAll(() {
      audioToolkit = FlutterAudioToolkit();
    });

    testWidgets('Platform version returns iOS version', (
      WidgetTester tester,
    ) async {
      try {
        final version = await audioToolkit.getPlatformVersion();
        expect(version, contains('iOS'));
        //'✅ Platform version: $version');
      } on PlatformException {
        //❌ Platform version test failed: ${e.message}');
        rethrow;
      }
    });

    testWidgets('Format support detection works', (WidgetTester tester) async {
      try {
        // Test with dummy paths (file existence not required for format detection)
        final mp3Supported = await audioToolkit.isFormatSupported(
          '/test/audio.mp3',
        );
        final mp4Supported = await audioToolkit.isFormatSupported(
          '/test/video.mp4',
        );
        final unknownSupported = await audioToolkit.isFormatSupported(
          '/test/file.xyz',
        );

        expect(mp3Supported, isTrue);
        expect(mp4Supported, isFalse);
        expect(unknownSupported, isFalse);

        //'✅ Format support detection working correctly');
      } on PlatformException {
        //'❌ Format support test failed: ${e.message}');
        rethrow;
      }
    });

    testWidgets('Audio info with non-existent file returns error', (
      WidgetTester tester,
    ) async {
      try {
        final audioInfo = await audioToolkit.getAudioInfo(
          '/non/existent/file.mp3',
        );

        expect(audioInfo['isValid'], isFalse);
        expect(audioInfo['error'], isNotNull);

        //'✅ Audio info error handling working correctly');
        //'   Error: ${audioInfo['error']}');
      } on PlatformException {
        //'❌ Audio info test failed: ${e.message}');
        rethrow;
      }
    });

    testWidgets('Convert audio with invalid arguments returns error', (
      WidgetTester tester,
    ) async {
      try {
        await audioToolkit.convertAudio(
          inputPath: '',
          outputPath: '',
          format: AudioFormat.aac,
        );
        fail('Should have thrown an exception');
      } on PlatformException catch (e) {
        expect(e.code, 'INVALID_ARGUMENTS');
        //'✅ Convert audio argument validation working correctly');
        //'   Error: ${e.message}');
      }
    });

    testWidgets('Trim audio with invalid range returns error', (
      WidgetTester tester,
    ) async {
      try {
        await audioToolkit.trimAudio(
          inputPath: '/test/audio.mp3',
          outputPath: '/test/trimmed.m4a',
          startTimeMs: 5000, // Start after end
          endTimeMs: 2000, // End before start
          format: AudioFormat.m4a,
        );
        fail('Should have thrown an exception');
      } on PlatformException catch (e) {
        expect(e.code, 'INVALID_RANGE');
        //'   Error: ${e.message}');
      }
    });

    testWidgets('Extract waveform with invalid path returns error', (
      WidgetTester tester,
    ) async {
      try {
        await audioToolkit.extractWaveform(
          inputPath: '',
          samplesPerSecond: 100,
        );
        fail('Should have thrown an exception');
      } on PlatformException catch (e) {
        expect(e.code, 'INVALID_ARGUMENTS');
        //'   Error: ${e.message}');
      }
    });
  });
}
