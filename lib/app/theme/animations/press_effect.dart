import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortune_fiesta/app/data/models/audio_model.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/audio_controller.dart';
import 'package:get/get.dart';

class TactilePressEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double scaleFactor;
  final Duration duration;

  const TactilePressEffect({
    super.key,
    required this.child,
    this.onPressed,
    this.scaleFactor = 0.94,
    this.duration = const Duration(milliseconds: 90),
  });

  @override
  State<TactilePressEffect> createState() => _TactilePressEffectState();
}

class _TactilePressEffectState extends State<TactilePressEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
    _controller.forward();

    // Play light haptic and sound clicks globally
    try {
      if (Get.isRegistered<AudioController>()) {
        final audio = Get.find<AudioController>();
        audio.triggerHaptic(HapticProfile.light);
        audio.playEvent(AudioEvent.buttonPress);
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (_) {
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!_isPressed) return;
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _isPressed = false);
      }
    });
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    if (!_isPressed) return;
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
