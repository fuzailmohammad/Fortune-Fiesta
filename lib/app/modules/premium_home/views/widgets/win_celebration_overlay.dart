import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';

enum WinCelebrationTier {
  small,
  big,
}

class WinCelebrationOverlay extends StatefulWidget {
  final int winAmount;
  final VoidCallback onFinished;

  const WinCelebrationOverlay({
    super.key,
    required this.winAmount,
    required this.onFinished,
  });

  @override
  State<WinCelebrationOverlay> createState() => _WinCelebrationOverlayState();
}

class _WinCelebrationOverlayState extends State<WinCelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _bannerController;
  late AnimationController _physicsController;

  late WinCelebrationTier _tier;
  final List<_BezierCoin> _coins = [];
  final List<_ConfettiParticle> _confetti = [];
  final math.Random _random = math.Random();

  bool _isSkipped = false;

  @override
  void initState() {
    super.initState();
    _tier = widget.winAmount >= 1000
        ? WinCelebrationTier.big
        : WinCelebrationTier.small;

    // 1. Intro Banner Animation Controller
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 2. Loop Physics controller for Confetti & Flying Coins
    final int durationMs = _tier == WinCelebrationTier.big ? 4500 : 2500;
    _physicsController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );

    _bannerController.forward();
    _physicsController.forward().then((_) {
      if (!_isSkipped) {
        widget.onFinished();
      }
    });

    // Initialize particles on post frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      _initializeCelebrationDetails(size);
    });
  }

  void _initializeCelebrationDetails(Size size) {
    final startPoint = Offset(size.width / 2, size.height * 0.55);
    final endPoint = Offset(
        size.width - 90, 42); // Coordinates pointing to Top-Right Coin HUD
    final controlPoint = Offset(size.width * 0.35, size.height * 0.15);

    // Spawn flight coins
    final int coinCount = _tier == WinCelebrationTier.big ? 35 : 15;
    for (int i = 0; i < coinCount; i++) {
      _coins.add(_BezierCoin(
        start: startPoint,
        end: endPoint,
        control: controlPoint,
        delay: i * 0.025, // Staggered stream release
        speed: 0.8 + _random.nextDouble() * 0.4,
        size: 14 + _random.nextDouble() * 8,
        startRotation: _random.nextDouble() * math.pi * 2,
        rotationalSpeed: (_random.nextDouble() - 0.5) * 15,
      ));
    }

    // Spawn falling confetti (mostly for Big Wins)
    final int confettiCount = _tier == WinCelebrationTier.big ? 90 : 25;
    for (int i = 0; i < confettiCount; i++) {
      _confetti.add(_ConfettiParticle(
        x: _random.nextDouble() * size.width,
        y: -20 - _random.nextDouble() * 150,
        color: _getConfettiColor(),
        shape: _getConfettiShape(),
        speedX: (_random.nextDouble() - 0.5) * 2.0,
        speedY: 2.0 + _random.nextDouble() * 4.0,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationalSpeed: (_random.nextDouble() - 0.5) * 8,
        size: 8 + _random.nextDouble() * 8,
        driftFreq: 0.5 + _random.nextDouble() * 1.5,
      ));
    }
  }

  Color _getConfettiColor() {
    final rVal = _random.nextDouble();
    if (rVal < 0.4) {
      return PremiumColors.premiumGold;
    } else if (rVal < 0.7) {
      return const Color(0xFFE040FB); // Magenta Purple
    } else {
      return PremiumColors.electricBlue;
    }
  }

  _ConfettiShape _getConfettiShape() {
    final rVal = _random.nextDouble();
    if (rVal < 0.35) {
      return _ConfettiShape.rectangle;
    } else if (rVal < 0.65) {
      return _ConfettiShape.star;
    } else {
      return _ConfettiShape.circle;
    }
  }

  void _skipCelebration() {
    if (_isSkipped) return;
    setState(() {
      _isSkipped = true;
    });
    _bannerController.stop();
    _physicsController.stop();

    // Instantly complete and invoke finish
    widget.onFinished();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _physicsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // 1. Interactive Tap-to-Skip Layer
        Positioned.fill(
          child: GestureDetector(
            onTap: _skipCelebration,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
        ),

        // 2. High-Performance Particle custom painter layer
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _physicsController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _CelebrationPhysicsPainter(
                    coins: _coins,
                    confetti: _confetti,
                    progress: _physicsController.value,
                    size: size,
                  ),
                );
              },
            ),
          ),
        ),

        // 3. Gold Banners and Scores (intro animated)
        Align(
          alignment: Alignment.center,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _bannerController,
              builder: (context, child) {
                final double opacity = CurvedAnimation(
                  parent: _bannerController,
                  curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
                ).value;

                final double scale = CurvedAnimation(
                  parent: _bannerController,
                  curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
                ).value;

                final double scoreOpacity = CurvedAnimation(
                  parent: _bannerController,
                  curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
                ).value;

                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Large Golden Win Banner
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: PremiumGradients.gold,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 2.0),
                            boxShadow: [
                              BoxShadow(
                                color: PremiumColors.premiumGold
                                    .withValues(alpha: 0.5),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            _tier == WinCelebrationTier.big
                                ? 'BIG WIN!'
                                : 'WINNER!',
                            style: PremiumTypography.numbersStyle.copyWith(
                              fontSize:
                                  _tier == WinCelebrationTier.big ? 28 : 22,
                              color: PremiumColors.richBlack,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Score increment text
                        Opacity(
                          opacity: scoreOpacity,
                          child: Text(
                            '+${widget.winAmount}',
                            style: PremiumTypography.numbersStyle.copyWith(
                              fontSize: 36,
                              color: PremiumColors.premiumGold,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  color: PremiumColors.premiumGold
                                      .withValues(alpha: 0.6),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Skip banner hint (bottom of screen)
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  'TAP TO SKIP',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 4. Confetti shapes
enum _ConfettiShape {
  rectangle,
  star,
  circle,
}

class _ConfettiParticle {
  double x;
  double y;
  final Color color;
  final _ConfettiShape shape;
  final double speedX;
  final double speedY;
  double rotation;
  final double rotationalSpeed;
  final double size;
  final double driftFreq;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.shape,
    required this.speedX,
    required this.speedY,
    required this.rotation,
    required this.rotationalSpeed,
    required this.size,
    required this.driftFreq,
  });

  void update(double dt) {
    y += speedY;
    x += speedX + math.sin(y * 0.05 * driftFreq) * 0.6;
    rotation += rotationalSpeed * dt;
  }
}

class _BezierCoin {
  final Offset start;
  final Offset end;
  final Offset control;
  final double delay;
  final double speed;
  final double size;
  final double startRotation;
  final double rotationalSpeed;

  _BezierCoin({
    required this.start,
    required this.end,
    required this.control,
    required this.delay,
    required this.speed,
    required this.size,
    required this.startRotation,
    required this.rotationalSpeed,
  });

  Offset getPosition(double t) {
    if (t < delay) return start;
    // Normalized flight timeline
    final double ft = ((t - delay) * speed).clamp(0.0, 1.0);
    // Quadratic Bezier Formula
    final double mt = 1.0 - ft;
    return (start * mt * mt) + (control * 2.0 * mt * ft) + (end * ft * ft);
  }

  double getRotation(double t) {
    if (t < delay) return startRotation;
    final double ft = ((t - delay) * speed).clamp(0.0, 1.0);
    return startRotation + rotationalSpeed * ft;
  }

  double getOpacity(double t) {
    if (t < delay) return 0.0;
    final double ft = ((t - delay) * speed).clamp(0.0, 1.0);
    if (ft >= 0.9) {
      return (1.0 - ft) * 10.0; // Fade out near coin card
    }
    return 1.0;
  }
}

// 5. Celebration Custom Painter
class _CelebrationPhysicsPainter extends CustomPainter {
  final List<_BezierCoin> coins;
  final List<_ConfettiParticle> confetti;
  final double progress;
  final Size size;

  _CelebrationPhysicsPainter({
    required this.coins,
    required this.confetti,
    required this.progress,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size paintSize) {
    final paint = Paint()..isAntiAlias = true;

    // 1. Paint Confetti particles
    for (final particle in confetti) {
      particle.update(0.016);

      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);
      paint.color = particle.color;

      if (particle.shape == _ConfettiShape.rectangle) {
        canvas.drawRect(
            Rect.fromLTWH(-particle.size / 2, -particle.size / 4, particle.size,
                particle.size / 2),
            paint);
      } else if (particle.shape == _ConfettiShape.circle) {
        canvas.drawCircle(Offset.zero, particle.size / 3, paint);
      } else {
        // Draw star shape
        final double hs = particle.size / 2;
        final path = Path()
          ..moveTo(0, -hs)
          ..lineTo(hs * 0.3, -hs * 0.3)
          ..lineTo(hs, 0)
          ..lineTo(hs * 0.3, hs * 0.3)
          ..lineTo(0, hs)
          ..lineTo(-hs * 0.3, hs * 0.3)
          ..lineTo(-hs, 0)
          ..lineTo(-hs * 0.3, -hs * 0.3)
          ..close();
        canvas.drawPath(path, paint);
      }
      canvas.restore();
    }

    // 2. Paint Bezier Flight Coins
    for (final coin in coins) {
      final double opacity = coin.getOpacity(progress);
      if (opacity <= 0) continue;

      final position = coin.getPosition(progress);
      final rotation = coin.getRotation(progress);

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(rotation);

      // Gold coin vector circle
      paint.shader = const RadialGradient(
        colors: [Color(0xFFFFEA00), Color(0xFFFF9100)],
      ).createShader(
          Rect.fromCircle(center: Offset.zero, radius: coin.size / 2));
      canvas.drawCircle(Offset.zero, coin.size / 2, paint);
      paint.shader = null;

      // Inner border
      paint.color = const Color(0xFFE65100).withValues(alpha: opacity);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.2;
      canvas.drawCircle(Offset.zero, coin.size * 0.35, paint);

      // Center symbol icon (Monetization sign)
      paint.color = const Color(0xFFE65100).withValues(alpha: opacity);
      paint.style = PaintingStyle.fill;
      canvas.drawRect(
          Rect.fromLTWH(-1.5, -coin.size * 0.25, 3.0, coin.size * 0.5), paint);
      canvas.drawCircle(Offset.zero, 1.8, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
