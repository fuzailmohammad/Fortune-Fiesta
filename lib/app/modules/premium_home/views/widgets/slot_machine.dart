import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fortune_fiesta/app/theme/animations/breathing_animation.dart';
import 'package:fortune_fiesta/app/theme/animations/glow_effects.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../../../data/models/audio_model.dart';
import '../../controllers/audio_controller.dart';
import '../../controllers/premium_home_controller.dart';
import '../../controllers/settings_controller.dart';

// Reel Spin Lifecycle States
enum SpinState {
  idle,
  starting, // Motor engages, slight backward anticipation pull
  accelerating, // Speed builds up rapidly
  cruise, // Stable maximum velocity reached
  slowing, // Gradual deceleration
  locking, // Magnetic lock-in towards target
  bouncing, // Mechanical spring oscillation
  rest, // Locked securely in position
}

// Constants and Coefficients for Reel Physics
class ReelPhysics {
  ReelPhysics._();

  static const double mass = 1.0;
  static const double gravity = 0.0;
  static const double springK = 180.0;
  static const double dampingC = 14.0;
}

class SlotMachine extends StatefulWidget {
  const SlotMachine({super.key});

  @override
  State<SlotMachine> createState() => _SlotMachineState();
}

class _SlotMachineState extends State<SlotMachine>
    with SingleTickerProviderStateMixin {
  late AnimationController _rumbleController;
  late Animation<double> _rumbleAnimation;
  bool _wasSpinning = false;
  int _lockedReelsCount = 3; // Default at rest
  Worker? _spinWorker;

  @override
  void initState() {
    super.initState();
    _rumbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _rumbleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.8), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.8, end: -1.8), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -1.8, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: -1.2), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -1.2, end: 0.6), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.6, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _rumbleController,
      curve: Curves.easeInOut,
    ));

    if (Get.isRegistered<PremiumHomeController>()) {
      final controller = Get.find<PremiumHomeController>();
      _spinWorker = ever<bool>(controller.isReelsSpinning, _onSpinStateChanged);
    }
  }

  void _onSpinStateChanged(bool isSpinning) {
    if (isSpinning && !_wasSpinning) {
      _wasSpinning = true;
      if (mounted) {
        setState(() {
          _lockedReelsCount = 0;
        });
        _triggerCabinetRumble();
      }
    } else if (!isSpinning && _wasSpinning) {
      _wasSpinning = false;
    }
  }

  @override
  void dispose() {
    _spinWorker?.dispose();
    _rumbleController.dispose();
    super.dispose();
  }

  void _triggerCabinetRumble() {
    _rumbleController.forward(from: 0.0);
    _playSpinStartFeedback();
  }

  void _playSpinStartFeedback() {
    try {
      if (Get.isRegistered<AudioController>()) {
        final audio = Get.find<AudioController>();
        audio.triggerHaptic(HapticProfile.medium);
        audio.playEvent(AudioEvent.spinStart);
      }
    } catch (_) {}
  }

  void _onReelStopped() {
    if (!mounted) return;
    setState(() {
      _lockedReelsCount = math.min(3, _lockedReelsCount + 1);
    });
    _playReelStopFeedback();
    if (_lockedReelsCount == 3) {
      if (Get.isRegistered<PremiumHomeController>()) {
        Get.find<PremiumHomeController>().onReelsStopped();
      }
    }
  }

  void _playReelStopFeedback() {
    try {
      if (Get.isRegistered<AudioController>()) {
        final audio = Get.find<AudioController>();
        audio.triggerHaptic(HapticProfile.light);
        audio.playEvent(AudioEvent.reelStop);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PremiumHomeController>();

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Obx(() {
          final bool isSpinning = controller.isSpinning.value;
          final bool isReelsSpinning = controller.isReelsSpinning.value;

          // Evaluate winning combinations for visual highlighting
          final target1 = controller.reelTargetIndices[0];
          final target2 = controller.reelTargetIndices[1];
          final target3 = controller.reelTargetIndices[2];

          final bool doubleMatch = (target1 == target2) ||
              (target2 == target3) ||
              (target1 == target3);
          final bool isRestState = _lockedReelsCount >= 3;

          final bool r1Win = isRestState &&
              doubleMatch &&
              (target1 == target2 || target1 == target3);
          final bool r2Win = isRestState &&
              doubleMatch &&
              (target2 == target1 || target2 == target3);
          final bool r3Win = isRestState &&
              doubleMatch &&
              (target3 == target1 || target3 == target2);

          return AnimatedBuilder(
            animation: _rumbleAnimation,
            builder: (context, child) {
              final double shake = _rumbleAnimation.value;
              return Transform.translate(
                offset: Offset(shake, shake * 0.7),
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SlotMachineFrame(
                  isSpinning: isSpinning,
                  child: SlotViewport(
                    isSpinning: isSpinning,
                    lockedReelsCount: _lockedReelsCount,
                    child: Row(
                      children: [
                        // Reel 1
                        Expanded(
                          child: SlotReelColumn(
                            reelIndex: 0,
                            targetIndex: target1,
                            isSpinning: isReelsSpinning,
                            isWinning: r1Win,
                            onStopped: _onReelStopped,
                          ),
                        ),
                        const VerticalDivider(
                          color: Color(0xFF07050F),
                          width: 6,
                          thickness: 2,
                        ),
                        // Reel 2
                        Expanded(
                          child: SlotReelColumn(
                            reelIndex: 1,
                            targetIndex: target2,
                            isSpinning: isReelsSpinning,
                            isWinning: r2Win,
                            onStopped: _onReelStopped,
                          ),
                        ),
                        const VerticalDivider(
                          color: Color(0xFF07050F),
                          width: 6,
                          thickness: 2,
                        ),
                        // Reel 3
                        Expanded(
                          child: SlotReelColumn(
                            reelIndex: 2,
                            targetIndex: target3,
                            isSpinning: isReelsSpinning,
                            isWinning: r3Win,
                            onStopped: _onReelStopped,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Pedestal Stand
                const MachineBase(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class SlotMachineFrame extends StatelessWidget {
  final Widget child;
  final bool isSpinning;

  const SlotMachineFrame({
    super.key,
    required this.child,
    required this.isSpinning,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1535),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: PremiumColors.premiumGold,
          width: 3.5,
        ),
        boxShadow: [
          BoxShadow(
            color: PremiumColors.royalPurple
                .withValues(alpha: isSpinning ? 0.65 : 0.4),
            blurRadius: isSpinning ? 30 : 20,
            spreadRadius: isSpinning ? 4 : 2,
          ),
          BoxShadow(
            color: PremiumColors.electricBlue
                .withValues(alpha: isSpinning ? 0.22 : 0.12),
            blurRadius: isSpinning ? 40 : 30,
            spreadRadius: isSpinning ? -2 : -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: PremiumColors.premiumGold.withValues(alpha: 0.5),
                width: 1.5,
              ),
              gradient: const LinearGradient(
                colors: [Color(0xFF140F27), Color(0xFF07050F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecorativeLights(isSpinning: isSpinning),
            ),
          ),
        ],
      ),
    );
  }
}

class DecorativeLights extends StatefulWidget {
  final bool isSpinning;

  const DecorativeLights({
    super.key,
    required this.isSpinning,
  });

  @override
  State<DecorativeLights> createState() => _DecorativeLightsState();
}

class _DecorativeLightsState extends State<DecorativeLights>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    if (widget.isSpinning) {
      _flashController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant DecorativeLights oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning && !oldWidget.isSpinning) {
      _flashController.repeat(reverse: true);
    } else if (!widget.isSpinning && oldWidget.isSpinning) {
      _flashController.stop();
    }
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flashController,
      builder: (context, child) {
        return CustomPaint(
          painter: LEDLightsPainter(
            isSpinning: widget.isSpinning,
            flashProgress: _flashController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class LEDLightsPainter extends CustomPainter {
  final bool isSpinning;
  final double flashProgress;

  LEDLightsPainter({
    required this.isSpinning,
    required this.flashProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const double spacing = 22.0;
    const double margin = 6.0;

    final bool alternate = isSpinning && flashProgress > 0.5;

    for (double x = 12; x < size.width - 12; x += spacing) {
      _drawBulb(canvas, Offset(x, margin), paint,
          isCyan: ((x ~/ spacing) % 2 == 0) ^ alternate);
    }

    for (double y = 12; y < size.height - 12; y += spacing) {
      _drawBulb(canvas, Offset(margin, y), paint,
          isCyan: ((y ~/ spacing) % 2 != 0) ^ alternate);
    }

    for (double y = 12; y < size.height - 12; y += spacing) {
      _drawBulb(canvas, Offset(size.width - margin, y), paint,
          isCyan: ((y ~/ spacing) % 2 == 0) ^ alternate);
    }
  }

  void _drawBulb(Canvas canvas, Offset center, Paint paint,
      {required bool isCyan}) {
    final Color color =
        isCyan ? PremiumColors.electricBlue : PremiumColors.premiumGold;
    final double radiusBoost = isSpinning ? (flashProgress * 2.0) : 0.0;

    paint.shader = RadialGradient(
      colors: [
        color.withValues(alpha: isSpinning ? 0.7 : 0.5),
        Colors.transparent
      ],
      stops: const [0.2, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: 8 + radiusBoost));
    canvas.drawCircle(center, 8 + radiusBoost, paint);
    paint.shader = null;
    paint.color = Colors.white;
    canvas.drawCircle(center, 2.0, paint);
  }

  @override
  bool shouldRepaint(covariant LEDLightsPainter oldDelegate) =>
      oldDelegate.isSpinning != isSpinning ||
      oldDelegate.flashProgress != flashProgress;
}

class SlotViewport extends StatelessWidget {
  final Widget child;
  final bool isSpinning;
  final int lockedReelsCount;

  const SlotViewport({
    super.key,
    required this.child,
    required this.isSpinning,
    required this.lockedReelsCount,
  });

  @override
  Widget build(BuildContext context) {
    double lineOpacity = 0.15;
    if (lockedReelsCount == 1) {
      lineOpacity = 0.45;
    } else if (lockedReelsCount == 2) {
      lineOpacity = 0.75;
    } else if (lockedReelsCount >= 3) {
      lineOpacity = 1.0;
    }

    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF05030A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PremiumColors.royalPurple.withValues(alpha: 0.4),
          width: 2.0,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: child,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF05030A).withValues(alpha: 0.95),
                      const Color(0xFF05030A).withValues(alpha: 0.0),
                      const Color(0xFF05030A).withValues(alpha: 0.0),
                      const Color(0xFF05030A).withValues(alpha: 0.95),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.22, 0.78, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: isSpinning ? 0.20 : 0.08),
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: isSpinning ? 0.06 : 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: lineOpacity,
              child: isSpinning
                  ? const SleekBreathingAnimation(
                      minScale: 0.99,
                      maxScale: 1.01,
                      duration: Duration(milliseconds: 900),
                      child: WinningLine(),
                    )
                  : const WinningLine(),
            ),
          ),
        ],
      ),
    );
  }
}

class WinningLine extends StatelessWidget {
  const WinningLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PremiumColors.neonCyan, PremiumColors.electricBlue],
        ),
        boxShadow: [
          BoxShadow(
            color: PremiumColors.electricBlue.withValues(alpha: 0.8),
            blurRadius: 8,
            spreadRadius: 1.5,
          ),
        ],
      ),
    );
  }
}

// Ticker-Driven Frame-by-Frame Reel Motion Column
class SlotReelColumn extends StatefulWidget {
  final int reelIndex;
  final int targetIndex;
  final bool isSpinning;
  final bool isWinning;
  final VoidCallback onStopped;

  const SlotReelColumn({
    super.key,
    required this.reelIndex,
    required this.targetIndex,
    required this.isSpinning,
    required this.isWinning,
    required this.onStopped,
  });

  @override
  State<SlotReelColumn> createState() => _SlotReelColumnState();
}

class _SlotReelColumnState extends State<SlotReelColumn>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final ScrollController _scrollController = ScrollController();
  final double _itemHeight = 80.0;
  final int _symbolsCount = 10;
  final double _loopHeight = 800.0;

  double _offset = 800.0;
  double _velocity = 0.0;
  double _targetOffset = 0.0;
  double _stateTime = 0.0;
  double _lastElapsedSeconds = 0.0;

  SpinState _state = SpinState.rest;
  bool _wasSpinning = false;
  Timer? _stopTimer;

  late double _maxVelocity;
  late double _acceleration;
  late double _startBacklashOffset;

  @override
  void initState() {
    super.initState();
    _offset = _loopHeight + (widget.targetIndex - 1) * _itemHeight;

    final random = math.Random(widget.reelIndex);
    _maxVelocity = 1400.0 + random.nextDouble() * 200.0;
    _acceleration = 2200.0 + random.nextDouble() * 400.0;
    _startBacklashOffset = -12.0 - random.nextDouble() * 6.0;

    _ticker = createTicker(_onTick);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_offset);
      }
    });
  }

  @override
  void didUpdateWidget(covariant SlotReelColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning && !_wasSpinning) {
      _wasSpinning = true;
      _startSpinTimeline();
    } else if (!widget.isSpinning && _wasSpinning) {
      _wasSpinning = false;
      _stopSpinTimeline();
    }
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startSpinTimeline() {
    _stopTimer?.cancel();
    _stateTime = 0.0;
    _lastElapsedSeconds = 0.0;
    _state = SpinState.starting;
    if (!_ticker.isTicking) {
      _ticker.start();
    }
  }

  void _stopSpinTimeline() {
    final int delayMs = widget.reelIndex * 240;
    _stopTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      final double targetLocal = (widget.targetIndex - 1) * _itemHeight;
      final double minSlowdownDistance = 1200.0;
      final double absoluteStopGoal = _offset + minSlowdownDistance;

      final double remaining = absoluteStopGoal - targetLocal;
      final int loops = (remaining / _loopHeight).ceil();
      _targetOffset = targetLocal + (loops * _loopHeight);

      _stateTime = 0.0;
      _state = SpinState.slowing;
    });
  }

  void _onTick(Duration elapsed) {
    final double elapsedSeconds =
        elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    double dt = elapsedSeconds - _lastElapsedSeconds;
    _lastElapsedSeconds = elapsedSeconds;

    if (dt > 0.03) dt = 0.03;
    _stateTime += dt;

    switch (_state) {
      case SpinState.starting:
        const double startDuration = 0.25;
        final double t = (_stateTime / startDuration).clamp(0.0, 1.0);
        final double backlash = math.sin(t * math.pi) * _startBacklashOffset;
        _offset =
            _loopHeight + (widget.targetIndex - 1) * _itemHeight + backlash;
        _velocity = 0.0;

        if (_stateTime >= startDuration + (widget.reelIndex * 0.05)) {
          _state = SpinState.accelerating;
          _stateTime = 0.0;
        }
        break;

      case SpinState.accelerating:
        _velocity += _acceleration * dt;
        if (_velocity >= _maxVelocity) {
          _velocity = _maxVelocity;
          _state = SpinState.cruise;
          _stateTime = 0.0;
        }
        _offset += _velocity * dt;
        break;

      case SpinState.cruise:
        _velocity = _maxVelocity;
        _offset += _velocity * dt;
        break;

      case SpinState.slowing:
        final double distanceRemaining = _targetOffset - _offset;

        if (distanceRemaining <= 0) {
          _offset = _targetOffset;
          _state = SpinState.locking;
          _stateTime = 0.0;
        } else {
          _velocity =
              math.max(180.0, _maxVelocity * (distanceRemaining / 1200.0));
          _offset += _velocity * dt;

          if (distanceRemaining <= 120.0) {
            _state = SpinState.locking;
            _stateTime = 0.0;
          }
        }
        break;

      case SpinState.locking:
      case SpinState.bouncing:
        final double x = _offset - _targetOffset;
        final double springForce = -ReelPhysics.springK * x;
        final double dampingForce = -ReelPhysics.dampingC * _velocity;
        final double acceleration =
            (springForce + dampingForce) / ReelPhysics.mass;

        _velocity += acceleration * dt;
        _offset += _velocity * dt;

        if (_velocity.abs() < 0.35 && x.abs() < 0.35) {
          _offset = _targetOffset;
          _velocity = 0.0;
          _state = SpinState.rest;
          _ticker.stop();
          widget.onStopped();
        }
        break;

      case SpinState.rest:
      case SpinState.idle:
        _velocity = 0.0;
        break;
    }

    _wrapOffsetBounds();

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_offset);
    }
  }

  void _wrapOffsetBounds() {
    if (_offset >= 1600.0) {
      _offset -= _loopHeight;
      if (_state == SpinState.slowing ||
          _state == SpinState.locking ||
          _state == SpinState.bouncing) {
        _targetOffset -= _loopHeight;
      }
    } else if (_offset < 800.0) {
      _offset += _loopHeight;
      if (_state == SpinState.slowing ||
          _state == SpinState.locking ||
          _state == SpinState.bouncing) {
        _targetOffset += _loopHeight;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const int totalItems = 30;
    final bool isRest = _state == SpinState.rest;

    return ListView.builder(
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      itemExtent: _itemHeight,
      itemCount: totalItems,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final int symbolIndex = index % _symbolsCount;

        final bool isCenterPayline = symbolIndex == widget.targetIndex;
        final bool isFocused = !isRest || isCenterPayline;

        final bool showWinningLine = !Get.isRegistered<SettingsController>() ||
            Get.find<SettingsController>()
                .settings
                .value
                .gameplay
                .showWinningLine;
        final bool isWinningSymbol =
            isCenterPayline && widget.isWinning && showWinningLine;

        return Center(
          child: SlotSymbolTile(
            symbolIndex: symbolIndex,
            velocity: _velocity,
            isFocused: isFocused,
            isWinning: isWinningSymbol,
          ),
        );
      },
    );
  }
}

// Collectible capsule symbol tile
class SlotSymbolTile extends StatelessWidget {
  final int symbolIndex;
  final double velocity;
  final bool isFocused;
  final bool isWinning;

  const SlotSymbolTile({
    super.key,
    required this.symbolIndex,
    this.velocity = 0.0,
    required this.isFocused,
    this.isWinning = false,
  });

  @override
  Widget build(BuildContext context) {
    final double speedRatio = (velocity.abs() / 1500.0).clamp(0.0, 1.0);

    Widget tileContent = Container(
      width: 68,
      height: 68,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PremiumColors.purpleGlass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinning
              ? PremiumColors.premiumGold
              : PremiumColors.royalPurple.withValues(alpha: 0.35),
          width: isWinning ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isWinning
                ? PremiumColors.premiumGold.withValues(alpha: 0.2)
                : PremiumColors.electricBlue.withValues(alpha: 0.04),
            blurRadius: isWinning ? 8 : 4,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [Color(0xFF1B1437), Color(0xFF07050F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Transform.scale(
          scaleY: 1.0 + (speedRatio * 0.12),
          alignment: Alignment.center,
          child: Opacity(
            opacity: 1.0 - (speedRatio * 0.25),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomPaint(
                painter: SlotSymbolPainter(symbolIndex: symbolIndex),
                size: const Size(60, 60),
              ),
            ),
          ),
        ),
      ),
    );

    // Apply symbol win celebration (glow and breathing pulse)
    if (isWinning) {
      tileContent = GlowingEffect(
        glowColor: PremiumColors.premiumGold,
        maxSpread: 8.0,
        minSpread: 2.0,
        child: SleekBreathingAnimation(
          minScale: 0.96,
          maxScale: 1.04,
          duration: const Duration(milliseconds: 1000),
          child: tileContent,
        ),
      );
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: isFocused ? 1.0 : 0.65,
      child: tileContent,
    );
  }
}

class SlotSymbolPainter extends CustomPainter {
  final int symbolIndex;

  SlotSymbolPainter({required this.symbolIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    switch (symbolIndex) {
      case 0:
        _drawDiamond(canvas, cx, cy, w * 0.7, paint);
        break;
      case 1:
        _drawCrown(canvas, cx, cy, w * 0.75, paint);
        break;
      case 2:
        _drawClover(canvas, cx, cy, w * 0.7, paint);
        break;
      case 3:
        _drawBell(canvas, cx, cy, w * 0.7, paint);
        break;
      case 4:
        _drawCherries(canvas, cx, cy, w * 0.75, paint);
        break;
      case 5:
        _drawGoldBar(canvas, cx, cy, w * 0.75, paint);
        break;
      case 6:
        _drawTreasureChest(canvas, cx, cy, w * 0.75, paint);
        break;
      case 7:
        _drawLuckySeven(canvas, cx, cy, w * 0.7, paint);
        break;
      case 8:
        _drawRuby(canvas, cx, cy, w * 0.7, paint);
        break;
      case 9:
      default:
        _drawEmerald(canvas, cx, cy, w * 0.7, paint);
        break;
    }
  }

  void _drawDiamond(
      Canvas canvas, double cx, double cy, double d, Paint paint) {
    final double r = d / 2;
    final path = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r, cy)
      ..lineTo(cx, cy + r)
      ..lineTo(cx - r, cy)
      ..close();

    paint.shader = const RadialGradient(
      colors: [Color(0xFF80F3FF), Color(0xFF00E5FF), Color(0xFF0060B7)],
      stops: [0.0, 0.4, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawPath(path, paint);
    paint.shader = null;

    final facetPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), facetPaint);
    canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), facetPaint);

    paint.color = Colors.white.withValues(alpha: 0.25);
    final innerFacet = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r * 0.4, cy - r * 0.4)
      ..lineTo(cx, cy)
      ..lineTo(cx - r * 0.4, cy - r * 0.4)
      ..close();
    canvas.drawPath(innerFacet, paint);
  }

  void _drawCrown(Canvas canvas, double cx, double cy, double d, Paint paint) {
    final double r = d / 2;
    final path = Path()
      ..moveTo(cx - r, cy + r * 0.6)
      ..lineTo(cx + r, cy + r * 0.6)
      ..lineTo(cx + r * 0.9, cy - r * 0.3)
      ..lineTo(cx + r * 0.5, cy + r * 0.1)
      ..lineTo(cx, cy - r * 0.6)
      ..lineTo(cx - r * 0.5, cy + r * 0.1)
      ..lineTo(cx - r * 0.9, cy - r * 0.3)
      ..close();

    paint.shader = PremiumGradients.gold
        .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawPath(path, paint);
    paint.shader = null;

    paint.color = PremiumColors.dangerRed;
    canvas.drawCircle(Offset(cx, cy - r * 0.6), 3, paint);
    canvas.drawCircle(Offset(cx - r * 0.9, cy - r * 0.3), 2.5, paint);
    canvas.drawCircle(Offset(cx + r * 0.9, cy - r * 0.3), 2.5, paint);

    paint.color = const Color(0xFF8B6508);
    canvas.drawRect(
        Rect.fromLTRB(cx - r * 0.8, cy + r * 0.4, cx + r * 0.8, cy + r * 0.55),
        paint);
  }

  void _drawClover(Canvas canvas, double cx, double cy, double d, Paint paint) {
    final double r = d / 2;
    paint.shader = const RadialGradient(
      colors: [
        Color(0xFF81C784),
        PremiumColors.successGreen,
        Color(0xFF004D40)
      ],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    final double offset = r * 0.45;
    canvas.drawCircle(Offset(cx - offset, cy), r * 0.45, paint);
    canvas.drawCircle(Offset(cx + offset, cy), r * 0.45, paint);
    canvas.drawCircle(Offset(cx, cy - offset), r * 0.45, paint);
    canvas.drawCircle(Offset(cx, cy + offset), r * 0.45, paint);

    paint.shader = null;
    paint.color = const Color(0xFF004D40);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4.0;
    final stemPath = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(
          cx + r * 0.3, cy + r * 0.6, cx + r * 0.4, cy + r * 0.9);
    canvas.drawPath(stemPath, paint);
    paint.style = PaintingStyle.fill;
  }

  void _drawBell(Canvas canvas, double cx, double cy, double d, Paint paint) {
    final double r = d / 2;
    final path = Path()
      ..moveTo(cx - r * 0.2, cy - r * 0.7)
      ..lineTo(cx + r * 0.2, cy - r * 0.7)
      ..quadraticBezierTo(
          cx + r * 0.5, cy - r * 0.2, cx + r * 0.6, cy + r * 0.3)
      ..lineTo(cx - r * 0.6, cy + r * 0.3)
      ..quadraticBezierTo(
          cx - r * 0.5, cy - r * 0.2, cx - r * 0.2, cy - r * 0.7)
      ..close();

    paint.shader = PremiumGradients.gold
        .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawPath(path, paint);
    paint.shader = null;

    paint.color = const Color(0xFF8B6508);
    canvas.drawCircle(Offset(cx, cy + r * 0.4), r * 0.25, paint);
    paint.color = PremiumColors.premiumGold;
    canvas.drawCircle(Offset(cx, cy + r * 0.4), r * 0.15, paint);
  }

  void _drawCherries(
      Canvas canvas, double cx, double cy, double d, Paint paint) {
    final double r = d / 2;

    paint.color = const Color(0xFF33691E);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    final stem = Path()
      ..moveTo(cx - r * 0.3, cy + r * 0.2)
      ..quadraticBezierTo(
          cx - r * 0.1, cy - r * 0.5, cx + r * 0.2, cy - r * 0.6)
      ..moveTo(cx + r * 0.3, cy + r * 0.2)
      ..quadraticBezierTo(
          cx + r * 0.1, cy - r * 0.5, cx + r * 0.2, cy - r * 0.6);
    canvas.drawPath(stem, paint);

    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF558B2F);
    final leaf = Path()
      ..moveTo(cx + r * 0.2, cy - r * 0.6)
      ..quadraticBezierTo(
          cx - r * 0.1, cy - r * 0.4, cx - r * 0.2, cy - r * 0.5)
      ..quadraticBezierTo(
          cx + r * 0.05, cy - r * 0.7, cx + r * 0.2, cy - r * 0.6)
      ..close();
    canvas.drawPath(leaf, paint);

    paint.shader = const RadialGradient(
      colors: [Color(0xFFFF5252), PremiumColors.dangerRed, Color(0xFF880E4F)],
      stops: [0.1, 0.6, 1.0],
    ).createShader(Rect.fromCircle(
        center: Offset(cx - r * 0.3, cy + r * 0.25), radius: r * 0.35));
    canvas.drawCircle(Offset(cx - r * 0.3, cy + r * 0.25), r * 0.35, paint);

    paint.shader = const RadialGradient(
      colors: [Color(0xFFFF5252), PremiumColors.dangerRed, Color(0xFF880E4F)],
      stops: [0.1, 0.6, 1.0],
    ).createShader(Rect.fromCircle(
        center: Offset(cx + r * 0.3, cy + r * 0.25), radius: r * 0.35));
    canvas.drawCircle(Offset(cx + r * 0.3, cy + r * 0.25), r * 0.35, paint);
    paint.shader = null;

    paint.color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(Offset(cx - r * 0.4, cy + r * 0.15), 3, paint);
    canvas.drawCircle(Offset(cx + r * 0.2, cy + r * 0.15), 3, paint);
  }

  void _drawGoldBar(
      Canvas canvas, double cx, double cy, double d, Paint paint) {
    final double r = d / 2;
    final path = Path()
      ..moveTo(cx - r * 0.7, cy + r * 0.4)
      ..lineTo(cx + r * 0.7, cy + r * 0.4)
      ..lineTo(cx + r * 0.45, cy - r * 0.4)
      ..lineTo(cx - r * 0.45, cy - r * 0.4)
      ..close();

    paint.shader = PremiumGradients.gold
        .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawPath(path, paint);
    paint.shader = null;

    paint.color = Colors.white.withValues(alpha: 0.3);
    final shine = Path()
      ..moveTo(cx - r * 0.45, cy - r * 0.4)
      ..lineTo(cx + r * 0.45, cy - r * 0.4)
      ..lineTo(cx + r * 0.4, cy - r * 0.15)
      ..lineTo(cx - r * 0.4, cy - r * 0.15)
      ..close();
    canvas.drawPath(shine, paint);

    final linePaint = Paint()
      ..color = const Color(0xFF8B6508).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, linePaint);
  }

  void _drawTreasureChest(
      Canvas canvas, double cx, double cy, double d, Paint paint) {
    final double r = d / 2;

    paint.shader = const LinearGradient(
      colors: [Color(0xFF8D6E63), Color(0xFF4E342E)],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(
                cx - r * 0.7, cy - r * 0.1, cx + r * 0.7, cy + r * 0.5),
            const Radius.circular(4)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(
                cx - r * 0.7, cy - r * 0.6, cx + r * 0.7, cy - r * 0.15),
            const Radius.circular(8)),
        paint);
    paint.shader = null;

    paint.shader = PremiumGradients.gold
        .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawRect(
        Rect.fromLTRB(cx - r * 0.7, cy - r * 0.6, cx - r * 0.5, cy + r * 0.5),
        paint);
    canvas.drawRect(
        Rect.fromLTRB(cx + r * 0.5, cy - r * 0.6, cx + r * 0.7, cy + r * 0.5),
        paint);
    canvas.drawCircle(Offset(cx, cy - r * 0.1), 7.0, paint);
    paint.shader = null;

    paint.color = Colors.black;
    canvas.drawCircle(Offset(cx, cy - r * 0.1), 2.5, paint);
  }

  void _drawLuckySeven(
      Canvas canvas, double cx, double cy, double d, Paint paint) {
    final double r = d / 2;
    final path = Path()
      ..moveTo(cx - r * 0.5, cy - r * 0.8)
      ..lineTo(cx + r * 0.5, cy - r * 0.8)
      ..lineTo(cx + r * 0.45, cy - r * 0.4)
      ..lineTo(cx - r * 0.05, cy + r * 0.8)
      ..lineTo(cx - r * 0.4, cy + r * 0.8)
      ..lineTo(cx + r * 0.1, cy - r * 0.4)
      ..lineTo(cx - r * 0.5, cy - r * 0.4)
      ..close();

    paint.shader = const LinearGradient(
      colors: [PremiumColors.dangerRed, Color(0xFFFF5252), Color(0xFFFFAB40)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawPath(path, paint);
    paint.shader = null;

    final borderPaint = Paint()
      ..shader = PremiumGradients.gold
          .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, borderPaint);
  }

  void _drawRuby(Canvas canvas, double cx, double cy, double d, Paint paint) {
    final double r = d / 2;
    final double offset = r * 0.4;
    final path = Path()
      ..moveTo(cx - offset, cy - r)
      ..lineTo(cx + offset, cy - r)
      ..lineTo(cx + r, cy - offset)
      ..lineTo(cx + r, cy + offset)
      ..lineTo(cx + offset, cy + r)
      ..lineTo(cx - offset, cy + r)
      ..lineTo(cx - r, cy + offset)
      ..lineTo(cx - r, cy - offset)
      ..close();

    paint.shader = const RadialGradient(
      colors: [Color(0xFFFF8A80), PremiumColors.dangerRed, Color(0xFF880E4F)],
      stops: [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawPath(path, paint);
    paint.shader = null;

    final facetPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, facetPaint);

    canvas.drawLine(Offset(cx - offset, cy - r),
        Offset(cx - offset * 0.4, cy - r * 0.4), facetPaint);
    canvas.drawLine(Offset(cx + offset, cy - r),
        Offset(cx + offset * 0.4, cy - r * 0.4), facetPaint);
    canvas.drawLine(Offset(cx - r, cy - offset),
        Offset(cx - r * 0.4, cy - offset * 0.4), facetPaint);
    canvas.drawLine(Offset(cx + r, cy - offset),
        Offset(cx + r * 0.4, cy - offset * 0.4), facetPaint);
  }

  void _drawEmerald(
      Canvas canvas, double cx, double cy, double d, Paint paint) {
    final double r = d / 2;
    final path = Path();
    path.moveTo(cx, cy + r * 0.7);
    path.cubicTo(cx - r * 1.2, cy - r * 0.6, cx - r * 0.5, cy - r * 1.1, cx,
        cy - r * 0.4);
    path.moveTo(cx, cy + r * 0.7);
    path.cubicTo(cx + r * 1.2, cy - r * 0.6, cx + r * 0.5, cy - r * 1.1, cx,
        cy - r * 0.4);
    path.close();

    paint.shader = const RadialGradient(
      colors: [
        Color(0xFFA5D6A7),
        PremiumColors.successGreen,
        Color(0xFF1B5E20)
      ],
      stops: [0.0, 0.6, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawPath(path, paint);
    paint.shader = null;

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MachineBase extends StatelessWidget {
  const MachineBase({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BaseClipper(),
      child: Container(
        height: 22,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: PremiumGradients.gold,
          border: Border(
            top: BorderSide(
              color: PremiumColors.premiumGold.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class BaseClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.08, 0);
    path.lineTo(size.width * 0.92, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
