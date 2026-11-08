import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/localization/app_strings.dart';
import '../../library/presentation/home_screen.dart';

/// Minimalist, warm-editorial Get Started / Onboarding Screen for Nostra.
/// Shown strictly on first launch of the app.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onCompleted;

  const OnboardingScreen({super.key, this.onCompleted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onGetStarted() async {
    final box = Hive.isBoxOpen('app_settings')
        ? Hive.box('app_settings')
        : await Hive.openBox('app_settings');
    await box.put('has_seen_onboarding', true);

    if (widget.onCompleted != null) {
      widget.onCompleted!();
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F0),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Spacer
            const Spacer(flex: 2),

            // 2. Central Hand-Drawn Illustration (Swipeable 3-page PageView)
            SizedBox(
              height: 290,
              width: double.infinity,
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                children: const [
                  CustomPaint(
                    size: Size(double.infinity, 290),
                    painter: NostraOnboardingPainter(),
                  ),
                  CustomPaint(
                    size: Size(double.infinity, 290),
                    painter: NostraMindmapPainter(),
                  ),
                  CustomPaint(
                    size: Size(double.infinity, 290),
                    painter: NostraLibraryPainter(),
                  ),
                ],
              ),
            ),

            // 3. Spacing
            const SizedBox(height: 28),

            // 4. Main Brand Title "Nostra"
            Text(
              'Nostra',
              style: GoogleFonts.pacifico(
                fontSize: 48,
                color: const Color(0xFF1E1E1E),
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),

            // 5. Subtle Developer Credit "Project By TycamiTech"
            const SizedBox(height: 6),
            Text(
              'Project By TycamiTech',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
                color: const Color(0xFF1E1E1E).withValues(alpha: 0.45),
              ),
              textAlign: TextAlign.center,
            ),

            // 6. Bottom Spacer
            const Spacer(flex: 2),

            // 7. Primary CTA Pill Button "Mulai Sekarang"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E),
                    foregroundColor: const Color(0xFFF5F4F0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _onGetStarted,
                  child: Text(
                    AppStrings.getStarted,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF5F4F0),
                    ),
                  ),
                ),
              ),
            ),

            // 10. Bottom Spacing (clean below the button)
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Helper Functions for Editorial Drawing
// =============================================================================

void _drawDashedPath(
  Canvas canvas,
  Path path,
  Paint paint, {
  double dashWidth = 4.0,
  double dashSpace = 3.5,
}) {
  for (final metric in path.computeMetrics()) {
    double distance = 0.0;
    while (distance < metric.length) {
      final end = (distance + dashWidth).clamp(0.0, metric.length);
      final extract = metric.extractPath(distance, end);
      canvas.drawPath(extract, paint);
      distance += dashWidth + dashSpace;
    }
  }
}

void _drawSparkleStar(
  Canvas canvas,
  Offset center,
  double size,
  Paint strokePaint, [
  Paint? fillPaint,
]) {
  final path = Path();
  final half = size / 2;
  final quarter = size * 0.14;

  path.moveTo(center.dx, center.dy - half);
  path.quadraticBezierTo(
      center.dx + quarter, center.dy - quarter, center.dx + half, center.dy);
  path.quadraticBezierTo(
      center.dx + quarter, center.dy + quarter, center.dx, center.dy + half);
  path.quadraticBezierTo(
      center.dx - quarter, center.dy + quarter, center.dx - half, center.dy);
  path.quadraticBezierTo(
      center.dx - quarter, center.dy - quarter, center.dx, center.dy - half);
  path.close();

  if (fillPaint != null) {
    canvas.drawPath(path, fillPaint);
  }
  canvas.drawPath(path, strokePaint);
}

void _drawLineStar(
  Canvas canvas,
  Offset center,
  double radius,
  Paint strokePaint,
) {
  canvas.drawLine(
    Offset(center.dx, center.dy - radius),
    Offset(center.dx, center.dy + radius),
    strokePaint,
  );
  canvas.drawLine(
    Offset(center.dx - radius, center.dy),
    Offset(center.dx + radius, center.dy),
    strokePaint,
  );
}

// =============================================================================
// 1. PRIMARY NOSTRA ONBOARDING PAINTER (Student on Beanbag with Study Galaxy)
// =============================================================================

class NostraOnboardingPainter extends CustomPainter {
  const NostraOnboardingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Reference coordinate canvas: 320 x 290
    final scale = (size.height / 290.0).clamp(0.5, 1.35);
    final dx = (size.width - 320.0 * scale) / 2.0;
    final dy = (size.height - 290.0 * scale) / 2.0;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    // Paints
    final linePaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final sagePaint = Paint()
      ..color = const Color(0xFFDCE6DF)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0xFFEFE5CD)
      ..style = PaintingStyle.fill;

    final creamPaint = Paint()
      ..color = const Color(0xFFF7F3E8)
      ..style = PaintingStyle.fill;

    final lavenderPaint = Paint()
      ..color = const Color(0xFFE8E1EB)
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final inkFill = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.fill;

    final faintPaint = Paint()
      ..color = const Color(0x661E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // --- A. Floor Shadow (Warm Beige #EFE5CD) ---
    final shadowRect =
        Rect.fromCenter(center: const Offset(160, 252), width: 172, height: 26);
    canvas.drawOval(shadowRect, shadowPaint);

    final shadowLine = Path();
    shadowLine.moveTo(96, 255);
    shadowLine.quadraticBezierTo(160, 264, 224, 255);
    canvas.drawPath(
      shadowLine,
      Paint()
        ..color = const Color(0x2E1E1E1E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );

    // --- B. Soft Sage-Green Beanbag / Cushion (#DCE6DF) ---
    final beanbag = Path();
    beanbag.moveTo(102, 218);
    beanbag.cubicTo(94, 238, 120, 252, 160, 252);
    beanbag.cubicTo(200, 252, 226, 238, 218, 218);
    beanbag.cubicTo(225, 185, 210, 154, 180, 150);
    beanbag.cubicTo(160, 148, 140, 148, 120, 156);
    beanbag.cubicTo(95, 172, 98, 196, 102, 218);
    beanbag.close();

    canvas.drawPath(beanbag, sagePaint);
    canvas.drawPath(beanbag, linePaint);

    // Subtle hand-drawn creases on beanbag
    final crease1 = Path()
      ..moveTo(112, 222)
      ..quadraticBezierTo(132, 232, 146, 230);
    final crease2 = Path()
      ..moveTo(208, 222)
      ..quadraticBezierTo(188, 232, 174, 230);
    canvas.drawPath(crease1, linePaint);
    canvas.drawPath(crease2, linePaint);

    // --- C. Character / Student Sitting Comfortably ---
    // Legs tucked comfortably
    final leftLeg = Path()
      ..moveTo(122, 206)
      ..quadraticBezierTo(114, 222, 126, 232)
      ..quadraticBezierTo(140, 238, 152, 228)
      ..quadraticBezierTo(145, 215, 138, 208);
    canvas.drawPath(leftLeg, creamPaint);
    canvas.drawPath(leftLeg, linePaint);

    final rightLeg = Path()
      ..moveTo(198, 206)
      ..quadraticBezierTo(206, 222, 194, 232)
      ..quadraticBezierTo(180, 238, 168, 228)
      ..quadraticBezierTo(175, 215, 182, 208);
    canvas.drawPath(rightLeg, creamPaint);
    canvas.drawPath(rightLeg, linePaint);

    // Cozy simple socks / feet
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(132, 234), width: 13, height: 7.5),
      linePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(188, 234), width: 13, height: 7.5),
      linePaint,
    );

    // Torso / Cozy Sweater
    final torso = Path()
      ..moveTo(140, 162)
      ..cubicTo(132, 180, 134, 206, 144, 214)
      ..lineTo(176, 214)
      ..cubicTo(186, 206, 188, 180, 180, 162)
      ..close();
    canvas.drawPath(torso, whitePaint);
    canvas.drawPath(torso, linePaint);

    // Sweater collar
    final collar = Path()
      ..moveTo(152, 156)
      ..quadraticBezierTo(160, 163, 168, 156);
    canvas.drawPath(collar, linePaint);

    // Arms cradling notebook
    final armPaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final leftArm = Path()
      ..moveTo(140, 164)
      ..cubicTo(126, 176, 128, 192, 144, 196);
    canvas.drawPath(leftArm, armPaint);

    final rightArm = Path()
      ..moveTo(180, 164)
      ..cubicTo(194, 176, 192, 192, 176, 196);
    canvas.drawPath(rightArm, armPaint);

    // Hands gently holding notebook edges
    canvas.drawCircle(const Offset(144, 195), 3.5, creamPaint);
    canvas.drawCircle(const Offset(144, 195), 3.5, linePaint);
    canvas.drawCircle(const Offset(176, 195), 3.5, creamPaint);
    canvas.drawCircle(const Offset(176, 195), 3.5, linePaint);

    // Head base
    canvas.drawLine(const Offset(160, 148), const Offset(160, 156), linePaint);
    canvas.drawCircle(const Offset(160, 136), 12, creamPaint);
    canvas.drawCircle(const Offset(160, 136), 12, linePaint);

    // Editorial tousled hair
    final hair = Path()
      ..moveTo(148, 135)
      ..cubicTo(147, 122, 156, 120, 162, 120)
      ..cubicTo(172, 120, 175, 127, 173, 136)
      ..quadraticBezierTo(168, 128, 160, 129)
      ..quadraticBezierTo(154, 130, 148, 135)
      ..close();
    canvas.drawPath(hair, inkFill);

    // Peaceful closed reading eye
    final eye = Path()
      ..moveTo(161, 138)
      ..quadraticBezierTo(164, 141, 167, 138);
    canvas.drawPath(eye, linePaint);

    // --- D. Open Cream Notebook (#F7F3E8) ---
    final leftPage = Path()
      ..moveTo(160, 186)
      ..cubicTo(153, 184, 144, 186, 136, 189)
      ..lineTo(136, 206)
      ..cubicTo(144, 203, 153, 205, 160, 208)
      ..close();
    canvas.drawPath(leftPage, creamPaint);
    canvas.drawPath(leftPage, linePaint);

    final rightPage = Path()
      ..moveTo(160, 186)
      ..cubicTo(167, 184, 176, 186, 184, 189)
      ..lineTo(184, 206)
      ..cubicTo(176, 203, 167, 205, 160, 208)
      ..close();
    canvas.drawPath(rightPage, creamPaint);
    canvas.drawPath(rightPage, linePaint);

    // Bookmark ribbon dangling down
    final ribbon = Path()
      ..moveTo(160, 208)
      ..quadraticBezierTo(162, 216, 159, 222)
      ..lineTo(161, 220)
      ..lineTo(163, 222)
      ..quadraticBezierTo(162, 216, 160, 208);
    canvas.drawPath(ribbon, lavenderPaint);
    canvas.drawPath(ribbon, linePaint);

    // Ruled lines on pages
    canvas.drawLine(const Offset(141, 192), const Offset(155, 191), faintPaint);
    canvas.drawLine(const Offset(141, 197), const Offset(155, 196), faintPaint);
    canvas.drawLine(const Offset(165, 191), const Offset(179, 192), faintPaint);
    canvas.drawLine(const Offset(165, 196), const Offset(179, 197), faintPaint);

    // --- E. Floating Orbiting Study Elements ---

    // 1. Open Fluttering Book on the Left (approx 45, 140)
    canvas.save();
    canvas.translate(45, 140);
    canvas.rotate(-0.18);
    final bookL = Path()
      ..moveTo(0, -10)
      ..quadraticBezierTo(-12, -14, -20, -11)
      ..lineTo(-20, 11)
      ..quadraticBezierTo(-12, 8, 0, 12)
      ..close();
    final bookR = Path()
      ..moveTo(0, -10)
      ..quadraticBezierTo(12, -14, 20, -11)
      ..lineTo(20, 11)
      ..quadraticBezierTo(12, 8, 0, 12)
      ..close();
    canvas.drawPath(bookL, whitePaint);
    canvas.drawPath(bookL, linePaint);
    canvas.drawPath(bookR, whitePaint);
    canvas.drawPath(bookR, linePaint);
    // Motion flutter breeze
    final breeze = Path()
      ..moveTo(-25, -4)
      ..quadraticBezierTo(-31, -7, -33, -13);
    canvas.drawPath(breeze, linePaint);
    canvas.restore();

    // 2. Curved Arrow / Flight Path to Paper Plane at the Top
    final flightPath = Path()
      ..moveTo(125, 90)
      ..cubicTo(105, 50, 140, 32, 172, 38);
    _drawDashedPath(canvas, flightPath, linePaint);

    // Paper Plane at (184, 34)
    canvas.save();
    canvas.translate(184, 34);
    canvas.rotate(0.32);
    final plane = Path()
      ..moveTo(16, 0)
      ..lineTo(-14, -8)
      ..lineTo(-8, 0)
      ..lineTo(-14, 8)
      ..close();
    canvas.drawPath(plane, whitePaint);
    canvas.drawPath(plane, linePaint);
    canvas.drawLine(const Offset(16, 0), const Offset(-8, 0), linePaint);
    canvas.restore();

    // 3. 3-Node Logic Tree Diagram at Top-Right
    const root = Offset(255, 46);
    const childLeft = Offset(238, 76);
    const childRight = Offset(272, 76);
    canvas.drawLine(root, childLeft, linePaint);
    canvas.drawLine(root, childRight, linePaint);

    canvas.drawCircle(root, 8.5, sagePaint);
    canvas.drawCircle(root, 8.5, linePaint);
    canvas.drawCircle(childLeft, 7, lavenderPaint);
    canvas.drawCircle(childLeft, 7, linePaint);
    canvas.drawCircle(childRight, 7, sagePaint);
    canvas.drawCircle(childRight, 7, linePaint);

    canvas.drawCircle(root, 2.5, inkFill);
    canvas.drawCircle(childLeft, 2.0, inkFill);
    canvas.drawCircle(childRight, 2.0, inkFill);

    // 4. Minimalist Round Clock on the Right
    const clockCenter = Offset(270, 130);
    canvas.drawCircle(clockCenter, 14, whitePaint);
    canvas.drawCircle(clockCenter, 14, linePaint);
    canvas.drawLine(const Offset(270, 118), const Offset(270, 121), linePaint);
    canvas.drawLine(const Offset(270, 142), const Offset(270, 139), linePaint);
    canvas.drawLine(const Offset(258, 130), const Offset(261, 130), linePaint);
    canvas.drawLine(const Offset(282, 130), const Offset(279, 130), linePaint);
    // Clock hands at 10:10
    canvas.drawLine(clockCenter, const Offset(264, 124), linePaint);
    canvas.drawLine(clockCenter, const Offset(277, 125), linePaint);
    canvas.drawCircle(clockCenter, 2.0, inkFill);

    // 5. Tilted Pencil on the Right
    canvas.save();
    canvas.translate(260, 195);
    canvas.rotate(-0.55);
    final pencilBody =
        Rect.fromCenter(center: const Offset(0, 0), width: 7, height: 26);
    canvas.drawRect(pencilBody, shadowPaint);
    canvas.drawRect(pencilBody, linePaint);
    // Graphite Tip
    final tip = Path()
      ..moveTo(-3.5, 13)
      ..lineTo(0, 21)
      ..lineTo(3.5, 13)
      ..close();
    canvas.drawPath(tip, whitePaint);
    canvas.drawPath(tip, linePaint);
    final lead = Path()
      ..moveTo(-1.8, 17)
      ..lineTo(0, 21)
      ..lineTo(1.8, 17)
      ..close();
    canvas.drawPath(lead, inkFill);
    // Eraser cap (#E8E1EB)
    final eraser = Path()
      ..moveTo(-3.5, -13)
      ..lineTo(-3.5, -19)
      ..quadraticBezierTo(0, -22, 3.5, -19)
      ..lineTo(3.5, -13)
      ..close();
    canvas.drawPath(eraser, lavenderPaint);
    canvas.drawPath(eraser, linePaint);
    canvas.restore();

    // 6. Small Lavender Sticky Note on Bottom-Left (#E8E1EB)
    canvas.save();
    canvas.translate(55, 215);
    canvas.rotate(-0.1);
    final note = Path()
      ..moveTo(-13, -13)
      ..lineTo(13, -13)
      ..lineTo(13, 5)
      ..lineTo(5, 13)
      ..lineTo(-13, 13)
      ..close();
    canvas.drawPath(note, lavenderPaint);
    canvas.drawPath(note, linePaint);
    // Curled corner
    final curl = Path()
      ..moveTo(5, 13)
      ..lineTo(5, 5)
      ..lineTo(13, 5)
      ..close();
    canvas.drawPath(curl, shadowPaint);
    canvas.drawPath(curl, linePaint);
    // Mini note text lines
    canvas.drawLine(const Offset(-8, -6), const Offset(6, -6), faintPaint);
    canvas.drawLine(const Offset(-8, -1), const Offset(4, -1), faintPaint);
    canvas.drawLine(const Offset(-8, 4), const Offset(0, 4), faintPaint);
    canvas.restore();

    // 7. Accented 4-Point Hand-Drawn Sparkle Stars
    _drawSparkleStar(canvas, const Offset(70, 78), 14, linePaint, creamPaint);
    _drawSparkleStar(canvas, const Offset(218, 26), 11, linePaint, sagePaint);
    _drawSparkleStar(canvas, const Offset(296, 92), 12, linePaint, lavenderPaint);
    _drawSparkleStar(canvas, const Offset(34, 186), 10, linePaint, creamPaint);
    _drawLineStar(canvas, const Offset(102, 46), 4.5, linePaint);
    _drawLineStar(canvas, const Offset(236, 114), 4.0, linePaint);
    _drawLineStar(canvas, const Offset(290, 172), 3.5, linePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// 2. SLIDE 2: MINIMALIST MINDMAP & KNOWLEDGE CARDS PAINTER
// =============================================================================

class NostraMindmapPainter extends CustomPainter {
  const NostraMindmapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.height / 290.0).clamp(0.5, 1.35);
    final dx = (size.width - 320.0 * scale) / 2.0;
    final dy = (size.height - 290.0 * scale) / 2.0;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    final linePaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final sagePaint = Paint()
      ..color = const Color(0xFFDCE6DF)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0xFFEFE5CD)
      ..style = PaintingStyle.fill;

    final lavenderPaint = Paint()
      ..color = const Color(0xFFE8E1EB)
      ..style = PaintingStyle.fill;

    final softBluePaint = Paint()
      ..color = const Color(0xFFDCE2EA)
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final inkFill = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.fill;

    final faintPaint = Paint()
      ..color = const Color(0x661E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Floor shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(160, 248), width: 180, height: 24),
      shadowPaint,
    );

    // Central Card
    final centerCard = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(160, 160), width: 90, height: 72),
      const Radius.circular(12),
    );
    canvas.drawRRect(centerCard, whitePaint);
    canvas.drawRRect(centerCard, linePaint);

    // Card header chip & lines
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(125, 134, 28, 8),
        const Radius.circular(4),
      ),
      sagePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(125, 134, 28, 8),
        const Radius.circular(4),
      ),
      linePaint,
    );
    canvas.drawLine(const Offset(125, 154), const Offset(195, 154), faintPaint);
    canvas.drawLine(const Offset(125, 166), const Offset(185, 166), faintPaint);
    canvas.drawLine(const Offset(125, 178), const Offset(170, 178), faintPaint);

    // Mindmap Branches & Nodes
    final nodeA = const Offset(80, 85);
    final nodeB = const Offset(240, 80);
    final nodeC = const Offset(70, 195);
    final nodeD = const Offset(250, 200);

    // Branch curves
    final branchA = Path()
      ..moveTo(140, 130)
      ..quadraticBezierTo(105, 115, nodeA.dx + 15, nodeA.dy + 8);
    final branchB = Path()
      ..moveTo(180, 130)
      ..quadraticBezierTo(215, 110, nodeB.dx - 15, nodeB.dy + 8);
    final branchC = Path()
      ..moveTo(125, 175)
      ..quadraticBezierTo(90, 185, nodeC.dx + 16, nodeC.dy);
    final branchD = Path()
      ..moveTo(195, 175)
      ..quadraticBezierTo(230, 185, nodeD.dx - 16, nodeD.dy);

    _drawDashedPath(canvas, branchA, linePaint);
    _drawDashedPath(canvas, branchB, linePaint);
    _drawDashedPath(canvas, branchC, linePaint);
    _drawDashedPath(canvas, branchD, linePaint);

    // Node A (Lavender Tag)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: nodeA, width: 44, height: 26),
        const Radius.circular(8),
      ),
      lavenderPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: nodeA, width: 44, height: 26),
        const Radius.circular(8),
      ),
      linePaint,
    );
    canvas.drawCircle(Offset(nodeA.dx - 12, nodeA.dy), 3, inkFill);
    canvas.drawLine(
        Offset(nodeA.dx - 4, nodeA.dy), Offset(nodeA.dx + 12, nodeA.dy), faintPaint);

    // Node B (Soft Blue Circle)
    canvas.drawCircle(nodeB, 18, softBluePaint);
    canvas.drawCircle(nodeB, 18, linePaint);
    canvas.drawCircle(nodeB, 5, whitePaint);
    canvas.drawCircle(nodeB, 5, linePaint);

    // Node C (Warm Ochre Tag)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: nodeC, width: 40, height: 24),
        const Radius.circular(6),
      ),
      shadowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: nodeC, width: 40, height: 24),
        const Radius.circular(6),
      ),
      linePaint,
    );
    canvas.drawLine(Offset(nodeC.dx - 12, nodeC.dy - 3),
        Offset(nodeC.dx + 12, nodeC.dy - 3), faintPaint);
    canvas.drawLine(Offset(nodeC.dx - 12, nodeC.dy + 3),
        Offset(nodeC.dx + 6, nodeC.dy + 3), faintPaint);

    // Node D (Sage Green Diamond)
    canvas.save();
    canvas.translate(nodeD.dx, nodeD.dy);
    canvas.rotate(math.pi / 4);
    canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 22, height: 22), sagePaint);
    canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 22, height: 22), linePaint);
    canvas.restore();

    // Floating Drafting Triangle Ruler at top center
    canvas.save();
    canvas.translate(160, 60);
    canvas.rotate(0.12);
    final triangle = Path()
      ..moveTo(-18, 12)
      ..lineTo(18, 12)
      ..lineTo(-18, -24)
      ..close();
    canvas.drawPath(triangle, whitePaint);
    canvas.drawPath(triangle, linePaint);
    final innerTri = Path()
      ..moveTo(-12, 8)
      ..lineTo(8, 8)
      ..lineTo(-12, -12)
      ..close();
    canvas.drawPath(innerTri, linePaint);
    canvas.restore();

    // Sparkle Stars & Accents
    _drawSparkleStar(canvas, const Offset(42, 60), 13, linePaint, shadowPaint);
    _drawSparkleStar(canvas, const Offset(280, 50), 12, linePaint, sagePaint);
    _drawSparkleStar(canvas, const Offset(36, 140), 9, linePaint, lavenderPaint);
    _drawSparkleStar(canvas, const Offset(284, 150), 11, linePaint, softBluePaint);
    _drawLineStar(canvas, const Offset(120, 40), 4.5, linePaint);
    _drawLineStar(canvas, const Offset(215, 42), 4.0, linePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// 3. SLIDE 3: WARM EDITORIAL ARCHIVE & LIBRARY PAINTER
// =============================================================================

class NostraLibraryPainter extends CustomPainter {
  const NostraLibraryPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.height / 290.0).clamp(0.5, 1.35);
    final dx = (size.width - 320.0 * scale) / 2.0;
    final dy = (size.height - 290.0 * scale) / 2.0;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    final linePaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final sagePaint = Paint()
      ..color = const Color(0xFFDCE6DF)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0xFFEFE5CD)
      ..style = PaintingStyle.fill;

    final creamPaint = Paint()
      ..color = const Color(0xFFF7F3E8)
      ..style = PaintingStyle.fill;

    final lavenderPaint = Paint()
      ..color = const Color(0xFFE8E1EB)
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final faintPaint = Paint()
      ..color = const Color(0x661E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Floor Shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(160, 248), width: 180, height: 24),
      shadowPaint,
    );

    // Large Open Hardcover Journal in Center
    canvas.save();
    canvas.translate(160, 168);

    // Hardcover back edge
    final coverBack = Path()
      ..moveTo(-74, -30)
      ..lineTo(-74, 38)
      ..lineTo(74, 38)
      ..lineTo(74, -30)
      ..close();
    canvas.drawPath(coverBack, sagePaint);
    canvas.drawPath(coverBack, linePaint);

    // Left Page Spread
    final leftPage = Path()
      ..moveTo(-4, -34)
      ..cubicTo(-24, -38, -56, -34, -70, -28)
      ..lineTo(-70, 32)
      ..cubicTo(-56, 26, -24, 30, -4, 34)
      ..close();
    canvas.drawPath(leftPage, creamPaint);
    canvas.drawPath(leftPage, linePaint);

    // Right Page Spread
    final rightPage = Path()
      ..moveTo(4, -34)
      ..cubicTo(24, -38, 56, -34, 70, -28)
      ..lineTo(70, 32)
      ..cubicTo(56, 26, 24, 30, 4, 34)
      ..close();
    canvas.drawPath(rightPage, creamPaint);
    canvas.drawPath(rightPage, linePaint);

    // Hanging Ribbon
    final ribbon = Path()
      ..moveTo(0, 34)
      ..quadraticBezierTo(8, 48, 2, 58)
      ..lineTo(6, 55)
      ..lineTo(10, 58)
      ..quadraticBezierTo(8, 48, 0, 34);
    canvas.drawPath(ribbon, lavenderPaint);
    canvas.drawPath(ribbon, linePaint);

    // Editorial text lines on open book
    canvas.drawLine(const Offset(-60, -18), const Offset(-15, -20), faintPaint);
    canvas.drawLine(const Offset(-60, -8), const Offset(-15, -10), faintPaint);
    canvas.drawLine(const Offset(-60, 2), const Offset(-20, 0), faintPaint);
    canvas.drawLine(const Offset(-60, 12), const Offset(-25, 10), faintPaint);

    canvas.drawLine(const Offset(15, -20), const Offset(60, -18), faintPaint);
    canvas.drawLine(const Offset(15, -10), const Offset(60, -8), faintPaint);
    canvas.drawLine(const Offset(15, 0), const Offset(55, 2), faintPaint);
    canvas.drawLine(const Offset(15, 10), const Offset(50, 12), faintPaint);

    canvas.restore();

    // Floating Steaming Ceramic Coffee Mug on Right (245, 115)
    canvas.save();
    canvas.translate(245, 120);
    // Mug body
    final mug = Path()
      ..moveTo(-12, -14)
      ..lineTo(12, -14)
      ..cubicTo(12, 10, 8, 14, 0, 14)
      ..cubicTo(-8, 14, -12, 10, -12, -14)
      ..close();
    canvas.drawPath(mug, shadowPaint);
    canvas.drawPath(mug, linePaint);
    // Mug handle
    final handle = Path()
      ..moveTo(12, -8)
      ..cubicTo(20, -8, 20, 6, 11, 6);
    canvas.drawPath(handle, linePaint);
    // Steam curves
    final steam1 = Path()
      ..moveTo(-4, -20)
      ..quadraticBezierTo(-8, -26, -3, -32);
    final steam2 = Path()
      ..moveTo(4, -18)
      ..quadraticBezierTo(8, -25, 3, -31);
    canvas.drawPath(steam1, linePaint);
    canvas.drawPath(steam2, linePaint);
    canvas.restore();

    // Floating Archive Folder on Left (75, 105)
    canvas.save();
    canvas.translate(75, 105);
    canvas.rotate(-0.15);
    final folder = Path()
      ..moveTo(-26, -16)
      ..lineTo(-8, -16)
      ..lineTo(-2, -10)
      ..lineTo(26, -10)
      ..lineTo(26, 18)
      ..lineTo(-26, 18)
      ..close();
    canvas.drawPath(folder, whitePaint);
    canvas.drawPath(folder, linePaint);
    // Folder tab highlight
    final tabFill = Path()
      ..moveTo(-26, -16)
      ..lineTo(-8, -16)
      ..lineTo(-2, -10)
      ..lineTo(-26, -10)
      ..close();
    canvas.drawPath(tabFill, sagePaint);
    canvas.drawPath(tabFill, linePaint);
    // Small label
    canvas.drawLine(const Offset(-18, 4), const Offset(12, 4), faintPaint);
    canvas.restore();

    // Sparkle Stars & Accents
    _drawSparkleStar(canvas, const Offset(65, 48), 14, linePaint, lavenderPaint);
    _drawSparkleStar(canvas, const Offset(265, 52), 12, linePaint, sagePaint);
    _drawSparkleStar(canvas, const Offset(160, 62), 10, linePaint, shadowPaint);
    _drawSparkleStar(canvas, const Offset(36, 185), 11, linePaint, creamPaint);
    _drawSparkleStar(canvas, const Offset(285, 185), 10, linePaint, lavenderPaint);
    _drawLineStar(canvas, const Offset(105, 42), 4.5, linePaint);
    _drawLineStar(canvas, const Offset(215, 60), 4.0, linePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
