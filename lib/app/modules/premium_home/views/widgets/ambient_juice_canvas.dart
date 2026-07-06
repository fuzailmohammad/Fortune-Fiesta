import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/juice_controller.dart';

class AmbientJuiceCanvas extends StatelessWidget {
  const AmbientJuiceCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<JuiceController>()) return const SizedBox.shrink();
    final controller = Get.find<JuiceController>();

    return Obx(() {
      return IgnorePointer(
        child: CustomPaint(
          size: Size.infinite,
          painter: _JuicePainter(
            particles: controller.particles.toList(),
            rollingCoins: controller.rollingCoins.toList(),
            butterflies: controller.butterflies.toList(),
          ),
        ),
      );
    });
  }
}

class _JuicePainter extends CustomPainter {
  final List<dynamic> particles;
  final List<Offset> rollingCoins;
  final List<Offset> butterflies;

  _JuicePainter({
    required this.particles,
    required this.rollingCoins,
    required this.butterflies,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw drifting particles
    final Paint pPaint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      pPaint.color = Color(p.colorValue).withValues(alpha: p.opacity);

      // Draw circular glow sparkle
      canvas.drawCircle(Offset(p.x, p.y), p.size, pPaint);

      // Draw subtle cross star highlights occasionally for gold sparkles
      if (p.colorValue == 0xFFFFD700 && p.size > 2.8) {
        final starPaint = Paint()
          ..color = Colors.white.withValues(alpha: p.opacity * 0.8)
          ..strokeWidth = 1.0;

        canvas.drawLine(
            Offset(p.x - p.size, p.y), Offset(p.x + p.size, p.y), starPaint);
        canvas.drawLine(
            Offset(p.x, p.y - p.size), Offset(p.x, p.y + p.size), starPaint);
      }
    }

    // 2. Draw rolling surprise coins
    final Paint coinPaint = Paint()..color = const Color(0xFFFFD700);
    final Paint coinRing = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final coin in rollingCoins) {
      // Draw beveled coin body
      canvas.drawCircle(coin, 12, coinPaint);
      canvas.drawCircle(coin, 9, coinRing);

      // Draw dollar icon center
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '\$',
          style: TextStyle(
            color: Color(0xFF5D4037),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(coin.dx - 4, coin.dy - 7.5));
    }

    // 3. Draw fluttering golden butterflies
    final Paint wingPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.85);
    final Paint bodyPaint = Paint()..color = const Color(0xFF4E342E);

    for (final b in butterflies) {
      // Draw body
      canvas.drawRect(Rect.fromLTWH(b.dx - 1.5, b.dy - 6, 3, 12), bodyPaint);

      // Draw left & right wings
      final Path leftWing = Path()
        ..moveTo(b.dx, b.dy)
        ..quadraticBezierTo(b.dx - 16, b.dy - 12, b.dx - 10, b.dy)
        ..quadraticBezierTo(b.dx - 14, b.dy + 8, b.dx, b.dy)
        ..close();

      final Path rightWing = Path()
        ..moveTo(b.dx, b.dy)
        ..quadraticBezierTo(b.dx + 16, b.dy - 12, b.dx + 10, b.dy)
        ..quadraticBezierTo(b.dx + 14, b.dy + 8, b.dx, b.dy)
        ..close();

      canvas.drawPath(leftWing, wingPaint);
      canvas.drawPath(rightWing, wingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _JuicePainter oldDelegate) {
    // High performance repaint checks
    return particles.isNotEmpty ||
        rollingCoins.isNotEmpty ||
        butterflies.isNotEmpty;
  }
}
