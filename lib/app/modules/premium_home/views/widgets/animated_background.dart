import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/animations/particle_background.dart';

class AnimatedBackground extends StatelessWidget {
  final Widget child;
  final bool isSpinning;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.isSpinning = false,
  });

  @override
  Widget build(BuildContext context) {
    return SleekParticleBackground(
      isSpinning: isSpinning,
      child: child,
    );
  }
}
