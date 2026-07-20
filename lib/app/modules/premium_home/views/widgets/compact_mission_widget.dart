import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/data/models/mission_model.dart';
import 'package:fortune_fiesta/app/theme/animations/breathing_animation.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../controllers/mission_controller.dart';
import '../missions_screen.dart';

class CompactMissionWidget extends StatelessWidget {
  const CompactMissionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MissionController>()) return const SizedBox.shrink();
    final controller = Get.find<MissionController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
      child: Obx(() {
        // Find highest priority incomplete mission
        final mission = controller.activeMissions.firstWhereOrNull(
          (m) => m.state != MissionState.claimed,
        );

        if (mission == null) {
          return const SizedBox.shrink(); // All missions claimed!
        }

        final double progress =
            (mission.currentValue / mission.targetValue).clamp(0.0, 1.0);
        final bool isCompleted = mission.state == MissionState.completed;

        return TactilePressEffect(
          onPressed: () {
            Get.to(() => const MissionsScreen());
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PremiumColors.purpleGlass.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompleted
                    ? PremiumColors.premiumGold
                    : PremiumColors.royalPurple.withValues(alpha: 0.2),
                width: isCompleted ? 1.5 : 1.0,
              ),
              boxShadow: [
                if (isCompleted)
                  BoxShadow(
                    color: PremiumColors.premiumGold.withValues(alpha: 0.12),
                    blurRadius: 10,
                  ),
              ],
            ),
            child: Row(
              children: [
                // Icon indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF07050F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getMissionIcon(mission.id),
                    color: isCompleted
                        ? PremiumColors.premiumGold
                        : PremiumColors.electricBlue,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // Title & Mini Progress Bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mission.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Progress bar with indicator text
                      Row(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 350),
                                  height: 6,
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: progress,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            PremiumColors.neonCyan,
                                            PremiumColors.electricBlue
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${mission.currentValue}/${mission.targetValue}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Claim Button or Reward Icon
                if (isCompleted)
                  SleekBreathingAnimation(
                    minScale: 0.94,
                    maxScale: 1.06,
                    duration: const Duration(milliseconds: 900),
                    child: TactilePressEffect(
                      onPressed: () => controller.claimMission(mission.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: PremiumGradients.gold,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: PremiumColors.premiumGold
                                  .withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Text(
                          'CLAIM',
                          style: TextStyle(
                            color: PremiumColors.richBlack,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  // Reward value representation
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRewardIcon(mission.rewardType),
                        color: PremiumColors.premiumGold,
                        size: 13,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '+${mission.rewardValue}',
                        style: const TextStyle(
                          color: PremiumColors.premiumGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  IconData _getMissionIcon(String id) {
    if (id.contains('spin')) {
      return Icons.casino_outlined;
    } else if (id.contains('win')) {
      return Icons.workspace_premium_outlined;
    } else {
      return Icons.monetization_on_outlined;
    }
  }

  IconData _getRewardIcon(String type) {
    if (type == 'xp') {
      return Icons.star_rounded;
    } else if (type == 'diamonds') {
      return Icons.diamond_rounded;
    } else {
      return Icons.monetization_on_rounded;
    }
  }
}
