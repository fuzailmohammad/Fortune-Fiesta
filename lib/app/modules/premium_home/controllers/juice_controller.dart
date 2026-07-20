import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/juice_model.dart';
import 'settings_controller.dart';

class JuiceController extends GetxController {
  final RxList<JuiceParticle> particles = <JuiceParticle>[].obs;
  final RxList<Offset> rollingCoins = <Offset>[].obs;
  final RxList<Offset> butterflies = <Offset>[].obs;

  Timer? _tickTimer;
  final math.Random _random = math.Random();
  bool _wasRollingCoinsNotEmpty = false;
  bool _wasButterfliesNotEmpty = false;

  @override
  void onInit() {
    super.onInit();
    _startAnimationLoop();
  }

  @override
  void onClose() {
    _tickTimer?.cancel();
    super.onClose();
  }

  void _startAnimationLoop() {
    _tickTimer?.cancel();

    // Dynamically adjust loop rate based on Battery Saver settings
    // 16ms = ~60 FPS. If battery saver is active, we tick at 45ms (~22 FPS)
    final Duration duration = _isBatterySaverActive()
        ? const Duration(milliseconds: 45)
        : const Duration(milliseconds: 16);

    _tickTimer = Timer.periodic(duration, (_) => _updatePhysics());
  }

  bool _isBatterySaverActive() {
    try {
      if (Get.isRegistered<SettingsController>()) {
        return Get.find<SettingsController>()
            .settings
            .value
            .graphics
            .batterySaver;
      }
    } catch (_) {}
    return false;
  }

  bool get isBatterySaver => _isBatterySaverActive();

  void setAmbientParticlesEnabled(bool enabled) {
    if (enabled) {
      _startAnimationLoop();
    } else {
      _tickTimer?.cancel();
    }
  }

  int _getMaxParticleCount() {
    if (_isBatterySaverActive()) return 10; // Cap heavily to save energy

    try {
      if (Get.isRegistered<SettingsController>()) {
        final quality =
            Get.find<SettingsController>().settings.value.graphics.quality;
        switch (quality.name) {
          case 'low':
            return 15;
          case 'medium':
            return 30;
          case 'high':
            return 60;
          case 'ultra':
            return 100;
        }
      }
    } catch (_) {}
    return 40;
  }

  void _updatePhysics() {
    final int maxParticles = _getMaxParticleCount();

    // 1. Maintain floating particles count
    if (particles.length < maxParticles && _random.nextDouble() < 0.15) {
      _spawnSingleParticle();
    }
    if (particles.length > maxParticles) {
      particles.removeRange(maxParticles, particles.length);
    }

    // Update floating ambient particles
    for (int i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      p.x += p.vx * p.speed;
      p.y += p.vy * p.speed;
      p.opacity -= 0.005; // Fade out slowly

      // Reset dead particles
      if (p.opacity <= 0.0 || p.y < 0) {
        particles.removeAt(i);
      }
    }
    if (particles.isNotEmpty) {
      particles.refresh();
    }

    // 2. Update rolling gold coins
    if (rollingCoins.isNotEmpty) {
      for (int i = rollingCoins.length - 1; i >= 0; i--) {
        final coin = rollingCoins[i];
        final double newX = coin.dx + 4.5;
        final double newY =
            coin.dy + math.sin(newX / 25) * 1.5; // subtle bouncing wiggle

        if (newX > Get.width + 50) {
          rollingCoins.removeAt(i);
        } else {
          rollingCoins[i] = Offset(newX, newY);
        }
      }
    }
    if (rollingCoins.isNotEmpty || _wasRollingCoinsNotEmpty) {
      _wasRollingCoinsNotEmpty = rollingCoins.isNotEmpty;
      rollingCoins.refresh();
    }

    // 3. Update golden butterflies
    if (butterflies.isNotEmpty) {
      for (int i = butterflies.length - 1; i >= 0; i--) {
        final b = butterflies[i];
        final double newX = b.dx + 2.5;
        // Fluttering wiggle vector
        final double newY = b.dy - 1.2 + (physicsWiggle(newX));

        if (newX > Get.width + 50 || newY < -50) {
          butterflies.removeAt(i);
        } else {
          butterflies[i] = Offset(newX, newY);
        }
      }
    }
    if (butterflies.isNotEmpty || _wasButterfliesNotEmpty) {
      _wasButterfliesNotEmpty = butterflies.isNotEmpty;
      butterflies.refresh();
    }
  }

  double physicsWiggle(double x) {
    return math.sin(x / 10) * 3.5 + _random.nextDouble() * 1.5;
  }

  void _spawnSingleParticle() {
    particles.add(JuiceParticle(
      x: _random.nextDouble() * Get.width,
      y: Get.height + 20, // start just below screens
      vx: (_random.nextDouble() - 0.5) * 0.4,
      vy: -(_random.nextDouble() * 0.6 + 0.3),
      size: _random.nextDouble() * 3.5 + 1.2,
      opacity: 0.0,
      maxOpacity: _random.nextDouble() * 0.35 + 0.15,
      speed: 1.0,
      colorValue: _random.nextBool()
          ? 0xFFFFD700 // Gold star sparkle
          : 0xFF6A1B9A, // Royal Purple glow
    ));

    // Ramp up starting opacity fade
    particles.last.opacity = particles.last.maxOpacity;
  }

  // 🦋 Trigger Micro-surprises (rare delightful triggers)
  void triggerMicroSurprise(JuiceEffectType type) {
    if (_isBatterySaverActive()) return; // skip luxury surprises on saver

    if (type == JuiceEffectType.rollingCoin) {
      rollingCoins.add(Offset(-50, Get.height * 0.72));
    } else if (type == JuiceEffectType.butterfly) {
      butterflies.add(Offset(-50, Get.height * 0.45));
    }
  }

  // Settings changes apply instantly
  void onSettingsChanged() {
    _startAnimationLoop();
  }
}
