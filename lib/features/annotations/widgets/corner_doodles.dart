import 'package:flutter/material.dart';

/// Minimalist line-art doodles decorating the top corners of the TOC & Search sheet.
class TopCornerDoodlesPainter extends CustomPainter {
  final Color color;

  const TopCornerDoodlesPainter({
    this.color = const Color(0x4D1E1E1E), // Subtle charcoal line art
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // --- Top-Left Corner: Hand-drawn Cloud & Sparkle ---
    final cloud = Path();
    cloud.moveTo(18, 32);
    cloud.arcToPoint(const Offset(25, 20), radius: const Radius.circular(8));
    cloud.arcToPoint(const Offset(38, 18), radius: const Radius.circular(9));
    cloud.arcToPoint(const Offset(46, 26), radius: const Radius.circular(8));
    cloud.arcToPoint(const Offset(40, 36), radius: const Radius.circular(8));
    cloud.arcToPoint(const Offset(24, 36), radius: const Radius.circular(7));
    cloud.close();
    canvas.drawPath(cloud, linePaint);

    // Mini thought trail
    canvas.drawCircle(const Offset(18, 42), 1.5, fillPaint);
    canvas.drawCircle(const Offset(14, 48), 1.0, fillPaint);

    // Sparkle star near top-left
    _drawMiniSparkle(canvas, const Offset(56, 18), 7, fillPaint);

    // --- Top-Right Corner: Crescent Moon & Star Burst ---
    final moon = Path();
    moon.moveTo(size.width - 26, 16);
    moon.arcToPoint(
      Offset(size.width - 26, 36),
      radius: const Radius.circular(11),
      clockwise: false,
    );
    moon.arcToPoint(
      Offset(size.width - 26, 16),
      radius: const Radius.circular(8),
      clockwise: true,
    );
    moon.close();
    canvas.drawPath(moon, linePaint);

    // Floating sparkle star
    _drawMiniSparkle(canvas, Offset(size.width - 48, 28), 6, fillPaint);

    // Mini star dot
    canvas.drawCircle(Offset(size.width - 18, 44), 1.4, fillPaint);
  }

  void _drawMiniSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final half = size / 2;

    path.moveTo(center.dx, center.dy - half);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + half, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + half);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - half, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - half);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TopCornerDoodlesPainter oldDelegate) =>
      oldDelegate.color != color;
}

