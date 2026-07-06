import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/dynamic_atmosphere_controller.dart';
import 'package:get/get.dart';

class SleekParticleBackground extends StatefulWidget {
  final Widget child;
  final bool isSpinning;

  const SleekParticleBackground({
    super.key,
    required this.child,
    this.isSpinning = false,
  });

  @override
  State<SleekParticleBackground> createState() =>
      _SleekParticleBackgroundState();
}

class _SleekParticleBackgroundState extends State<SleekParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final List<GlowingOrb> _orbs = [];
  final List<Sparkle> _sparkles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;

      // Initialize 20 slowly rising background particles
      for (int i = 0; i < 20; i++) {
        _particles.add(Particle(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          radius: _random.nextDouble() * 2.5 + 1.0,
          speed: _random.nextDouble() * 0.3 + 0.1,
          opacity: _random.nextDouble() * 0.4 + 0.15,
          color: _getParticleColor(),
        ));
      }

      // Initialize 3 large drifting glowing orbs
      _orbs.add(GlowingOrb(
        x: size.width * 0.25,
        y: size.height * 0.3,
        radius: size.width * 0.45,
        color: const Color(0xFF6A1B9A).withValues(alpha: 0.18),
        speed: 0.0006,
        amplitude: 40.0,
      ));
      _orbs.add(GlowingOrb(
        x: size.width * 0.75,
        y: size.height * 0.7,
        radius: size.width * 0.55,
        color: const Color(0xFF310B5E).withValues(alpha: 0.22),
        speed: 0.0004,
        amplitude: 60.0,
      ));
      _orbs.add(GlowingOrb(
        x: size.width * 0.5,
        y: size.height * 0.45,
        radius: size.width * 0.4,
        color: const Color(0xFF00E5FF).withValues(alpha: 0.06),
        speed: 0.0008,
        amplitude: 30.0,
      ));

      // Initialize 10 twinkling sparkles
      for (int i = 0; i < 10; i++) {
        _sparkles.add(Sparkle(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height * 0.8,
          maxOpacity: _random.nextDouble() * 0.6 + 0.2,
          blinkSpeed: _random.nextDouble() * 0.03 + 0.015,
          size: _random.nextDouble() * 5 + 3,
        ));
      }
    });
  }

  Color _getParticleColor() {
    final randVal = _random.nextDouble();
    if (randVal < 0.4) {
      return const Color(0xFF00E5FF);
    } else if (randVal < 0.7) {
      return const Color(0xFFFFD700);
    } else {
      return const Color(0xFF9C27B0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Gradient Background (Responsive to Time-of-Day & Festivals)
        Obx(() {
          final colors = Get.isRegistered<DynamicAtmosphereController>()
              ? DynamicAtmosphereController.to.backgroundGradientColors
              : [const Color(0xFF150D2A), const Color(0xFF05030A)];
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.3,
                colors: colors.length >= 2
                    ? [colors[0], colors[1]]
                    : [const Color(0xFF150D2A), const Color(0xFF05030A)],
                stops: const [0.0, 1.0],
              ),
            ),
          );
        }),

        // Custom paint background
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: GameBackgroundPainter(
                  particles: _particles,
                  orbs: _orbs,
                  sparkles: _sparkles,
                  isSpinning: widget.isSpinning,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),

        // Foreground content
        widget.child,
      ],
    );
  }
}

class GlowingOrb {
  double x;
  double y;
  final double baseKeyX;
  final double baseKeyY;
  final double radius;
  final Color color;
  final double speed;
  final double amplitude;
  double _time = 0.0;

  GlowingOrb({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.speed,
    required this.amplitude,
  })  : baseKeyX = x,
        baseKeyY = y;

  void update() {
    _time += speed;
    x = baseKeyX + sin(_time * 2.0) * amplitude;
    y = baseKeyY + cos(_time * 1.5) * amplitude;
  }
}

class Particle {
  double x;
  double y;
  final double radius;
  final double speed;
  final double opacity;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.color,
  });

  void update(double height, {required bool isSpinning}) {
    // 2.5x speed increase when spinning
    final double currentSpeed = isSpinning ? speed * 2.5 : speed;
    y -= currentSpeed;
    if (y < -10) {
      y = height + 10;
    }
  }
}

class Sparkle {
  final double x;
  final double y;
  double opacity = 0.0;
  final double maxOpacity;
  final double blinkSpeed;
  final double size;
  bool _increasing = true;

  Sparkle({
    required this.x,
    required this.y,
    required this.maxOpacity,
    required this.blinkSpeed,
    required this.size,
  });

  void update({required bool isSpinning}) {
    // 2x speed increase when spinning
    final double currentSpeed = isSpinning ? blinkSpeed * 2.0 : blinkSpeed;
    if (_increasing) {
      opacity += currentSpeed;
      if (opacity >= maxOpacity) {
        opacity = maxOpacity;
        _increasing = false;
      }
    } else {
      opacity -= currentSpeed;
      if (opacity <= 0.0) {
        opacity = 0.0;
        _increasing = true;
      }
    }
  }
}

class GameBackgroundPainter extends CustomPainter {
  final List<Particle> particles;
  final List<GlowingOrb> orbs;
  final List<Sparkle> sparkles;
  final bool isSpinning;

  GameBackgroundPainter({
    required this.particles,
    required this.orbs,
    required this.sparkles,
    required this.isSpinning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 1. Paint and update Glowing Orbs
    for (final orb in orbs) {
      orb.update();
      final double sizeBoost = isSpinning ? 1.25 : 1.0;
      final double finalRadius = orb.radius * sizeBoost;
      paint.shader = RadialGradient(
        colors: [orb.color, Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(
          Rect.fromCircle(center: Offset(orb.x, orb.y), radius: finalRadius));
      canvas.drawCircle(Offset(orb.x, orb.y), finalRadius, paint);
    }
    paint.shader = null;

    // 2. Paint and update Twinkling Sparkles
    for (final sparkle in sparkles) {
      sparkle.update(isSpinning: isSpinning);
      if (sparkle.opacity > 0) {
        paint.color = Colors.white.withValues(alpha: sparkle.opacity);
        final double halfSize = sparkle.size / 2;

        final path = Path()
          ..moveTo(sparkle.x, sparkle.y - halfSize)
          ..quadraticBezierTo(
              sparkle.x, sparkle.y, sparkle.x + halfSize, sparkle.y)
          ..quadraticBezierTo(
              sparkle.x, sparkle.y, sparkle.x, sparkle.y + halfSize)
          ..quadraticBezierTo(
              sparkle.x, sparkle.y, sparkle.x - halfSize, sparkle.y)
          ..quadraticBezierTo(
              sparkle.x, sparkle.y, sparkle.x, sparkle.y - halfSize)
          ..close();
        canvas.drawPath(path, paint);
      }
    }

    // 3. Paint and update Rising Background Particles
    for (final particle in particles) {
      particle.update(size.height, isSpinning: isSpinning);
      paint.color = particle.color.withValues(alpha: particle.opacity);
      canvas.drawCircle(Offset(particle.x, particle.y), particle.radius, paint);
    }

    // 4. Accentuate Vignette during spinning to focus attention on center cabinet
    if (isSpinning) {
      paint.shader = RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.45),
        ],
        stops: const [0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GameBackgroundPainter oldDelegate) => true;
}
