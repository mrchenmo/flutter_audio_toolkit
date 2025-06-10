import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';

void main() {
  group('Noise Detection Tests', () {
    late FlutterAudioToolkit plugin;

    setUp(() {
      plugin = FlutterAudioToolkit();
    });

    test('analyzes audio for noise detection', () async {
      const inputPath = '/path/to/test/audio.mp3';

      final result = await plugin.analyzeNoise(inputPath: inputPath, segmentDurationMs: 3000);

      expect(result, isA<NoiseDetectionResult>());
      expect(result.overallNoiseLevel, isA<NoiseLevel>());
      expect(result.volumeLevel, isA<VolumeLevel>());
      expect(result.detectedNoises, isA<List<DetectedNoise>>());
      expect(result.qualityMetrics, isA<AudioQualityMetrics>());
      expect(result.frequencyAnalysis, isA<FrequencyAnalysis>());
      expect(result.segments, isA<List<NoiseSegment>>());
      expect(result.confidenceScore, inInclusiveRange(0.0, 1.0));
      expect(result.analyzedDurationMs, greaterThan(0));
    });

    test('analyzes audio from URL for noise detection', () async {
      const url = 'https://example.com/audio.mp3';
      const localPath = '/tmp/downloaded_audio.mp3';

      final result = await plugin.analyzeNoiseFromUrl(url: url, localPath: localPath, segmentDurationMs: 2000);

      expect(result, isA<NoiseDetectionResult>());
      expect(result.segments.isNotEmpty, true);
    });

    test('performs quick noise check', () async {
      const inputPath = '/path/to/test/audio.mp3';

      final result = await plugin.quickNoiseCheck(inputPath: inputPath);

      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('noiseLevel'), true);
      expect(result.containsKey('volumeLevel'), true);
      expect(result.containsKey('peakDbFS'), true);
      expect(result.containsKey('averageDbFS'), true);
      expect(result.containsKey('snrDb'), true);
    });

    test('noise detection result provides summary and recommendations', () async {
      const inputPath = '/path/to/test/audio.mp3';

      final result = await plugin.analyzeNoise(inputPath: inputPath);

      // Test summary generation
      expect(result.summary, isA<String>());
      expect(result.summary.contains('Audio Analysis Summary'), true);

      // Test issues detection
      expect(result.issues, isA<List<String>>());

      // Test recommendations
      expect(result.recommendations, isA<List<String>>());
    });
  });

  group('Detected Noise Tests', () {
    test('creates detected noise with all properties', () {
      const noise = DetectedNoise(
        type: NoiseType.dogBarking,
        confidence: 0.85,
        startTimeMs: 5000,
        endTimeMs: 8000,
        peakAmplitude: 0.7,
        averageAmplitude: 0.4,
        frequencyRange: FrequencyRange(lowHz: 300, highHz: 2000),
      );

      expect(noise.type, NoiseType.dogBarking);
      expect(noise.confidence, 0.85);
      expect(noise.durationMs, 3000);
      expect(noise.durationSeconds, 3.0);
      expect(noise.timeRange, isA<String>());
    });

    test('noise types have correct descriptions and categories', () {
      expect(NoiseType.traffic.description, 'Traffic Noise');
      expect(NoiseType.carHorn.description, 'Car Horn');
      expect(NoiseType.dogBarking.description, 'Dog Barking');
      expect(NoiseType.electricalHum.description, 'Electrical Hum');

      expect(NoiseType.traffic.category, NoiseCategory.environmental);
      expect(NoiseType.dogBarking.category, NoiseCategory.vocal);
      expect(NoiseType.wind.category, NoiseCategory.natural);
      expect(NoiseType.hvac.category, NoiseCategory.mechanical);
    });

    test('noise types have appropriate frequency ranges', () {
      final electricalHumRange = NoiseType.electricalHum.typicalFrequencyRange;
      expect(electricalHumRange.lowHz, 50);
      expect(electricalHumRange.highHz, 180);

      final dogBarkingRange = NoiseType.dogBarking.typicalFrequencyRange;
      expect(dogBarkingRange.lowHz, 300);
      expect(dogBarkingRange.highHz, 2000);
    });
  });

  group('Audio Quality Metrics Tests', () {
    test('creates quality metrics with all properties', () {
      const metrics = AudioQualityMetrics(
        peakDbFS: -6.0,
        averageDbFS: -18.0,
        dynamicRange: 12.0,
        signalToNoiseRatio: 35.0,
        clippingPercentage: 0.05,
        totalHarmonicDistortion: 2.0,
        stereoBalance: 0.1,
        overallScore: 0.8,
        lufs: -14.0,
        crestFactor: 12.0,
        zeroCrossingRate: 0.15,
        spectralCentroid: 1500.0,
        spectralRolloff: 4000.0,
      );

      expect(metrics.peakDbFS, -6.0);
      expect(metrics.dynamicRange, 12.0);
      expect(metrics.grade, AudioQualityGrade.good);
      expect(metrics.loudnessCategory, LoudnessCategory.loud);
      expect(metrics.hasClipping, false); // 0.05% is < 0.1% threshold
      expect(metrics.hasDistortion, false); // 2.0% is < 5.0% threshold
    });

    test('quality grades work correctly', () {
      expect(AudioQualityGrade.excellent.score, 95);
      expect(AudioQualityGrade.good.score, 80);
      expect(AudioQualityGrade.fair.score, 60);
      expect(AudioQualityGrade.poor.score, 40);
      expect(AudioQualityGrade.veryPoor.score, 20);
    });

    test('loudness categories work correctly', () {
      expect(LoudnessCategory.tooLoud.description, 'Too Loud');
      expect(LoudnessCategory.optimal.description, 'Optimal');
      expect(LoudnessCategory.tooQuiet.description, 'Too Quiet');
    });
  });

  group('Frequency Analysis Tests', () {
    test('creates frequency analysis with spectrum data', () {
      final spectrum = [
        const FrequencyBin(frequencyHz: 100, magnitude: 0.5, phase: 1.0),
        const FrequencyBin(frequencyHz: 1000, magnitude: 0.8, phase: 2.0),
        const FrequencyBin(frequencyHz: 5000, magnitude: 0.3, phase: 0.5),
      ];

      var analysis = FrequencyAnalysis(
        spectrum: spectrum,
        dominantFrequency: 1000,
        fundamentalFrequency: 440,
        lowFrequencyEnergy: 25.0,
        midFrequencyEnergy: 60.0,
        highFrequencyEnergy: 15.0,
        spectralFlatness: 0.3,
        spectralSlope: -4.0,
        hasLowFrequencyRumble: false,
        hasHighFrequencyHiss: true,
        problematicBands: const [],
      );

      expect(analysis.spectrum.length, 3);
      expect(analysis.dominantFrequency, 1000);
      expect(analysis.frequencyDistribution, 'Mid-Range Heavy');
      expect(analysis.tonalCharacteristics.contains('High-frequency hiss'), true);
    });

    test('problematic frequency bands work correctly', () {
      const band = ProblematicFrequencyBand(
        range: FrequencyRange(lowHz: 50, highHz: 120),
        problemType: FrequencyProblemType.hum,
        severity: 0.7,
        suggestedAction: 'Apply a 50/60Hz notch filter',
      );

      expect(band.problemType, FrequencyProblemType.hum);
      expect(band.severity, 0.7);
      expect(band.range.bandwidth, 70);
    });
  });

  group('Noise Segment Tests', () {
    test('creates noise segments with analysis data', () {
      const spectralData = SegmentSpectralData(
        dominantFrequency: 800,
        spectralCentroid: 1200,
        spectralBandwidth: 400,
        spectralRolloff: 3000,
        zeroCrossingRate: 0.2,
        mfcc: [0.1, -0.2, 0.3, -0.1, 0.05],
      );

      const segment = NoiseSegment(
        startTimeMs: 10000,
        endTimeMs: 15000,
        noiseLevel: NoiseLevel.medium,
        volumeLevel: VolumeLevel.optimal,
        detectedNoises: [],
        peakAmplitude: 0.6,
        averageAmplitude: 0.3,
        snrDb: 25.0,
        spectralData: spectralData,
      );

      expect(segment.durationMs, 5000);
      expect(segment.durationSeconds, 5.0);
      expect(segment.hasIssues, false); // Medium noise level isn't considered an issue
      expect(segment.qualityScore, greaterThan(0.5));
      expect(segment.timeRange, isA<String>());
    });

    test('segment spectral data calculates perceptual properties', () {
      const spectralData = SegmentSpectralData(
        dominantFrequency: 1000,
        spectralCentroid: 2000,
        spectralBandwidth: 500,
        spectralRolloff: 4000,
        zeroCrossingRate: 0.1, // Low ZCR indicates tonal content
        mfcc: [0.1, -0.2, 0.3],
      );

      expect(spectralData.brightness, 0.5); // 2000/4000
      expect(spectralData.tonality, 0.8); // 1.0 - (0.1/0.5)
    });
  });

  group('Frequency Range Tests', () {
    test('calculates frequency range properties', () {
      const range = FrequencyRange(lowHz: 100, highHz: 1000);

      expect(range.bandwidth, 900);
      expect(range.centerHz, 550);
      expect(range.formatted, '100-1000 Hz');
    });

    test('formats frequency ranges correctly', () {
      const lowRange = FrequencyRange(lowHz: 50, highHz: 200);
      const midRange = FrequencyRange(lowHz: 500, highHz: 2000);
      const highRange = FrequencyRange(lowHz: 2000, highHz: 8000);

      expect(lowRange.formatted, '50-200 Hz');
      expect(midRange.formatted, '500 Hz - 2.0 kHz');
      expect(highRange.formatted, '2.0-8.0 kHz');
    });
  });

  group('Noise Level and Volume Level Tests', () {
    test('noise levels have correct descriptions and scores', () {
      expect(NoiseLevel.veryLow.description, 'Very Clean');
      expect(NoiseLevel.low.description, 'Clean');
      expect(NoiseLevel.medium.description, 'Moderate Noise');
      expect(NoiseLevel.high.description, 'High Noise');
      expect(NoiseLevel.veryHigh.description, 'Very High Noise');

      expect(NoiseLevel.veryLow.score, 95);
      expect(NoiseLevel.low.score, 80);
      expect(NoiseLevel.medium.score, 60);
      expect(NoiseLevel.high.score, 35);
      expect(NoiseLevel.veryHigh.score, 10);
    });

    test('volume levels have correct descriptions', () {
      expect(VolumeLevel.tooQuiet.description, 'Too Quiet');
      expect(VolumeLevel.optimal.description, 'Optimal');
      expect(VolumeLevel.loud.description, 'Loud');
      expect(VolumeLevel.tooLoud.description, 'Too Loud');
    });
  });

  group('Serialization Tests', () {
    test('noise detection result serializes correctly', () async {
      const inputPath = '/path/to/test/audio.mp3';
      final originalResult = await FlutterAudioToolkit().analyzeNoise(inputPath: inputPath);

      final map = originalResult.toMap();
      final restoredResult = NoiseDetectionResult.fromMap(map);

      expect(restoredResult.overallNoiseLevel, originalResult.overallNoiseLevel);
      expect(restoredResult.volumeLevel, originalResult.volumeLevel);
      expect(restoredResult.confidenceScore, originalResult.confidenceScore);
      expect(restoredResult.analyzedDurationMs, originalResult.analyzedDurationMs);
    });

    test('detected noise serializes correctly', () {
      const originalNoise = DetectedNoise(
        type: NoiseType.traffic,
        confidence: 0.75,
        startTimeMs: 1000,
        endTimeMs: 3000,
        peakAmplitude: 0.8,
        averageAmplitude: 0.5,
        frequencyRange: FrequencyRange(lowHz: 80, highHz: 800),
      );

      final map = originalNoise.toMap();
      final restoredNoise = DetectedNoise.fromMap(map);

      expect(restoredNoise.type, originalNoise.type);
      expect(restoredNoise.confidence, originalNoise.confidence);
      expect(restoredNoise.startTimeMs, originalNoise.startTimeMs);
      expect(restoredNoise.endTimeMs, originalNoise.endTimeMs);
    });
  });
}
