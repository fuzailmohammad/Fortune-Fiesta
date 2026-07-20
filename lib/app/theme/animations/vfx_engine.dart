import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Particle Families
enum ParticleFamily {
  coin,
  star,
  sparkle,
  diamond,
  confetti,
  glowDust,
  shockwave,
}

// Particle Shapes
enum ParticleShape {
  circle,
  square,
  star,
  diamond,
  ring,
}

// Visual Effect Presets
enum EffectPreset {
  coinBurst, // Explosion of gold coins
  confettiShower, // Screen-wide confetti fall
  sparkleSplash, // Starry sparkle burst
  shockwaveRing, // Expanding energy ring
}

// Graphics Quality Levels
enum VfxQuality {
  low, // 30% particle density
  medium, // 60% particle density
  high, // 100% particle density
  ultra, // 150% particle density
}

// Physics Particle Class
class Particle {
  bool active = false;

  // Position & Velocity
  double x = 0.0;
  double y = 0.0;
  double vx = 0.0;
  double vy = 0.0;
  double ax = 0.0;
  double ay = 0.0;

  // Physics constraints
  double gravity = 0.0;
  double drag = 0.98;
  double wind = 0.0;

  // Visuals
  double size = 10.0;
  double startSize = 10.0;
  double rotation = 0.0;
  double rotationalSpeed = 0.0;
  double opacity = 1.0;

  // Life timeline
  double age = 0.0;
  double maxLife = 1.0; // In seconds

  Color color = Colors.white;
  ParticleFamily family = ParticleFamily.glowDust;
  ParticleShape shape = ParticleShape.circle;

  // Optional Bezier trajectory targets
  Offset? bezierEnd;
  Offset? bezierControl;
  double bezierProgress = 0.0;

  void reset() {
    active = false;
    x = 0.0;
    y = 0.0;
    vx = 0.0;
    vy = 0.0;
    ax = 0.0;
    ay = 0.0;
    gravity = 0.0;
    drag = 0.98;
    wind = 0.0;
    size = 10.0;
    startSize = 10.0;
    rotation = 0.0;
    rotationalSpeed = 0.0;
    opacity = 1.0;
    age = 0.0;
    maxLife = 1.0;
    color = Colors.white;
    family = ParticleFamily.glowDust;
    shape = ParticleShape.circle;
    bezierEnd = null;
    bezierControl = null;
    bezierProgress = 0.0;
  }

  void update(double dt) {
    if (!active) return;
    age += dt;

    if (age >= maxLife) {
      active = false;
      return;
    }

    final double lifeRatio = age / maxLife;

    if (bezierEnd != null && bezierControl != null) {
      // 1. Bezier Flight Trajectory Math
      bezierProgress = (age / maxLife).clamp(0.0, 1.0);
      final double mt = 1.0 - bezierProgress;

      // Calculate Quadratic Bezier Position
      final double bx = (mt * mt * x) +
          (2.0 * mt * bezierProgress * bezierControl!.dx) +
          (bezierProgress * bezierProgress * bezierEnd!.dx);
      final double by = (mt * mt * y) +
          (2.0 * mt * bezierProgress * bezierControl!.dy) +
          (bezierProgress * bezierProgress * bezierEnd!.dy);

      // Temporary position holder
      x = bx;
      y = by;

      rotation += rotationalSpeed * dt;
      opacity = lifeRatio > 0.85 ? (1.0 - lifeRatio) * 6.6 : 1.0;
    } else {
      // 2. Physics Emitter Movement Math
      vx += ax * dt;
      vy += ay * dt + gravity * dt;
      vx *= math.pow(drag, dt * 60.0);
      vy *= math.pow(drag, dt * 60.0);
      x += (vx + wind) * dt;
      y += vy * dt;

      rotation += rotationalSpeed * dt;

      // Opacity and Size scaling curves
      if (family == ParticleFamily.shockwave) {
        opacity = 1.0 - lifeRatio;
        size = startSize * (1.0 + lifeRatio * 3.0); // Expanding ring
      } else {
        opacity = 1.0 - lifeRatio;
        size = startSize * (1.0 - lifeRatio * 0.3);
      }
    }
  }
}

// Performance-Critical Recycler Pool
class ParticlePool {
  final List<Particle> _pool = [];
  final int maxPoolSize;

  ParticlePool({this.maxPoolSize = 400}) {
    // Pre-populate memory block
    for (int i = 0; i < maxPoolSize; i++) {
      _pool.add(Particle());
    }
  }

  Particle? acquire() {
    for (int i = 0; i < _pool.length; i++) {
      if (!_pool[i].active) {
        _pool[i].reset();
        _pool[i].active = true;
        return _pool[i];
      }
    }
    // Fallback: If pool is exhausted, return null (respecting device constraints)
    return null;
  }
}

// Global VFX Controller Singleton (120 FPS frame ticker)
class VfxController extends ChangeNotifier {
  VfxController._();

  static final VfxController instance = VfxController._();

  Ticker? _ticker;
  final ParticlePool _pool = ParticlePool(maxPoolSize: 450);
  final List<Particle> activeParticles = [];
  final math.Random _random = math.Random();

  VfxQuality quality = VfxQuality.high;
  double _lastElapsedSeconds = 0.0;

  void startEngine() {
    if (_ticker != null && _ticker!.isTicking) return;
    _lastElapsedSeconds = 0.0;
    _ticker?.dispose();
    _ticker = Ticker(_onTick);
    _ticker!.start();
  }

  void stopEngine() {
    _ticker?.stop();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _ticker = null;
    super.dispose();
  }

  // Quality multiplier capping particle densities
  double _getQualityMultiplier() {
    switch (quality) {
      case VfxQuality.low:
        return 0.3;
      case VfxQuality.medium:
        return 0.6;
      case VfxQuality.ultra:
        return 1.4;
      case VfxQuality.high:
        return 1.0;
    }
  }

  // Simplified play API
  void playEffect(EffectPreset preset, Offset spawnPoint, {Offset? endPoint}) {
    startEngine();
    final double density = _getQualityMultiplier();

    switch (preset) {
      case EffectPreset.coinBurst:
        _spawnCoinBurst(spawnPoint, endPoint, density);
        break;
      case EffectPreset.confettiShower:
        _spawnConfettiShower(spawnPoint, density);
        break;
      case EffectPreset.sparkleSplash:
        _spawnSparkleSplash(spawnPoint, density);
        break;
      case EffectPreset.shockwaveRing:
        _spawnShockwaveRing(spawnPoint);
        break;
    }
    notifyListeners();
  }

  void _spawnCoinBurst(Offset start, Offset? end, double density) {
    final int count = ((end != null ? 22 : 12) * density).round();
    final Offset target = end ?? Offset(start.dx, start.dy - 100);

    for (int i = 0; i < count; i++) {
      final p = _pool.acquire();
      if (p == null) continue;

      p.x = start.dx;
      p.y = start.dy;
      p.maxLife = 1.0 + _random.nextDouble() * 0.4;
      p.size = 14.0 + _random.nextDouble() * 8.0;
      p.startSize = p.size;
      p.family = ParticleFamily.coin;
      p.shape = ParticleShape.circle;
      p.color = const Color(0xFFFFD700);

      // Bezier curve trajectory properties
      p.bezierEnd = target;
      p.bezierControl = Offset(
        start.dx + (_random.nextDouble() - 0.5) * 240.0,
        start.dy - 180.0 - _random.nextDouble() * 120.0,
      );
      p.age = -(i * 0.025); // Delayed cascade release
      p.rotation = _random.nextDouble() * math.pi * 2;
      p.rotationalSpeed = (_random.nextDouble() - 0.5) * 12;

      activeParticles.add(p);
    }
  }

  void _spawnConfettiShower(Offset start, double density) {
    final int count = (60 * density).round();
    for (int i = 0; i < count; i++) {
      final p = _pool.acquire();
      if (p == null) continue;

      p.x = _random.nextDouble() * start.dx; // Use width as max boundary
      p.y = -20 - _random.nextDouble() * 150;
      p.vx = (_random.nextDouble() - 0.5) * 120.0;
      p.vy = 120.0 + _random.nextDouble() * 180.0;
      p.drag = 0.97;
      p.gravity = 90.0; // Gravity acceleration
      p.wind = (_random.nextDouble() - 0.5) * 15.0;

      p.maxLife = 3.0 + _random.nextDouble() * 2.0;
      p.size = 8.0 + _random.nextDouble() * 10.0;
      p.startSize = p.size;
      p.family = ParticleFamily.confetti;
      p.shape = _getRandomConfettiShape();
      p.color = _getConfettiColor();

      p.rotation = _random.nextDouble() * math.pi * 2;
      p.rotationalSpeed = (_random.nextDouble() - 0.5) * 6.0;

      activeParticles.add(p);
    }
  }

  void _spawnSparkleSplash(Offset start, double density) {
    final int count = (16 * density).round();
    for (int i = 0; i < count; i++) {
      final p = _pool.acquire();
      if (p == null) continue;

      p.x = start.dx;
      p.y = start.dy;

      final double angle = _random.nextDouble() * math.pi * 2;
      final double speed = 80.0 + _random.nextDouble() * 180.0;
      p.vx = math.cos(angle) * speed;
      p.vy = math.sin(angle) * speed;
      p.drag = 0.94;
      p.gravity = 15.0;

      p.maxLife = 0.6 + _random.nextDouble() * 0.5;
      p.size = 10.0 + _random.nextDouble() * 8.0;
      p.startSize = p.size;
      p.family = ParticleFamily.sparkle;
      p.shape = ParticleShape.star;
      p.color = Colors.white;

      p.rotation = _random.nextDouble() * math.pi * 2;
      p.rotationalSpeed = (_random.nextDouble() - 0.5) * 10.0;

      activeParticles.add(p);
    }
  }

  void _spawnShockwaveRing(Offset start) {
    final p = _pool.acquire();
    if (p == null) return;

    p.x = start.dx;
    p.y = start.dy;
    p.maxLife = 0.5;
    p.size = 20.0;
    p.startSize = 20.0;
    p.family = ParticleFamily.shockwave;
    p.shape = ParticleShape.ring;
    p.color = const Color(0xFF00E5FF);

    activeParticles.add(p);
  }

  ParticleShape _getRandomConfettiShape() {
    final r = _random.nextDouble();
    if (r < 0.4) return ParticleShape.square;
    if (r < 0.7) return ParticleShape.diamond;
    return ParticleShape.star;
  }

  Color _getConfettiColor() {
    final r = _random.nextDouble();
    if (r < 0.4) return const Color(0xFFFFD700); // Gold
    if (r < 0.7) return const Color(0xFFE040FB); // Pink/Purple
    return const Color(0xFF00E5FF); // Electric Cyan
  }

  // Frame tick update handler
  void _onTick(Duration elapsed) {
    final double elapsedSeconds =
        elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    double dt = elapsedSeconds - _lastElapsedSeconds;
    _lastElapsedSeconds = elapsedSeconds;

    if (dt > 0.03) dt = 0.03;

    // Filter out inactive particles
    activeParticles.removeWhere((p) {
      p.update(dt);
      return !p.active;
    });

    if (activeParticles.isEmpty) {
      stopEngine();
    }
    notifyListeners();
  }
}

// Visual Effects Overlay Widget
class VfxOverlay extends StatelessWidget {
  final Widget child;

  const VfxOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: VfxController.instance,
              builder: (context, child) {
                if (VfxController.instance.activeParticles.isEmpty) {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  painter: VfxPainter(
                    particles: VfxController.instance.activeParticles,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// 120 FPS High-Performance Canvas Painter
class VfxPainter extends CustomPainter {
  final List<Particle> particles;

  VfxPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    for (final p in particles) {
      if (p.age < 0 || p.opacity <= 0) continue;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      if (p.family == ParticleFamily.coin) {
        _paintGoldCoin(canvas, p, paint);
      } else if (p.family == ParticleFamily.confetti) {
        _paintConfetti(canvas, p, paint);
      } else if (p.family == ParticleFamily.sparkle) {
        _paintSparkleStar(canvas, p, paint);
      } else if (p.family == ParticleFamily.shockwave) {
        _paintShockwaveRing(canvas, p, paint);
      } else {
        // Standard Glow Dust circles
        paint.color = p.color.withValues(alpha: p.opacity);
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      }
      canvas.restore();
    }
  }

  void _paintGoldCoin(Canvas canvas, Particle p, Paint paint) {
    // Outer Gold gradient coin
    paint.shader = const RadialGradient(
      colors: [Color(0xFFFFEA00), Color(0xFFFF9100)],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: p.size / 2));
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, p.size / 2, paint);
    paint.shader = null;

    // Outer edge border details
    paint.color = const Color(0xFFE65100).withValues(alpha: p.opacity);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.2;
    canvas.drawCircle(Offset.zero, p.size * 0.35, paint);

    // Dollar/Coin line indicators
    paint.style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(-1.5, -p.size * 0.25, 3.0, p.size * 0.5), paint);
    canvas.drawCircle(Offset.zero, 1.8, paint);
  }

  void _paintConfetti(Canvas canvas, Particle p, Paint paint) {
    paint.color = p.color.withValues(alpha: p.opacity);
    paint.style = PaintingStyle.fill;

    if (p.shape == ParticleShape.square) {
      canvas.drawRect(
          Rect.fromLTWH(-p.size / 2, -p.size / 2, p.size, p.size), paint);
    } else if (p.shape == ParticleShape.diamond) {
      final path = Path()
        ..moveTo(0, -p.size / 2)
        ..lineTo(p.size / 2, 0)
        ..lineTo(0, p.size / 2)
        ..lineTo(-p.size / 2, 0)
        ..close();
      canvas.drawPath(path, paint);
    } else {
      // Star Confetti
      final double hs = p.size / 2;
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
  }

  void _paintSparkleStar(Canvas canvas, Particle p, Paint paint) {
    paint.color = p.color.withValues(alpha: p.opacity);
    paint.style = PaintingStyle.fill;

    final double hs = p.size / 2;
    final path = Path()
      ..moveTo(0, -hs)
      ..quadraticBezierTo(0, 0, hs, 0)
      ..quadraticBezierTo(0, 0, 0, hs)
      ..quadraticBezierTo(0, 0, -hs, 0)
      ..quadraticBezierTo(0, 0, 0, -hs)
      ..close();
    canvas.drawPath(path, paint);

    // Inner core glow
    paint.color = Colors.white.withValues(alpha: p.opacity * 0.6);
    canvas.drawCircle(Offset.zero, hs * 0.3, paint);
  }

  void _paintShockwaveRing(Canvas canvas, Particle p, Paint paint) {
    paint.color = p.color.withValues(alpha: p.opacity);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.0;

    // Expanding neon ring
    canvas.drawCircle(Offset.zero, p.size / 2, paint);

    // Outer radial glow outline
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;
    paint.color = p.color.withValues(alpha: p.opacity * 0.3);
    canvas.drawCircle(Offset.zero, p.size / 2 + 4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
