import 'dart:math' as math;

import 'package:flutter/material.dart';

class SleekFloatingAnimation extends StatefulWidget {
  final Widget child;
  final double maxOffset;
  final Duration duration;

  const SleekFloatingAnimation({
    super.key,
    required this.child,
    this.maxOffset = 4.0,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<SleekFloatingAnimation> createState() => _SleekFloatingAnimationState();
}

class _SleekFloatingAnimationState extends State<SleekFloatingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double angle = _controller.value * 2.0 * math.pi;
        final double offset = math.sin(angle) * widget.maxOffset;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
