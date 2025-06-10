# Flutter Audio Toolkit

A comprehensive Flutter plugin for native audio processing that provides conversion, trimming, and waveform extraction capabilities using platform-specific APIs. Perfect for audio editing apps, music players, and audio visualization tools.

## 🚀 Features

- **🔄 Audio Conversion**: Convert audio files between formats (MP3, WAV, OGG → AAC, M4A)
- **✂️ Audio Trimming**: Precise audio trimming with lossless and lossy options
- **📊 Waveform Extraction**: Extract amplitude data for visual waveform displays
- **🎨 Enhanced Waveform Generation**: 25+ realistic waveform patterns with visual styling
- **🔊 Noise Detection & Analysis**: Comprehensive audio quality analysis and noise identification
- **📈 Audio Quality Metrics**: Peak levels, SNR, dynamic range, frequency analysis
- **🎵 Background Noise Identification**: Detect car horns, dog barking, music, speech, and more
- **🌐 Network Audio Processing**: Download and process audio files from URLs
- **📋 Audio Analysis**: Comprehensive audio file information and metadata
- **⚡ Native Performance**: Uses platform-optimized native libraries (MediaCodec, AVFoundation)
- **📈 Progress Tracking**: Real-time progress callbacks for all operations
- **🔍 Format Detection**: Automatic audio format detection and compatibility checking
- **💾 Lossless Processing**: Support for lossless audio trimming without re-encoding

## 📱 Platform Support

| Platform | Audio Conversion | Audio Trimming | Waveform Extraction | Lossless Processing | Implementation |
|----------|-----------------|----------------|-------------------|-------------------|----------------|
| Android  | ✅ | ✅ | ✅ | ✅ | MediaCodec, MediaMuxer, MediaExtractor |
| iOS      | ✅ | ✅ | ✅ | ✅ | AVAudioConverter, AVAssetExportSession, AVAssetReader |
| macOS    | ✅ | ✅ | ✅ | ✅ | AVFoundation (same as iOS) |
| Linux    | ⚠️ | ⚠️ | ⚠️ | ⚠️ | Limited support (requires FFmpeg/GStreamer) |
| Windows  | ⚠️ | ⚠️ | ⚠️ | ⚠️ | Limited support (requires Media Foundation/FFmpeg) |

> **Note**: Desktop platforms (Linux, Windows) have basic plugin structure but require additional audio processing libraries like FFmpeg or platform-specific APIs for full functionality. macOS has full support using AVFoundation.

### Supported Audio Formats

**Input Formats**: MP3, M4A, AAC, WAV, OGG  
**Output Formats**: AAC, M4A, Original (for lossless trimming)

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_audio_toolkit: ^0.3.0
```

## 📖 Usage

### Basic Setup

```dart
import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';

class AudioProcessor {
  final audioToolkit = FlutterAudioToolkit();
  
  Future<void> processAudio() async {
    // Your audio processing code here
  }
}
```

### 🔍 Audio Information & Analysis

Get comprehensive information about audio files including format details, compatibility, and metadata:

```dart
// Get detailed audio file information
final audioInfo = await audioToolkit.getAudioInfo('/path/to/audio.mp3');

// Access audio properties
print('Format: ${audioInfo['mime']}');                    // e.g., "audio/mpeg"
print('Duration: ${audioInfo['durationMs']}ms');          // Duration in milliseconds
print('Sample Rate: ${audioInfo['sampleRate']}Hz');       // e.g., 44100
print('Channels: ${audioInfo['channels']}');              // e.g., 2 (stereo)
print('Bit Rate: ${audioInfo['bitRate']}bps');           // Bit rate in bits per second
print('File Size: ${audioInfo['fileSize']}bytes');        // File size in bytes

// Feature compatibility checking
print('Conversion Support: ${audioInfo['supportedForConversion']}');      // true/false
print('Trimming Support: ${audioInfo['supportedForTrimming']}');          // true/false
print('Lossless Trimming: ${audioInfo['supportedForLosslessTrimming']}'); // true/false
print('Waveform Support: ${audioInfo['supportedForWaveform']}');          // true/false

// Format diagnostics
print('Format Details: ${audioInfo['formatDiagnostics']}');  // Human-readable format info
print('Found Tracks: ${audioInfo['foundTracks']}');          // List of detected tracks

// Validation status
if (audioInfo['isValid'] == true) {
  print('✅ Audio file is valid and ready for processing');
} else {
  print('❌ Error: ${audioInfo['error']}');
  print('Details: ${audioInfo['details']}');
}
```

### 🔄 Audio Conversion

Convert audio files between different formats with customizable quality settings:

```dart
// Convert MP3 to AAC with custom settings
final result = await audioToolkit.convertAudio(
  inputPath: '/path/to/input.mp3',
  outputPath: '/path/to/output.aac',
  format: AudioFormat.aac,
  bitRate: 128,      // Quality: 128kbps
  sampleRate: 44100, // Standard sample rate
  onProgress: (progress) {
    print('Conversion progress: ${(progress * 100).toStringAsFixed(1)}%');
  },
);

print('✅ Converted to: ${result.outputPath}');
print('Duration: ${result.durationMs}ms');
print('Bit Rate: ${result.bitRate}bps');
print('Sample Rate: ${result.sampleRate}Hz');
```

### ✂️ Audio Trimming

Trim audio files with precision, supporting both lossless and lossy processing:

```dart
// Lossless trimming (preserves original quality)
final losslessResult = await audioToolkit.trimAudio(
  inputPath: '/path/to/input.m4a',
  outputPath: '/path/to/trimmed.m4a',
  startTimeMs: 10000,  // Start at 10 seconds
  endTimeMs: 30000,    // End at 30 seconds
  format: AudioFormat.copy, // Lossless copy
  onProgress: (progress) {
    print('Trimming progress: ${(progress * 100).toStringAsFixed(1)}%');
  },
);

// Lossy trimming with format conversion
final lossyResult = await audioToolkit.trimAudio(
  inputPath: '/path/to/input.mp3',
  outputPath: '/path/to/trimmed.aac',
  startTimeMs: 5000,   // Start at 5 seconds
  endTimeMs: 25000,    // End at 25 seconds
  format: AudioFormat.aac,
  bitRate: 192,        // Higher quality
  sampleRate: 48000,   // Higher sample rate
  onProgress: (progress) {
    print('Converting and trimming: ${(progress * 100).toStringAsFixed(1)}%');
  },
);
```

### 📊 Waveform Extraction

Extract waveform data for audio visualization and analysis:

```dart
// Extract waveform data
final waveformData = await audioToolkit.extractWaveform(
  inputPath: '/path/to/audio.mp3',
  samplesPerSecond: 100, // Resolution: 100 samples per second
  onProgress: (progress) {
    print('Extraction progress: ${(progress * 100).toStringAsFixed(1)}%');
  },
);

// Use waveform data for visualization
print('Samples: ${waveformData.amplitudes.length}');
print('Duration: ${waveformData.durationMs}ms');
print('Sample Rate: ${waveformData.sampleRate}Hz');
print('Channels: ${waveformData.channels}');

// Amplitude values are normalized (0.0 to 1.0)
for (int i = 0; i < waveformData.amplitudes.length; i++) {
  final amplitude = waveformData.amplitudes[i];
  final timeMs = (i / waveformData.samplesPerSecond) * 1000;
  print('Time: ${timeMs.toStringAsFixed(1)}ms, Amplitude: ${amplitude.toStringAsFixed(3)}');
}
```

### 🎨 Fake Waveform Generation

Generate realistic-looking fake waveform data for testing, previews, or when you need to display waveforms without the overhead of processing actual audio files:

```dart
// Generate different waveform patterns
final musicWaveform = audioToolkit.generateFakeWaveform(
  pattern: WaveformPattern.music,
  durationMs: 30000,        // 30 seconds
  samplesPerSecond: 100,    // 100 samples per second
  frequency: 440.0,         // Base frequency in Hz
);

final speechWaveform = audioToolkit.generateFakeWaveform(
  pattern: WaveformPattern.speech,
  durationMs: 15000,        // 15 seconds
  samplesPerSecond: 120,    // Higher resolution
);

// Available patterns
enum WaveformPattern {
  sine,    // Smooth sine wave pattern
  random,  // Random amplitude values
  music,   // Music-like with beats and dynamics
  speech,  // Speech-like with pauses and variations
  pulse,   // Rhythmic pulse/beat pattern
  fade,    // Gradual fade in/out
  burst,   // Sudden bursts with quiet periods
}
```

### 🌐 Network Audio Processing

Process audio files directly from network URLs:

```dart
// Extract real waveform from network audio file
final networkWaveform = await audioToolkit.extractWaveformFromUrl(
  url: 'https://example.com/audio.mp3',
  localPath: '/tmp/downloaded_audio.mp3',
  samplesPerSecond: 100,
  onDownloadProgress: (progress) {
    print('Download: ${(progress * 100).toStringAsFixed(1)}%');
  },
  onExtractionProgress: (progress) {
    print('Extraction: ${(progress * 100).toStringAsFixed(1)}%');
  },
);

// Generate consistent fake waveform for a URL (useful for previews)
final fakeUrlWaveform = audioToolkit.generateFakeWaveformForUrl(
  url: 'https://example.com/audio.mp3',
  pattern: WaveformPattern.music,  estimatedDurationMs: 180000, // 3 minutes estimated
  samplesPerSecond: 100,
);
```

### 🔊 Noise Detection & Audio Quality Analysis

**New in v0.3.0!** Comprehensive noise detection and audio quality analysis to identify background noises, audio issues, and provide detailed quality metrics:

```dart
// Analyze audio for noise and quality metrics
final analysisResult = await audioToolkit.analyzeAudioNoise(
  inputPath: '/path/to/audio.mp3',
  onProgress: (progress) {
    print('Analysis progress: ${(progress * 100).toStringAsFixed(1)}%');
  },
);

// Access quality metrics
final quality = analysisResult.qualityMetrics;
if (quality != null) {
  print('Quality Grade: ${quality.grade.description}');     // Excellent, Good, Fair, Poor, Very Poor
  print('Peak Level: ${quality.peakLevelFormatted}');       // e.g., "-3.2 dBFS"
  print('Average Level: ${quality.averageLevelFormatted}'); // e.g., "-18.5 dBFS"
  print('SNR: ${quality.snrFormatted}');                    // Signal-to-noise ratio
  print('Loudness: ${quality.lufsFormatted}');              // LUFS measurement
  print('Dynamic Range: ${quality.dynamicRange.toStringAsFixed(1)} dB');
  print('Overall Score: ${(quality.overallScore * 100).toStringAsFixed(1)}%');
  
  // Check for specific issues
  if (quality.hasClipping) print('⚠️ Audio clipping detected');
  if (quality.hasDistortion) print('⚠️ Distortion present');
  if (quality.hasBalanceIssues) print('⚠️ Stereo balance issues');
}

// Check detected background noises
for (final noise in analysisResult.detectedNoises) {
  print('🔊 Detected: ${noise.type.displayName}');
  print('   Confidence: ${(noise.confidence * 100).toStringAsFixed(1)}%');
  print('   Description: ${noise.description}');
  
  // Time segments where noise was found
  for (final segment in noise.timeSegments) {
    print('   Found at: ${segment.startTimeFormatted} - ${segment.endTimeFormatted}');
    print('   Intensity: ${(segment.intensity * 100).toStringAsFixed(1)}%');
  }
}

// Frequency analysis
final freqAnalysis = analysisResult.frequencyAnalysis;
if (freqAnalysis != null) {
  print('🎵 Frequency Distribution: ${freqAnalysis.frequencyDistribution}');
  print('🎵 Dominant Frequency: ${freqAnalysis.dominantFrequency.toStringAsFixed(1)} Hz');
  print('🎵 Tonal Characteristics: ${freqAnalysis.tonalCharacteristics.join(', ')}');
}
```

#### Supported Noise Types

The noise detection system can identify 15+ different types of background noise:

| Noise Type | Description | Common Sources |
|------------|-------------|----------------|
| **Traffic** | Vehicle sounds, road noise | Cars, trucks, motorcycles |
| **Construction** | Building/demolition sounds | Hammering, drilling, machinery |
| **Nature** | Natural environmental sounds | Wind, rain, thunder |
| **Animals** | Animal vocalizations | Dogs barking, cats, birds |
| **Music** | Background musical content | Radio, speakers, instruments |
| **Speech** | Human conversation | Talking, crowd chatter |
| **Machinery** | Mechanical/electrical noise | Fans, AC units, appliances |
| **Electronic** | Digital/electrical interference | Hum, buzz, static |
| **Wind** | Wind noise on microphone | Outdoor recording issues |
| **Aircraft** | Airplane/helicopter sounds | Aviation noise |
| **Emergency** | Sirens and alarms | Police, fire, ambulance |
| **Urban** | General city noise | Traffic, crowds, activity |
| **Household** | Domestic sounds | TV, appliances, movement |
| **Industrial** | Factory/workshop noise | Heavy machinery, tools |
| **Water** | Water-related sounds | Rain, streams, dripping |

```dart
// Analyze network audio file
final networkAnalysis = await audioToolkit.analyzeAudioNoiseFromUrl(
  url: 'https://example.com/audio.mp3',
  localPath: '/tmp/analysis_audio.mp3',
  onProgress: (progress) {
    print('Download & Analysis: ${(progress * 100).toStringAsFixed(1)}%');
  },
);
```

### 🎨 Enhanced Waveform Generation

**Enhanced in v0.3.0!** Generate 25+ realistic waveform patterns with visual styling options:

```dart
// Generate waveforms with automatic styling
final themedWaveform = audioToolkit.generateThemedWaveform(
  pattern: WaveformPattern.jazz,
  durationMs: 30000,
);

// Generate waveforms with custom styling
final styledWaveform = audioToolkit.generateStyledWaveform(
  pattern: WaveformPattern.electronic,
  style: WaveformColorSchemes.neon,
  durationMs: 25000,
);

// Apply styling to existing waveform
final waveformWithStyle = existingWaveform.withStyle(WaveformColorSchemes.fire);
```

#### Available Waveform Patterns

**Basic Waveforms**: `sine`, `square`, `sawtooth`, `triangle`, `random`, `pulse`, `fade`, `burst`

**Musical Patterns**: `music`, `electronic`, `classical`, `rock`, `jazz`, `ambient`

**Voice & Speech**: `speech`, `podcast`, `audiobook`

**Nature & Relaxation**: `whiteNoise`, `pinkNoise`, `heartbeat`, `ocean`, `rain`, `binauralBeats`

#### Predefined Color Schemes

- `WaveformColorSchemes.classic` - Classic blue waveform
- `WaveformColorSchemes.fire` - Fire/heat color scheme
- `WaveformColorSchemes.ocean` - Ocean/water colors
- `WaveformColorSchemes.forest` - Forest/nature colors
- `WaveformColorSchemes.neon` - Neon/cyberpunk style
- `WaveformColorSchemes.monochrome` - Grayscale
- `WaveformColorSchemes.sunset` - Sunset colors
- `WaveformColorSchemes.professional` - Professional/business
- `WaveformColorSchemes.visualizer` - Music visualizer style

### 🔍 Format Validation

Check format compatibility before processing:

```dart
// Check if file format is supported
final isSupported = await audioToolkit.isFormatSupported('/path/to/audio.unknown');

if (isSupported) {
  print('✅ Format is supported for processing');
  // Proceed with conversion/trimming/extraction
} else {
  print('❌ Unsupported format. Please use MP3, M4A, AAC, WAV, or OGG files');
}
```

## 📚 API Reference

### FlutterAudioToolkit

Main class providing audio conversion, trimming, and waveform extraction capabilities.

#### Methods

##### `getAudioInfo(String inputPath)`
Analyzes an audio file and returns comprehensive information about its properties and compatibility.

```dart
Future<Map<String, dynamic>> getAudioInfo(String inputPath)
```

**Returns**: A `Map<String, dynamic>` containing:

| Key | Type | Description |
|-----|------|-------------|
| `isValid` | `bool` | Whether the file is valid and processable |
| `mime` | `String` | MIME type (e.g., "audio/mpeg", "audio/mp4") |
| `durationMs` | `int` | Duration in milliseconds |
| `sampleRate` | `int` | Sample rate in Hz (e.g., 44100) |
| `channels` | `int` | Number of audio channels (1=mono, 2=stereo) |
| `bitRate` | `int` | Bit rate in bits per second |
| `fileSize` | `int` | File size in bytes |
| `supportedForConversion` | `bool` | Can be used for format conversion |
| `supportedForTrimming` | `bool` | Can be trimmed/edited |
| `supportedForLosslessTrimming` | `bool` | Supports lossless trimming |
| `supportedForWaveform` | `bool` | Can extract waveform data |
| `formatDiagnostics` | `String` | Human-readable format details |
| `foundTracks` | `List<String>` | List of detected audio tracks |
| `error` | `String?` | Error message if `isValid` is false |
| `details` | `String?` | Additional error details |

##### `convertAudio()`
Converts an audio file to a different format.

```dart
Future<ConversionResult> convertAudio({
  required String inputPath,
  required String outputPath,
  required AudioFormat format,
  int bitRate = 128,
  int sampleRate = 44100,
  ProgressCallback? onProgress,
})
```

**Parameters**:
- `inputPath`: Source audio file path (MP3, WAV, OGG, M4A, AAC)
- `outputPath`: Destination file path
- `format`: Target format (`AudioFormat.aac` or `AudioFormat.m4a`)
- `bitRate`: Quality in kbps (32-320, default: 128)
- `sampleRate`: Sample rate in Hz (8000-192000, default: 44100)
- `onProgress`: Optional progress callback (0.0-1.0)

##### `trimAudio()`
Trims an audio file to a specific time range with optional format conversion.

```dart
Future<ConversionResult> trimAudio({
  required String inputPath,
  required String outputPath,
  required int startTimeMs,
  required int endTimeMs,
  required AudioFormat format,
  int bitRate = 128,
  int sampleRate = 44100,
  ProgressCallback? onProgress,
})
```

**Parameters**:
- `inputPath`: Source audio file path
- `outputPath`: Destination file path
- `startTimeMs`: Start time in milliseconds
- `endTimeMs`: End time in milliseconds
- `format`: Output format (`AudioFormat.aac`, `AudioFormat.m4a`, or `AudioFormat.copy` for lossless)
- `bitRate`: Quality for lossy formats (ignored for lossless)
- `sampleRate`: Sample rate for lossy formats (ignored for lossless)
- `onProgress`: Optional progress callback (0.0-1.0)

##### `extractWaveform()`
Extracts amplitude data from an audio file for waveform visualization.

```dart
Future<WaveformData> extractWaveform({
  required String inputPath,
  int samplesPerSecond = 100,
  ProgressCallback? onProgress,
})
```

**Parameters**:
- `inputPath`: Source audio file path
- `samplesPerSecond`: Resolution (1-1000, default: 100)
- `onProgress`: Optional progress callback (0.0-1.0)

##### `isFormatSupported(String inputPath)`
Checks if an audio file format is supported for processing.

```dart
Future<bool> isFormatSupported(String inputPath)
```

### Data Classes

#### AudioFormat
Enum representing supported audio formats:

```dart
enum AudioFormat {
  aac,  // Advanced Audio Coding (lossy)
  m4a,  // MPEG-4 Audio (lossy)
  copy, // Keep original format (lossless)
}
```

#### ConversionResult
Result object returned by conversion and trimming operations:

```dart
class ConversionResult {
  final String outputPath;   // Path to the output file
  final int durationMs;      // Duration in milliseconds
  final int bitRate;         // Bit rate in bps
  final int sampleRate;      // Sample rate in Hz
}
```

#### WaveformData
Result object returned by waveform extraction:

```dart
class WaveformData {
  final List<double> amplitudes;  // Normalized amplitude values (0.0-1.0)
  final int sampleRate;           // Sample rate in Hz
  final int durationMs;           // Duration in milliseconds
  final int channels;             // Number of audio channels
}
```

#### ProgressCallback
Callback function for tracking operation progress:

```dart
typedef ProgressCallback = void Function(double progress);
```
Progress values range from 0.0 (0%) to 1.0 (100%).

## Error Handling

The plugin throws platform-specific exceptions for various error conditions:

- **INVALID_ARGUMENTS**: Missing or invalid method arguments
- **INVALID_RANGE**: Invalid time range for trimming operations
- **CONVERSION_ERROR**: Audio conversion failed
- **TRIM_ERROR**: Audio trimming failed  
- **WAVEFORM_ERROR**: Waveform extraction failed
- **INFO_ERROR**: Unable to read audio file information

## Performance Considerations

- **Large Files**: For very large audio files, consider processing in chunks or showing progress indicators
- **Memory Usage**: Waveform extraction loads audio data into memory - adjust `samplesPerSecond` for large files
- **Background Processing**: All operations run on background threads to avoid blocking the UI
- **Native Performance**: Uses platform-optimized native libraries for best performance

## Permissions

### Android
Add these permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
```

### iOS  
Add these keys to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone for audio processing</string>
<key>NSDocumentsFolderUsageDescription</key>
<string>This app needs access to documents folder for audio file processing</string>
```

## Limitations

- **Input Formats**: Supports MP3, WAV, OGG input files
- **Output Formats**: Currently supports AAC and M4A output only
- **Platform Versions**: Requires iOS 12.0+ and Android API 21+
- **File Size**: Very large files (>100MB) may require additional memory optimization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Ensure all tests pass: `flutter test`
5. Run analyzer: `flutter analyze`
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

