import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Handles network operations for downloading audio files
class NetworkService {
  /// Downloads a file from URL with progress tracking
  ///
  /// [url] - URL of the file to download
  /// [outputPath] - Local path where the downloaded file will be saved
  /// [onProgress] - Optional callback for download progress (0.0 to 1.0)
  ///
  /// Throws [Exception] if download fails
  static Future<void> downloadFile(
    String url,
    String outputPath, {
    ProgressCallback? onProgress,
  }) async {
    final uri = Uri.parse(url);
    final request = http.Request('GET', uri);
    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to download file: HTTP ${response.statusCode}');
    }

    final file = File(outputPath);
    await file.parent.create(recursive: true);

    final sink = file.openWrite();
    int downloadedBytes = 0;
    final totalBytes = response.contentLength ?? 0;

    await response.stream
        .listen(
          (List<int> chunk) {
            sink.add(chunk);
            downloadedBytes += chunk.length;

            if (totalBytes > 0 && onProgress != null) {
              final progress = downloadedBytes / totalBytes;
              onProgress(progress.clamp(0.0, 1.0));
            }
          },
          onDone: () async {
            await sink.close();
            onProgress?.call(1.0);
          },
          onError: (error) async {
            await sink.close();
            throw error;
          },
        )
        .asFuture();
  }

  /// Validates if a URL is properly formatted
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Extracts filename from URL
  static String? getFilenameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return segments.last;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Checks if the file at the given path exists and is not empty
  static Future<bool> isValidLocalFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      final stat = await file.stat();
      return stat.size > 0;
    } catch (e) {
      return false;
    }
  }

  /// Cleans up temporary file if it exists
  static Future<void> cleanupFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }
}
