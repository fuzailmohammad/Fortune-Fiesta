import 'package:flutter/material.dart';

class SleekBreathingAnimation extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;

  const SleekBreathingAnimation({
    super.key,
    required this.child,
    this.minScale = 0.98,
    this.maxScale = 1.02,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<SleekBreathingAnimation> createState() => _SleekBreathingAnimationState();
}

class _SleekBreathingAnimationState extends State<SleekBreathingAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}
