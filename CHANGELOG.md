# Changelog

## [0.2.0] - 2025-06-08

### Added
- **Multi-Platform Support**: Added support for macOS, Linux, and Windows platforms
- **macOS Implementation**: Full native implementation using AVFoundation (same as iOS)
- **Linux & Windows**: Basic plugin structure with platform-specific error handling
- **Platform Documentation**: Updated README with comprehensive platform support matrix
- **Desktop Compatibility**: Plugin now declares support for all desktop platforms

### Enhanced
- Updated platform support matrix in README
- Added platform-specific implementation notes
- Improved plugin architecture for cross-platform compatibility

### Technical Details
- macOS: Complete AVFoundation implementation for audio conversion, trimming, and waveform extraction
- Linux: GTK-based plugin structure (requires FFmpeg/GStreamer for full functionality)
- Windows: Win32 plugin structure (requires Media Foundation/FFmpeg for full functionality)

### Notes
- Desktop platforms (Linux, Windows) have basic plugin structure but require additional audio processing libraries
- macOS has full feature parity with iOS using the same AVFoundation APIs

## [0.1.0] - 2025-06-07

### Added
- **Fake Waveform Generation**: Generate realistic waveform patterns for testing and previews
- **7 Waveform Patterns**: Sine, Random, Music, Speech, Pulse, Fade, and Burst patterns
- **Network URL Support**: Process audio files from network URLs with fake waveform generation
- **Modular Architecture**: Complete refactoring of example app with Provider state management
- **Enhanced Example App**: Added fake waveform UI with pattern selection and color-coded display
- Pattern-specific amplitude algorithms for realistic waveform simulation
- URL validation and network audio file support
- Comprehensive testing for fake waveform functionality

### Enhanced
- Example app refactored from 1180 lines to 122 lines (89% reduction)
- Added Provider state management pattern
- Extracted business logic into service classes
- Modularized UI components into reusable widgets
- Improved error handling and progress tracking

### Fixed
- Library formatting and method signature issues
- Enhanced dependency management

## [0.0.1] - 2025-06-07

### Added
- Initial release of flutter_audio_toolkit plugin
- Audio conversion from MP3, WAV, OGG to AAC/M4A formats
- Audio trimming with precise time range selection
- Waveform data extraction for visualization
- Native implementations for Android (MediaCodec/MediaMuxer) and iOS (AVFoundation)
- Progress tracking for all operations
- Audio file information retrieval
- Comprehensive example app with UI for all features
- Full test coverage including unit and widget tests
- Platform-specific permission handling
- Error handling and validation
- Performance optimized for large audio files

### Platform Support
- Android: API 21+ using MediaCodec, MediaMuxer, MediaExtractor
- iOS: 12.0+ using AVAssetExportSession, AVAudioConverter, AVAssetReader

### Features
- Convert audio files between formats
- Trim audio files to specific time ranges  
- Extract waveform amplitude data
- Get detailed audio file information
- Real-time progress callbacks
- Native performance optimization
