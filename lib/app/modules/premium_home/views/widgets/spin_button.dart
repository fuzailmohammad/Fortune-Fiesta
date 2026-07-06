import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/animations/breathing_animation.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../controllers/premium_home_controller.dart';

enum SpinButtonState {
  normal,
  pressed,
  disabled,
  loading,
  insufficientCoins,
  vipFree,
}

class SpinSection extends StatelessWidget {
  const SpinSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PremiumHomeController>();

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Obx(() {
          final bool isSpinning = controller.isSpinning.value;
          final int coins = controller.coins.value;

          // Determine button state reactively
          SpinButtonState state = SpinButtonState.normal;
          if (isSpinning) {
            state = SpinButtonState.loading;
          } else if (coins < 100) {
            state = SpinButtonState.insufficientCoins;
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: FractionallySizedBox(
                widthFactor: 0.85,
                child: SleekBreathingAnimation(
                  minScale: 0.98,
                  maxScale: 1.01,
                  duration: const Duration(seconds: 2),
                  child: SpinButton(
                    state: state,
                    onPressed: controller.spin,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class SpinButton extends StatelessWidget {
  final SpinButtonState state;
  final VoidCallback onPressed;

  const SpinButton({
    super.key,
    required this.state,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStyleConfig();
    final bool canPress =
        state != SpinButtonState.disabled && state != SpinButtonState.loading;

    return TactilePressEffect(
      scaleFactor: canPress ? 0.94 : 1.0, // Scale down on press if interactive
      onPressed: canPress ? onPressed : null,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: config.gradient,
          border: Border.all(
            color: config.borderColor,
            width: 3.0,
          ),
          boxShadow: [
            BoxShadow(
              color: config.glowColor.withValues(
                alpha: state == SpinButtonState.loading ? 0.2 : 0.45,
              ),
              blurRadius: 12,
              spreadRadius: 2.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glass reflection highlight
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: PremiumGradients.glassHighlight,
                ),
              ),
            ),

            // Content Layout: Icon, Text, Cost
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Icon
                  SpinIcon(state: state, iconColor: config.textColor),

                  // Center: Text Label
                  Expanded(
                    child: Center(
                      child: Text(
                        config.text,
                        style: PremiumTypography.numbersStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: config.textColor,
                          shadows: [
                            Shadow(
                              color: config.glowColor.withValues(alpha: 0.6),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Right: Cost Badge
                  SpinCost(state: state, costColor: config.textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ButtonStyleConfig _getStyleConfig() {
    switch (state) {
      case SpinButtonState.loading:
        return _ButtonStyleConfig(
          text: 'SPINNING...',
          gradient: const LinearGradient(
            colors: [Color(0xFF3B0B66), Color(0xFF1B1535)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderColor: PremiumColors.royalPurple.withValues(alpha: 0.4),
          textColor: PremiumColors.royalPurple,
          glowColor: Colors.transparent,
        );
      case SpinButtonState.insufficientCoins:
        return _ButtonStyleConfig(
          text: 'NO COINS',
          gradient: const LinearGradient(
            colors: [PremiumColors.dangerRed, Color(0xFFB71C1C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderColor: Colors.white.withValues(alpha: 0.7),
          textColor: Colors.white,
          glowColor: PremiumColors.dangerRed,
        );
      case SpinButtonState.disabled:
        return _ButtonStyleConfig(
          text: 'LOCKED',
          gradient: const LinearGradient(
            colors: [Color(0xFF424242), Color(0xFF212121)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderColor: const Color(0xFF757575),
          textColor: const Color(0xFF9E9E9E),
          glowColor: Colors.transparent,
        );
      case SpinButtonState.vipFree:
        return _ButtonStyleConfig(
          text: 'FREE SPIN',
          gradient: PremiumGradients.neonBlue,
          borderColor: Colors.white,
          textColor: PremiumColors.richBlack,
          glowColor: PremiumColors.electricBlue,
        );
      case SpinButtonState.pressed:
      case SpinButtonState.normal:
        return _ButtonStyleConfig(
          text: 'SPIN NOW',
          gradient: PremiumGradients.gold,
          borderColor: Colors.white,
          textColor: PremiumColors.richBlack,
          glowColor: PremiumColors.premiumGold,
        );
    }
  }
}

class _ButtonStyleConfig {
  final String text;
  final Gradient gradient;
  final Color borderColor;
  final Color textColor;
  final Color glowColor;

  _ButtonStyleConfig({
    required this.text,
    required this.gradient,
    required this.borderColor,
    required this.textColor,
    required this.glowColor,
  });
}

class SpinIcon extends StatelessWidget {
  final SpinButtonState state;
  final Color iconColor;

  const SpinIcon({
    super.key,
    required this.state,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.bolt_rounded;
    if (state == SpinButtonState.loading) {
      iconData = Icons.autorenew_rounded;
    } else if (state == SpinButtonState.insufficientCoins) {
      iconData = Icons.error_outline_rounded;
    } else if (state == SpinButtonState.disabled) {
      iconData = Icons.lock_outline_rounded;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 24,
    );
  }
}

class SpinCost extends StatelessWidget {
  final SpinButtonState state;
  final Color costColor;

  const SpinCost({
    super.key,
    required this.state,
    required this.costColor,
  });

  @override
  Widget build(BuildContext context) {
    if (state == SpinButtonState.loading || state == SpinButtonState.disabled) {
      return const SizedBox(width: 24);
    }

    final isNormal = state == SpinButtonState.normal;
    final isFree = state == SpinButtonState.vipFree;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isNormal
            ? PremiumColors.richBlack
            : costColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isNormal
              ? PremiumColors.premiumGold.withValues(alpha: 0.3)
              : costColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        isFree ? 'FREE' : '100',
        style: TextStyle(
          color: isNormal ? PremiumColors.premiumGold : costColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
