import 'package:flutter/material.dart';
import '../theme/mirello_theme.dart';

/// Subject doodle identifier enum
enum SubjectDoodleType {
  logic, // TPS (Tes Potensi Skolastik)
  math, // Pengetahuan Kuantitatif
  reading, // Literasi B. Indonesia / B. Inggris
  calculus, // Penalaran Matematika
}

/// Helper to render a four-point editorial sparkle star
void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
  final path = Path();
  final half = size / 2;

  path.moveTo(center.dx, center.dy - half);
  path.quadraticBezierTo(center.dx, center.dy, center.dx + half, center.dy);
  path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + half);
  path.quadraticBezierTo(center.dx, center.dy, center.dx - half, center.dy);
  path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - half);
  path.close();

  final fill = Paint()
    ..color = paint.color
    ..style = PaintingStyle.fill;
  canvas.drawPath(path, fill);
}

// =============================================================================
// 1. LOGIC DOODLE PAINTER (TPS: thought cloud, lightbulb, and geometric nodes)
// =============================================================================
class LogicDoodlePainter extends CustomPainter {
  final Color color;
  final Color fillColor;
  final double strokeWidth;

  const LogicDoodlePainter({
    this.color = MirelloColors.primaryInk,
    this.fillColor = const Color(0xE6FFFFFF),
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Scale reference coordinate system (100 x 100) to actual canvas size
    final scaleX = size.width / 100.0;
    final scaleY = size.height / 100.0;
    canvas.scale(scaleX, scaleY);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final solidInk = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // --- A. Thought Cloud (top-left) ---
    final cloudPath = Path();
    cloudPath.moveTo(20, 36);
    cloudPath.arcToPoint(const Offset(26, 22), radius: const Radius.circular(10));
    cloudPath.arcToPoint(const Offset(42, 20), radius: const Radius.circular(12));
    cloudPath.arcToPoint(const Offset(52, 30), radius: const Radius.circular(10));
    cloudPath.arcToPoint(const Offset(46, 42), radius: const Radius.circular(10));
    cloudPath.arcToPoint(const Offset(28, 42), radius: const Radius.circular(10));
    cloudPath.close();

    canvas.drawPath(cloudPath, fillPaint);
    canvas.drawPath(cloudPath, linePaint);

    // Thought bubbles trailing down
    canvas.drawCircle(const Offset(22, 50), 3.0, fillPaint);
    canvas.drawCircle(const Offset(22, 50), 3.0, linePaint);

    canvas.drawCircle(const Offset(16, 58), 2.0, fillPaint);
    canvas.drawCircle(const Offset(16, 58), 2.0, linePaint);

    // --- B. Stylized Lightbulb (center-right) ---
    final bulbPath = Path();
    // Bulb glass curve
    bulbPath.moveTo(60, 60);
    bulbPath.cubicTo(50, 52, 48, 38, 58, 28);
    bulbPath.cubicTo(68, 18, 84, 20, 88, 32);
    bulbPath.cubicTo(92, 42, 84, 52, 74, 60);
    bulbPath.close();

    canvas.drawPath(bulbPath, fillPaint);
    canvas.drawPath(bulbPath, linePaint);

    // Bulb filament inside
    final filamentPath = Path();
    filamentPath.moveTo(63, 46);
    filamentPath.lineTo(67, 36);
    filamentPath.lineTo(70, 42);
    filamentPath.lineTo(73, 36);
    filamentPath.lineTo(77, 46);
    canvas.drawPath(filamentPath, linePaint);

    // Bulb screw base lines
    canvas.drawLine(const Offset(61, 64), const Offset(73, 64), linePaint);
    canvas.drawLine(const Offset(62, 68), const Offset(72, 68), linePaint);
    // Base contact point
    final baseContact = Path()
      ..moveTo(63, 68)
      ..arcToPoint(const Offset(71, 68), radius: const Radius.circular(4));
    canvas.drawPath(baseContact, solidInk);

    // Lightbulb radiant rays
    canvas.drawLine(const Offset(73, 15), const Offset(73, 8), linePaint);
    canvas.drawLine(const Offset(89, 21), const Offset(95, 16), linePaint);
    canvas.drawLine(const Offset(55, 20), const Offset(49, 15), linePaint);

    // --- C. Geometric Synapse Nodes (bottom) ---
    const nodeA = Offset(30, 78);
    const nodeB = Offset(48, 68);
    const nodeC = Offset(44, 88);
    const nodeD = Offset(66, 82);

    canvas.drawLine(nodeA, nodeB, linePaint);
    canvas.drawLine(nodeB, nodeC, linePaint);
    canvas.drawLine(nodeB, nodeD, linePaint);
    canvas.drawLine(nodeA, nodeC, linePaint);

    canvas.drawCircle(nodeA, 3.5, solidInk);
    canvas.drawCircle(nodeB, 4.0, fillPaint);
    canvas.drawCircle(nodeB, 4.0, linePaint);
    canvas.drawCircle(nodeC, 3.0, solidInk);
    canvas.drawCircle(nodeD, 3.5, fillPaint);
    canvas.drawCircle(nodeD, 3.5, linePaint);

    // Editorial sparkle accent
    _drawSparkle(canvas, const Offset(88, 50), 7, linePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LogicDoodlePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.strokeWidth != strokeWidth;
}

// =============================================================================
// 2. MATH DOODLE PAINTER (Pengetahuan Kuantitatif: +, -, ÷, ruler/pencil line art)
// =============================================================================
class MathDoodlePainter extends CustomPainter {
  final Color color;
  final Color fillColor;
  final double strokeWidth;

  const MathDoodlePainter({
    this.color = MirelloColors.primaryInk,
    this.fillColor = const Color(0xE6FFFFFF),
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scaleX = size.width / 100.0;
    final scaleY = size.height / 100.0;
    canvas.scale(scaleX, scaleY);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final solidInk = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // --- A. Triangular Set Square / Ruler (background layer) ---
    final setSquarePath = Path()
      ..moveTo(16, 44)
      ..lineTo(16, 82)
      ..lineTo(54, 82)
      ..close();

    final innerCutout = Path()
      ..moveTo(22, 54)
      ..lineTo(22, 76)
      ..lineTo(44, 76)
      ..close();

    canvas.drawPath(setSquarePath, fillPaint);
    canvas.drawPath(setSquarePath, linePaint);
    canvas.drawPath(innerCutout, linePaint);

    // Ruler measurement ticks along vertical edge
    canvas.drawLine(const Offset(16, 50), const Offset(20, 50), linePaint);
    canvas.drawLine(const Offset(16, 56), const Offset(19, 56), linePaint);
    canvas.drawLine(const Offset(16, 62), const Offset(20, 62), linePaint);
    canvas.drawLine(const Offset(16, 68), const Offset(19, 68), linePaint);
    canvas.drawLine(const Offset(16, 74), const Offset(20, 74), linePaint);

    // --- B. Angled Drafting Pencil ---
    // Pencil angled at ~45 degrees across the card
    final pencilPath = Path()
      ..moveTo(28, 86) // eraser base left
      ..lineTo(22, 80) // eraser base right
      ..lineTo(64, 38) // shoulder right
      ..lineTo(70, 44) // shoulder left
      ..close();

    canvas.drawPath(pencilPath, fillPaint);
    canvas.drawPath(pencilPath, linePaint);

    // Longitudinal facet lines of the pencil
    canvas.drawLine(const Offset(25, 83), const Offset(67, 41), linePaint);

    // Sharpened cone tip
    final pencilTip = Path()
      ..moveTo(64, 38)
      ..lineTo(75, 27) // lead tip point
      ..lineTo(70, 44)
      ..close();
    canvas.drawPath(pencilTip, fillPaint);
    canvas.drawPath(pencilTip, linePaint);

    // Solid graphite lead point
    final leadTip = Path()
      ..moveTo(71, 31)
      ..lineTo(75, 27)
      ..lineTo(73, 33)
      ..close();
    canvas.drawPath(leadTip, solidInk);

    // Eraser metal ferrule band
    canvas.drawLine(const Offset(31, 83), const Offset(25, 77), linePaint);

    // --- C. Floating Mathematical Symbols ---
    // 1. Division symbol ÷ (top left)
    canvas.drawLine(const Offset(22, 22), const Offset(36, 22), linePaint);
    canvas.drawCircle(const Offset(29, 16), 1.6, solidInk);
    canvas.drawCircle(const Offset(29, 28), 1.6, solidInk);

    // 2. Plus symbol + (top right)
    canvas.drawLine(const Offset(78, 14), const Offset(78, 26), linePaint);
    canvas.drawLine(const Offset(72, 20), const Offset(84, 20), linePaint);

    // 3. Square root √ with vinculum (bottom right)
    final rootPath = Path()
      ..moveTo(60, 72)
      ..lineTo(63, 76)
      ..lineTo(68, 64)
      ..lineTo(86, 64);
    canvas.drawPath(rootPath, linePaint);

    // 'x' inside the square root
    canvas.drawLine(const Offset(74, 69), const Offset(80, 77), linePaint);
    canvas.drawLine(const Offset(80, 69), const Offset(74, 77), linePaint);

    // 4. Minus symbol - (floating left)
    canvas.drawLine(const Offset(40, 32), const Offset(49, 32), linePaint);

    // Editorial sparkle
    _drawSparkle(canvas, const Offset(86, 42), 6, linePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MathDoodlePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.strokeWidth != strokeWidth;
}

// =============================================================================
// 3. READING DOODLE PAINTER (Literasi B. Indonesia: open book, lamp, sparkles)
// =============================================================================
class ReadingDoodlePainter extends CustomPainter {
  final Color color;
  final Color fillColor;
  final double strokeWidth;

  const ReadingDoodlePainter({
    this.color = MirelloColors.primaryInk,
    this.fillColor = const Color(0xE6FFFFFF),
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scaleX = size.width / 100.0;
    final scaleY = size.height / 100.0;
    canvas.scale(scaleX, scaleY);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final solidInk = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // --- A. Open Book (center/bottom) ---
    // Left page outline
    final leftPage = Path()
      ..moveTo(50, 60) // spine top
      ..cubicTo(40, 56, 30, 54, 18, 58) // top curved page edge
      ..lineTo(18, 78) // left outer edge
      ..cubicTo(30, 74, 40, 76, 50, 80) // bottom page curve
      ..close();

    // Right page outline
    final rightPage = Path()
      ..moveTo(50, 60)
      ..cubicTo(60, 56, 70, 54, 82, 58)
      ..lineTo(82, 78)
      ..cubicTo(70, 74, 60, 76, 50, 80)
      ..close();

    // Draw page fills
    canvas.drawPath(leftPage, fillPaint);
    canvas.drawPath(rightPage, fillPaint);

    // Book spine thickness layer (underlying pages)
    final bookBase = Path()
      ..moveTo(18, 78)
      ..lineTo(18, 83)
      ..cubicTo(30, 79, 40, 81, 50, 85)
      ..cubicTo(60, 81, 70, 79, 82, 83)
      ..lineTo(82, 78);
    canvas.drawPath(bookBase, linePaint);

    // Outlines of open pages
    canvas.drawPath(leftPage, linePaint);
    canvas.drawPath(rightPage, linePaint);

    // Spine center seam
    canvas.drawLine(const Offset(50, 60), const Offset(50, 80), linePaint);

    // Swallowtail bookmark ribbon hanging from spine
    final ribbon = Path()
      ..moveTo(48, 80)
      ..lineTo(48, 93)
      ..lineTo(51, 90)
      ..lineTo(54, 93)
      ..lineTo(54, 80);
    canvas.drawPath(ribbon, fillPaint);
    canvas.drawPath(ribbon, linePaint);

    // Text line indications on pages
    // Left page lines
    canvas.drawLine(const Offset(24, 65), const Offset(44, 65), linePaint);
    canvas.drawLine(const Offset(24, 70), const Offset(42, 70), linePaint);
    canvas.drawLine(const Offset(24, 75), const Offset(36, 75), linePaint);

    // Right page lines
    canvas.drawLine(const Offset(56, 65), const Offset(76, 65), linePaint);
    canvas.drawLine(const Offset(56, 70), const Offset(74, 70), linePaint);
    canvas.drawLine(const Offset(56, 75), const Offset(66, 75), linePaint);

    // --- B. Minimalist Reading Lamp (arching from top-right) ---
    // Curved lamp neck/stem
    final lampStem = Path()
      ..moveTo(88, 52)
      ..cubicTo(92, 34, 82, 16, 62, 18);
    canvas.drawPath(lampStem, linePaint);

    // Conical lampshade
    final lampShade = Path()
      ..moveTo(64, 14)
      ..lineTo(54, 25)
      ..lineTo(44, 16)
      ..close();
    canvas.drawPath(lampShade, fillPaint);
    canvas.drawPath(lampShade, linePaint);

    // Lamp lightbulb inside rim
    canvas.drawCircle(const Offset(54, 23), 2.2, solidInk);

    // Subtle dotted illumination rays directed at the book
    final dashPaint = Paint()
      ..color = color.withAlpha(90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(50, 28), const Offset(44, 46), dashPaint);
    canvas.drawLine(const Offset(54, 30), const Offset(54, 48), dashPaint);
    canvas.drawLine(const Offset(58, 28), const Offset(64, 46), dashPaint);

    // --- C. Floating Editorial Sparkles ---
    _drawSparkle(canvas, const Offset(26, 32), 8, linePaint);
    _drawSparkle(canvas, const Offset(76, 38), 5, linePaint);
    canvas.drawCircle(const Offset(36, 18), 1.5, solidInk);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ReadingDoodlePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.strokeWidth != strokeWidth;
}

// =============================================================================
// 4. CALCULUS DOODLE PAINTER (Penalaran Matematika: coordinate graph & question mark)
// =============================================================================
class CalculusDoodlePainter extends CustomPainter {
  final Color color;
  final Color fillColor;
  final double strokeWidth;

  const CalculusDoodlePainter({
    this.color = MirelloColors.primaryInk,
    this.fillColor = const Color(0xE6FFFFFF),
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scaleX = size.width / 100.0;
    final scaleY = size.height / 100.0;
    canvas.scale(scaleX, scaleY);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final solidInk = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final areaPaint = Paint()
      ..color = color.withAlpha(25)
      ..style = PaintingStyle.fill;

    // --- A. Coordinate Axes with Arrowheads ---
    // X Axis
    canvas.drawLine(const Offset(16, 76), const Offset(84, 76), linePaint);
    // Arrowhead X
    canvas.drawLine(const Offset(80, 73), const Offset(84, 76), linePaint);
    canvas.drawLine(const Offset(80, 79), const Offset(84, 76), linePaint);

    // Y Axis
    canvas.drawLine(const Offset(22, 82), const Offset(22, 16), linePaint);
    // Arrowhead Y
    canvas.drawLine(const Offset(19, 20), const Offset(22, 16), linePaint);
    canvas.drawLine(const Offset(25, 20), const Offset(22, 16), linePaint);

    // Axis tick marks
    canvas.drawLine(const Offset(22, 60), const Offset(25, 60), linePaint);
    canvas.drawLine(const Offset(22, 44), const Offset(25, 44), linePaint);
    canvas.drawLine(const Offset(22, 28), const Offset(25, 28), linePaint);

    canvas.drawLine(const Offset(38, 76), const Offset(38, 73), linePaint);
    canvas.drawLine(const Offset(54, 76), const Offset(54, 73), linePaint);
    canvas.drawLine(const Offset(70, 76), const Offset(70, 73), linePaint);

    // --- B. Smooth Calculus Function Curve & Shaded Integral Region ---
    // Integral shaded region under local peak
    final integralArea = Path()
      ..moveTo(30, 76)
      ..cubicTo(32, 60, 36, 40, 44, 40)
      ..cubicTo(50, 40, 54, 54, 60, 56)
      ..lineTo(60, 76)
      ..close();
    canvas.drawPath(integralArea, areaPaint);

    // Smooth cubic Bezier function curve
    final curvePath = Path()
      ..moveTo(24, 72)
      ..cubicTo(32, 58, 36, 40, 44, 40)
      ..cubicTo(52, 40, 56, 58, 64, 56)
      ..cubicTo(70, 54, 76, 36, 82, 24);
    canvas.drawPath(curvePath, linePaint);

    // Local maximum critical point
    canvas.drawCircle(const Offset(44, 40), 3.0, solidInk);

    // Dashed tangent line at extremum
    final tangentPaint = Paint()
      ..color = color.withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(34, 40), const Offset(54, 40), tangentPaint);

    // --- C. Hand-Drawn Editorial Question Mark ? (center-right) ---
    final qPath = Path()
      ..moveTo(64, 28)
      ..cubicTo(66, 18, 78, 16, 80, 24)
      ..cubicTo(82, 32, 73, 34, 73, 40);
    canvas.drawPath(qPath, linePaint);
    // Question mark dot
    canvas.drawCircle(const Offset(73, 46), 1.8, solidInk);

    // Floating delta Δ symbol
    final deltaPath = Path()
      ..moveTo(36, 24)
      ..lineTo(42, 16)
      ..lineTo(48, 24)
      ..close();
    canvas.drawPath(deltaPath, linePaint);

    // Editorial sparkle
    _drawSparkle(canvas, const Offset(86, 62), 6, linePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CalculusDoodlePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.strokeWidth != strokeWidth;
}

// =============================================================================
// REUSABLE WIDGET WRAPPERS
// =============================================================================

class LogicDoodle extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final Color? fillColor;
  final double strokeWidth;

  const LogicDoodle({
    super.key,
    this.width = 80,
    this.height = 80,
    this.color,
    this.fillColor,
    this.strokeWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: LogicDoodlePainter(
          color: color ?? MirelloColors.primaryInk,
          fillColor: fillColor ?? const Color(0xE6FFFFFF),
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class MathDoodle extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final Color? fillColor;
  final double strokeWidth;

  const MathDoodle({
    super.key,
    this.width = 80,
    this.height = 80,
    this.color,
    this.fillColor,
    this.strokeWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: MathDoodlePainter(
          color: color ?? MirelloColors.primaryInk,
          fillColor: fillColor ?? const Color(0xE6FFFFFF),
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class ReadingDoodle extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final Color? fillColor;
  final double strokeWidth;

  const ReadingDoodle({
    super.key,
    this.width = 80,
    this.height = 80,
    this.color,
    this.fillColor,
    this.strokeWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: ReadingDoodlePainter(
          color: color ?? MirelloColors.primaryInk,
          fillColor: fillColor ?? const Color(0xE6FFFFFF),
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class CalculusDoodle extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final Color? fillColor;
  final double strokeWidth;

  const CalculusDoodle({
    super.key,
    this.width = 80,
    this.height = 80,
    this.color,
    this.fillColor,
    this.strokeWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: CalculusDoodlePainter(
          color: color ?? MirelloColors.primaryInk,
          fillColor: fillColor ?? const Color(0xE6FFFFFF),
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

/// Unified Subject Doodle factory
class SubjectDoodle extends StatelessWidget {
  final SubjectDoodleType type;
  final double width;
  final double height;
  final Color? color;
  final Color? fillColor;
  final double strokeWidth;

  const SubjectDoodle({
    super.key,
    required this.type,
    this.width = 80,
    this.height = 80,
    this.color,
    this.fillColor,
    this.strokeWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case SubjectDoodleType.logic:
        return LogicDoodle(
          width: width,
          height: height,
          color: color,
          fillColor: fillColor,
          strokeWidth: strokeWidth,
        );
      case SubjectDoodleType.math:
        return MathDoodle(
          width: width,
          height: height,
          color: color,
          fillColor: fillColor,
          strokeWidth: strokeWidth,
        );
      case SubjectDoodleType.reading:
        return ReadingDoodle(
          width: width,
          height: height,
          color: color,
          fillColor: fillColor,
          strokeWidth: strokeWidth,
        );
      case SubjectDoodleType.calculus:
        return CalculusDoodle(
          width: width,
          height: height,
          color: color,
          fillColor: fillColor,
          strokeWidth: strokeWidth,
        );
    }
  }
}
