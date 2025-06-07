import 'package:flutter/material.dart';

/// Custom painter for rendering waveform amplitudes as bars
class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color color;

  WaveformPainter(this.amplitudes, {this.color = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.0
          ..style = PaintingStyle.fill;

    final barWidth = size.width / amplitudes.length;

    for (int i = 0; i < amplitudes.length; i++) {
      final barHeight = amplitudes[i] * size.height;
      final x = i * barWidth;
      final y = (size.height - barHeight) / 2;

      canvas.drawRect(Rect.fromLTWH(x, y, barWidth * 0.8, barHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
