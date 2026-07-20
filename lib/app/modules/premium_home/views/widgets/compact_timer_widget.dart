import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/animations/breathing_animation.dart';
import 'package:fortune_fiesta/app/theme/animations/glow_effects.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../controllers/retention_controller.dart';
import '../retention_dashboard_screen.dart';

class CompactTimerWidget extends StatelessWidget {
  const CompactTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RetentionController>()) return const SizedBox.shrink();
    final controller = Get.find<RetentionController>();

    return Obx(() {
      final int sec = controller.hourlyTimerSeconds.value;
      final bool isReady = sec == 0;

      if (isReady) {
        // Pulsing, glowing claim-ready gift button
        return GlowingEffect(
          glowColor: PremiumColors.premiumGold,
          maxSpread: 6.0,
          child: SleekBreathingAnimation(
            minScale: 0.94,
            maxScale: 1.06,
            duration: const Duration(milliseconds: 900),
            child: TactilePressEffect(
              onPressed: () => controller.claimHourlyGift(),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: PremiumGradients.gold,
                  borderRadius: BorderRadius.circular(19),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumColors.premiumGold.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.card_giftcard_rounded,
                      color: PremiumColors.richBlack,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'GIFT',
                      style: TextStyle(
                        color: PremiumColors.richBlack,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        // Standard ticking countdown capsule
        return TactilePressEffect(
          onPressed: () {
            Get.to(() => const RetentionDashboardScreen());
          },
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: PremiumColors.purpleGlass.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: PremiumColors.royalPurple.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_filled_rounded,
                  color: Colors.white60,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTime(sec),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  String _formatTime(int totalSecs) {
    final int m = (totalSecs % 3600) ~/ 60;
    final int s = totalSecs % 60;

    final String ms = m.toString().padLeft(2, '0');
    final String ss = s.toString().padLeft(2, '0');
    return '$ms:$ss';
  }
}
