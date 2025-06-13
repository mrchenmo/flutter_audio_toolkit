import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';

/// Custom painter for rendering waveform visualizations
class WaveformPainter extends CustomPainter {
  final WaveformData? waveformData;
  final double progress;
  final Color primaryColor;
  final Color playedColor;
  final Color positionIndicatorColor;

  WaveformPainter({
    this.waveformData,
    required this.progress,
    required this.primaryColor,
    required this.playedColor,
    required this.positionIndicatorColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData == null || waveformData!.amplitudes.isEmpty) {
      // Draw placeholder waveform
      _drawPlaceholderWaveform(canvas, size);
      return;
    }

    final paint = Paint()..strokeWidth = 1.5;
    final amplitudes = waveformData!.amplitudes;
    final width = size.width;
    final height = size.height;
    final centerY = height / 2;

    final playedWidth = width * progress.clamp(0.0, 1.0);

    for (int i = 0; i < amplitudes.length; i++) {
      final x = (i / amplitudes.length) * width;
      final amplitude = amplitudes[i].clamp(0.0, 1.0);
      final barHeight = (amplitude * height * 0.8).clamp(2.0, height * 0.8);

      // Determine color based on progress
      paint.color = x <= playedWidth ? playedColor : primaryColor;

      // Draw waveform bar
      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }

    // Draw position indicator
    final indicatorX = playedWidth;
    paint.color = positionIndicatorColor;
    paint.strokeWidth = 3;
    canvas.drawLine(Offset(indicatorX, 0), Offset(indicatorX, height), paint);
  }

  void _drawPlaceholderWaveform(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = primaryColor
          ..strokeWidth = 1.5;

    final width = size.width;
    final height = size.height;
    final centerY = height / 2;
    final playedWidth = width * progress.clamp(0.0, 1.0);

    // Generate simple placeholder bars
    for (double x = 0; x < width; x += 3) {
      final normalizedX = x / width;
      final barHeight = (20 + 30 * (0.5 + 0.5 * math.sin(normalizedX * 10)))
          .clamp(5.0, height * 0.8);

      paint.color = x <= playedWidth ? playedColor : primaryColor;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }

    // Draw position indicator
    paint.color = positionIndicatorColor;
    paint.strokeWidth = 3;
    canvas.drawLine(Offset(playedWidth, 0), Offset(playedWidth, height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
