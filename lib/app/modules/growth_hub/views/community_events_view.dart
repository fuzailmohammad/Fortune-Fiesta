import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/data/models/growth_model.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/community_manager.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

class CommunityEventsView extends StatelessWidget {
  const CommunityEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = CommunityManager.to;

    return Column(
      children: [
        // Top Co-op Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PremiumColors.electricBlue.withValues(alpha: 0.5),
                PremiumColors.royalPurple.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: PremiumColors.electricBlue.withValues(alpha: 0.5),
                width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.public,
                  color: PremiumColors.electricBlue, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GLOBAL CO-OP FESTIVAL',
                        style: PremiumTypography.subHeadingStyle
                            .copyWith(color: PremiumColors.electricBlue)),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          'Your Contributed Spins: ${manager.playerContributedSpins.value}',
                          style: PremiumTypography.captionSmall
                              .copyWith(color: Colors.white70),
                        )),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  manager.recordPlayerSpin();
                  Get.snackbar('SPIN RECORDED!',
                      'You added a spin to the Weekend Global Goal!',
                      backgroundColor: PremiumColors.electricBlue,
                      colorText: Colors.black);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumColors.electricBlue,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('CONTRIBUTE',
                    style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Goals List
        Expanded(
          child: Obx(() {
            final goals = manager.activeGoals;
            return ListView.separated(
              itemCount: goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, idx) {
                final goal = goals[idx];
                return _buildGoalCard(goal);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGoalCard(CommunityGoal goal) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: PremiumColors.purpleGlass.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: goal.isCompleted ? PremiumColors.premiumGold : Colors.white24,
          width: goal.isCompleted ? 2.0 : 1.0,
        ),
        boxShadow: [
          if (goal.isCompleted)
            BoxShadow(
                color: PremiumColors.premiumGold.withValues(alpha: 0.2),
                blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(goal.title.toUpperCase(),
                  style: PremiumTypography.subHeadingStyle.copyWith(
                      color: goal.isCompleted
                          ? PremiumColors.premiumGold
                          : Colors.white,
                      fontSize: 16)),
              if (goal.isCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: PremiumColors.premiumGold,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text('GOAL REACHED!',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(goal.description,
              style:
                  PremiumTypography.bodyStyle.copyWith(color: Colors.white70)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: goal.progressRatio,
              backgroundColor: Colors.black45,
              valueColor: AlwaysStoppedAnimation<Color>(goal.isCompleted
                  ? PremiumColors.premiumGold
                  : PremiumColors.electricBlue),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal.currentProgress} / ${goal.targetProgress}',
                style: PremiumTypography.numbersStyle
                    .copyWith(fontSize: 14, color: PremiumColors.textLightGrey),
              ),
              Text(
                'Reward: +${goal.rewardCoins} Coins',
                style: const TextStyle(
                    color: PremiumColors.premiumGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (goal.isCompleted)
            ElevatedButton(
              onPressed: goal.isClaimed
                  ? null
                  : () {
                      if (CommunityManager.to.claimReward(goal.id)) {
                        Get.snackbar('REWARD CLAIMED!',
                            '+${goal.rewardCoins} Coins added from Global Goal!',
                            backgroundColor: PremiumColors.premiumGold,
                            colorText: Colors.black);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: PremiumColors.premiumGold,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                  goal.isClaimed ? 'CLAIMED BY YOU' : 'CLAIM SHARED REWARD',
                  style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
        ],
      ),
    );
  }
}
