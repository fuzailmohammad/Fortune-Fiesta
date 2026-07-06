import 'dart:async';

import 'package:flutter/material.dart';

class JuiceWiggleDecorator extends StatefulWidget {
  final Widget child;
  final Duration interval;

  const JuiceWiggleDecorator({
    super.key,
    required this.child,
    this.interval = const Duration(seconds: 8),
  });

  @override
  State<JuiceWiggleDecorator> createState() => _JuiceWiggleDecoratorState();
}

class _JuiceWiggleDecoratorState extends State<JuiceWiggleDecorator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _angleAnimation;
  Timer? _wiggleTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    // Elastic swinging wiggle back and forth
    _angleAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 0.12)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: 0.12, end: -0.10)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: -0.10, end: 0.07)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: 0.07, end: -0.04)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: -0.04, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 20),
    ]).animate(_controller);

    _startPeriodicWiggles();
  }

  void _startPeriodicWiggles() {
    _wiggleTimer = Timer.periodic(widget.interval, (_) {
      if (mounted) {
        _controller.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _wiggleTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _angleAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _angleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

class JuiceShimmerDecorator extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const JuiceShimmerDecorator({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2200),
  });

  @override
  State<JuiceShimmerDecorator> createState() => _JuiceShimmerDecoratorState();
}

class _JuiceShimmerDecoratorState extends State<JuiceShimmerDecorator>
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
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.white,
                Colors.white30,
                Colors.white,
              ],
              stops: const [0.35, 0.5, 0.65],
              // Map Sweep offset
              transform: _SlideGradientTransform(_controller.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlideGradientTransform extends GradientTransform {
  final double percent;
  const _SlideGradientTransform(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Translate gradient horizontally based on time percent
    final double dx = bounds.width * (percent * 3.0 - 1.5);
    return Matrix4.translationValues(dx, 0, 0);
  }
}
