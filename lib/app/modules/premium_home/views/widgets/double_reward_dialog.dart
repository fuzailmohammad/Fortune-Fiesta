import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/animations/breathing_animation.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../../../data/models/ad_model.dart';
import '../../controllers/ad_controller.dart';

class DoubleRewardDialog extends StatelessWidget {
  final int baseAmount;
  final String rewardType;
  final VoidCallback onDouble;
  final VoidCallback onCollectNormally;

  const DoubleRewardDialog({
    super.key,
    required this.baseAmount,
    required this.rewardType,
    required this.onDouble,
    required this.onCollectNormally,
  });

  @override
  Widget build(BuildContext context) {
    // Use existing AdController from binding
    if (!Get.isRegistered<AdController>()) return const SizedBox.shrink();
    final adController = Get.find<AdController>();

    final bool isCoins = rewardType == 'coins';
    final int doubleAmount = baseAmount * 2;
    final bool adAvailable = adController.canShowAd(AdPlacement.doubleWin);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF140F27).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: PremiumColors.premiumGold,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: PremiumColors.royalPurple.withValues(alpha: 0.4),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Multiplying Header Title
            const Icon(
              Icons.stars_rounded,
              color: PremiumColors.premiumGold,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'CONGRATULATIONS!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            // Base vs Multiplied values
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '+$baseAmount',
                  style: const TextStyle(
                    color: Colors.white30,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: PremiumColors.premiumGold,
                  size: 20,
                ),
                const SizedBox(width: 16),
                Text(
                  '+$doubleAmount',
                  style: const TextStyle(
                    color: PremiumColors.premiumGold,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(color: Colors.orange, blurRadius: 10),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isCoins ? 'GOLD COINS' : 'DIAMONDS',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),

            const SizedBox(height: 24),

            // Double reward Ad button
            if (adAvailable)
              SleekBreathingAnimation(
                minScale: 0.96,
                maxScale: 1.04,
                child: TactilePressEffect(
                  onPressed: () {
                    adController.showRewardedAd(
                      onComplete: onDouble,
                      onError: () {
                        // Safe fallback on fail
                        onCollectNormally();
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: PremiumGradients.gold,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              PremiumColors.premiumGold.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_fill_rounded,
                          color: PremiumColors.richBlack,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'DOUBLE REWARD',
                          style: TextStyle(
                            color: PremiumColors.richBlack,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              // If ad is not preloaded or on limit cooldown
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'AD COOLDOWN ACTIVE',
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),

            const SizedBox(height: 12),

            // Regular Collect button
            TactilePressEffect(
              onPressed: onCollectNormally,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'COLLECT NORMALLY',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
