import 'package:flutter/material.dart';

class PremiumShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const PremiumShimmer({
    super.key,
    required this.width,
    required this.height,
    this.radius = 12.0,
  });

  @override
  State<PremiumShimmer> createState() => _PremiumShimmerState();
}

class _PremiumShimmerState extends State<PremiumShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF140F27).withValues(alpha: 0.55),
                const Color(0xFFFFD700).withValues(alpha: 0.08),
                const Color(0xFF140F27).withValues(alpha: 0.55),
              ],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment(_shimmerAnimation.value - 1, -0.3),
              end: Alignment(_shimmerAnimation.value + 1, 0.3),
            ),
          ),
        );
      },
    );
  }
}
