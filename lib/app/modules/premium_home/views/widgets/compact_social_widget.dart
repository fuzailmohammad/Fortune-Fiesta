import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/animations/breathing_animation.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../controllers/social_controller.dart';
import '../social_hub_screen.dart';

class CompactSocialWidget extends StatelessWidget {
  const CompactSocialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SocialController>()) return const SizedBox.shrink();
    final controller = Get.find<SocialController>();

    return Obx(() {
      final profile = controller.playerProfile.value;
      if (profile == null) return const SizedBox.shrink();

      // Find player rank in leaderboard list
      final playerRow = controller.leaderboard
          .firstWhereOrNull((e) => e.name.contains('You'));
      final int rank = playerRow?.rank ?? 4;

      return TactilePressEffect(
        onPressed: () {
          Get.to(() => const SocialHubScreen());
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: PremiumColors.purpleGlass.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: PremiumColors.electricBlue.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SleekBreathingAnimation(
                    minScale: 0.9,
                    maxScale: 1.1,
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: PremiumColors.premiumGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile.league.name.toUpperCase()} LEAGUE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Title: ${profile.title}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Rank Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: PremiumColors.premiumGold.withValues(alpha: 0.25)),
                ),
                child: Text(
                  'RANK #$rank',
                  style: const TextStyle(
                    color: PremiumColors.premiumGold,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
