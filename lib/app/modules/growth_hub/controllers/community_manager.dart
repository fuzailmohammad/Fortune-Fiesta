import 'dart:async';

import 'package:fortune_fiesta/app/core/logger/app_logger.dart';
import 'package:fortune_fiesta/app/data/models/growth_model.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/premium_home_controller.dart';
import 'package:get/get.dart';

class CommunityManager extends GetxController {
  static CommunityManager get to => Get.find();

  final RxList<CommunityGoal> activeGoals = <CommunityGoal>[].obs;
  final RxInt playerContributedSpins = 0.obs;
  Timer? _simulatedGrowthTimer;

  @override
  void onInit() {
    super.onInit();
    _loadInitialGoals();
    _startSimulatedCommunityActivity();
  }

  @override
  void onClose() {
    _simulatedGrowthTimer?.cancel();
    super.onClose();
  }

  void _loadInitialGoals() {
    activeGoals.assignAll([
      const CommunityGoal(
        id: 'goal_weekend_spins',
        title: 'Weekend Community Spins',
        description:
            'Spin 5,000,000 times globally this weekend to unlock the Grand Vault!',
        currentProgress: 4320500,
        targetProgress: 5000000,
        rewardCoins: 100000,
        rewardDiamonds: 200,
      ),
      const CommunityGoal(
        id: 'goal_global_jackpot',
        title: 'Global Jackpot Festival',
        description: 'Hit 10,000 total Mega Jackpots worldwide!',
        currentProgress: 8850,
        targetProgress: 10000,
        rewardCoins: 250000,
        rewardDiamonds: 500,
      ),
      const CommunityGoal(
        id: 'goal_festival_chests',
        title: 'Fiesta Gift Drive',
        description: 'Open 50,000 Daily Reward Chests collectively.',
        currentProgress: 50000,
        targetProgress: 50000,
        rewardCoins: 50000,
        rewardDiamonds: 100,
        isCompleted: true,
      ),
    ]);
  }

  // 🌍 Simulate live world players spinning in the background
  void _startSimulatedCommunityActivity() {
    _simulatedGrowthTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      for (int i = 0; i < activeGoals.length; i++) {
        final goal = activeGoals[i];
        if (!goal.isCompleted && goal.currentProgress < goal.targetProgress) {
          final int increment =
              150 + (i * 45); // Simulate active global players
          final int newProg =
              (goal.currentProgress + increment).clamp(0, goal.targetProgress);
          final bool nowCompleted = newProg >= goal.targetProgress;

          activeGoals[i] = goal.copyWith(
              currentProgress: newProg, isCompleted: nowCompleted);
          if (nowCompleted) {
            AppLogger.i('🌍 COMMUNITY GOAL COMPLETED: ${goal.title}!',
                tag: 'CommunityManager');
          }
        }
      }
    });
  }

  // 🎰 Record local player spin contribution
  void recordPlayerSpin() {
    playerContributedSpins.value++;
    for (int i = 0; i < activeGoals.length; i++) {
      final goal = activeGoals[i];
      if (!goal.isCompleted && goal.id == 'goal_weekend_spins') {
        final int newProg =
            (goal.currentProgress + 1).clamp(0, goal.targetProgress);
        final bool nowCompleted = newProg >= goal.targetProgress;
        activeGoals[i] =
            goal.copyWith(currentProgress: newProg, isCompleted: nowCompleted);
      }
    }
  }

  // 🎁 Claim Community Shared Reward
  bool claimReward(String goalId) {
    final idx = activeGoals.indexWhere((g) => g.id == goalId);
    if (idx == -1) return false;

    final goal = activeGoals[idx];
    if (!goal.isCompleted || goal.isClaimed) return false;

    // Credit coins via PremiumHomeController
    if (Get.isRegistered<PremiumHomeController>()) {
      Get.find<PremiumHomeController>().coins.value += goal.rewardCoins;
    }

    activeGoals[idx] = goal.copyWith(isClaimed: true);
    AppLogger.i(
        '🎉 CLAIMED COMMUNITY REWARD: ${goal.title} (+${goal.rewardCoins} Coins)!',
        tag: 'CommunityManager');
    return true;
  }
}
