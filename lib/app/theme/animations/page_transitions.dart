import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PremiumTransitions {
  PremiumTransitions._();

  // Premium pre-configured fade-scale transition for GetX routes
  static const Transition defaultTransition = Transition.fadeIn;
  static const Duration defaultDuration = Duration(milliseconds: 320);

  // Custom PageRoute builder for non-GetX routes
  static Route createScaleFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scale = Tween<double>(begin: 0.96, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeIn),
        );
        return FadeTransition(
          opacity: opacity,
          child: ScaleTransition(
            scale: scale,
            child: child,
          ),
        );
      },
    );
  }
}
