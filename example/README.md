# Flutter Audio Toolkit Example

This example app demonstrates how to use the `flutter_audio_toolkit` plugin with comprehensive features including:

- Audio conversion (MP3, WAV, OGG → AAC, M4A)
- Audio trimming with range selection
- Waveform extraction and visualization
- Noise detection and analysis
- Audio player with true and fake waveform displays

## Dependencies

This example app uses additional dependencies to provide a complete demonstration:

```yaml
dependencies:
  flutter_audio_toolkit: ^0.3.3
  audioplayers: ^6.0.0        # For audio playback
  file_picker: ^8.1.6         # For file selection
  path_provider: ^2.1.4       # For temporary file storage
  permission_handler: ^11.3.1 # For audio file permissions
  provider: ^6.1.2            # For state management
```

**Note**: The main `flutter_audio_toolkit` plugin doesn't require these dependencies. They are only used in this example app for demonstration purposes.

## Getting Started

1. Clone the repository
2. Run `flutter pub get` in the example directory
3. Run the app on your device or emulator
4. Grant necessary permissions for file access and audio playback

## Features Demonstrated

- **Audio Conversion**: Convert between different audio formats
- **Audio Trimming**: Trim audio files with precise time range selection
- **Waveform Visualization**: Display real and fake waveforms
- **Noise Analysis**: Detect and analyze background noise
- **Remote Audio**: Handle audio files from URLs
- **File Management**: Pick and manage audio files

For detailed API documentation, see the main [flutter_audio_toolkit documentation](../README.md).
