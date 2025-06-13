import 'dart:io';
import 'package:flutter/foundation.dart';
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
    debugPrint('NetworkService: Downloading file from URL: $url');
    debugPrint('NetworkService: Output path: $outputPath');

    // Check if this is an MP4 file (which may need special handling)
    final isMP4 = url.toLowerCase().endsWith('.mp4');
    if (isMP4) {
      debugPrint(
        'NetworkService: Detected MP4 file, which may contain video+audio. Only audio will be processed.',
      );
    }

    try {
      final uri = Uri.parse(url);
      final request = http.Request('GET', uri);

      // Add user agent to avoid being blocked by some servers
      request.headers['User-Agent'] = 'Flutter_Audio_Toolkit/1.0';

      debugPrint('NetworkService: Sending request...');
      final response = await request.send();
      debugPrint(
        'NetworkService: Response status code: ${response.statusCode}',
      );

      // Log response headers for debugging
      final headers = response.headers;
      debugPrint(
        'NetworkService: Response content-type: ${headers['content-type']}',
      );
      debugPrint(
        'NetworkService: Response content-length: ${headers['content-length']}',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to download file: HTTP ${response.statusCode}');
      }

      // Create directory if it doesn't exist
      final file = File(outputPath);
      final dir = file.parent;
      debugPrint('NetworkService: Creating directory: ${dir.path}');
      await dir.create(recursive: true);

      final sink = file.openWrite();
      int downloadedBytes = 0;
      final totalBytes = response.contentLength ?? 0;
      debugPrint('NetworkService: Total bytes to download: $totalBytes');

      await response.stream
          .listen(
            (List<int> chunk) {
              sink.add(chunk);
              downloadedBytes += chunk.length;

              // Log progress periodically
              if (downloadedBytes % 50000 < chunk.length) {
                // Log every ~50KB
                debugPrint(
                  'NetworkService: Downloaded $downloadedBytes / $totalBytes bytes',
                );
              }

              if (totalBytes > 0 && onProgress != null) {
                final progress = downloadedBytes / totalBytes;
                onProgress(progress.clamp(0.0, 1.0));
              }
            },
            onDone: () async {
              await sink.close();
              onProgress?.call(1.0);
              final fileSize = await file.length();
              debugPrint(
                'NetworkService: Download completed. File size: $fileSize bytes',
              );
            },
            onError: (error, stackTrace) async {
              debugPrint('NetworkService: Error during download: $error');
              debugPrint('NetworkService: Stack trace: $stackTrace');
              await sink.close();
              throw error;
            },
          )
          .asFuture();
    } catch (e, stackTrace) {
      debugPrint('NetworkService: Exception during download: $e');
      debugPrint('NetworkService: Stack trace: $stackTrace');
      rethrow;
    }
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
