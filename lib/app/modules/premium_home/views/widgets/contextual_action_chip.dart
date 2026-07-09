import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/data/models/mission_model.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/liveops_controller.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/mission_controller.dart';
import 'package:fortune_fiesta/app/modules/premium_home/views/event_hub_screen.dart';
import 'package:fortune_fiesta/app/modules/premium_home/views/missions_screen.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

class ContextualActionChip extends StatelessWidget {
  const ContextualActionChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 1. Check Live Event first (highest priority)
      if (Get.isRegistered<LiveOpsController>()) {
        final liveOps = Get.find<LiveOpsController>();
        if (liveOps.activeEvents.isNotEmpty) {
          final event = liveOps.activeEvents.first;
          return _buildChip(
            icon: Icons.celebration_rounded,
            iconColor: PremiumColors.electricBlue,
            text: '${event.title} Live! Tap to view',
            onTap: () => Get.to(() => const EventHubScreen()),
          );
        }
      }

      // 2. Check Active Mission second
      if (Get.isRegistered<MissionController>()) {
        final missionCtrl = Get.find<MissionController>();
        final mission = missionCtrl.activeMissions.firstWhereOrNull(
          (m) => m.state != MissionState.claimed,
        );
        if (mission != null) {
          final bool isDone = mission.state == MissionState.completed;
          return _buildChip(
            icon: isDone ? Icons.emoji_events_rounded : Icons.flash_on_rounded,
            iconColor: isDone ? PremiumColors.premiumGold : PremiumColors.electricBlue,
            text: isDone
                ? 'Mission Complete! Claim Reward'
                : '${mission.title} (${mission.currentValue}/${mission.targetValue})',
            onTap: () => Get.to(() => const MissionsScreen()),
            isHighlight: isDone,
          );
        }
      }

      // 3. Default tip when all missions claimed and no active event
      return _buildChip(
        icon: Icons.auto_awesome_rounded,
        iconColor: PremiumColors.premiumGold,
        text: 'Lucky Spin Ready! Tap SPIN to win',
        onTap: () {},
      );
    });
  }

  Widget _buildChip({
    required IconData icon,
    required Color iconColor,
    required String text,
    required VoidCallback onTap,
    bool isHighlight = false,
  }) {
    return TactilePressEffect(
      onPressed: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: PremiumColors.purpleGlass.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHighlight
                ? PremiumColors.premiumGold
                : PremiumColors.royalPurple.withValues(alpha: 0.3),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: PremiumTypography.bodyLarge.copyWith(
                  fontSize: 13,
                  color: isHighlight ? PremiumColors.textWhite : PremiumColors.textLightGrey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: PremiumColors.textMutedGrey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
