import 'package:flutter/material.dart';

class GlowingEffect extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double maxSpread;
  final double minSpread;
  final Duration duration;

  const GlowingEffect({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF00E5FF),
    this.maxSpread = 6.0,
    this.minSpread = 1.0,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<GlowingEffect> createState() => _GlowingEffectState();
}

class _GlowingEffectState extends State<GlowingEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: widget.minSpread,
      end: widget.maxSpread,
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
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.35),
                blurRadius: _glowAnimation.value * 2.5,
                spreadRadius: _glowAnimation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
