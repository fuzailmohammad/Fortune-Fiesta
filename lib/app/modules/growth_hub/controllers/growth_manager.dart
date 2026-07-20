import 'package:fortune_fiesta/app/core/logger/app_logger.dart';
import 'package:fortune_fiesta/app/data/models/growth_model.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/cosmetic_manager.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/premium_home_controller.dart';
import 'package:get/get.dart';

class GrowthManager extends GetxController {
  static GrowthManager get to => Get.find();

  final RxList<PlayerStreak> activeStreaks = <PlayerStreak>[].obs;
  final RxInt currentDailyStreak = 5.obs;
  final RxBool hasClaimedToday = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialStreaks();
  }

  void _loadInitialStreaks() {
    activeStreaks.assignAll([
      const PlayerStreak(
        streakId: 'daily',
        title: '7-Day Login Streak',
        currentDays: 5,
        targetDays: 7,
        rewardCoins: 25000,
        rewardTitleId: 'title_lucky_spinner',
      ),
      const PlayerStreak(
        streakId: 'weekly',
        title: 'Weekly Active Spinner',
        currentDays: 3,
        targetDays: 4,
        rewardCoins: 75000,
      ),
      const PlayerStreak(
        streakId: 'monthly',
        title: 'Monthly High Roller',
        currentDays: 18,
        targetDays: 25,
        rewardCoins: 200000,
      ),
      const PlayerStreak(
        streakId: '100_day',
        title: '100-Day Fiesta Legend',
        currentDays: 42,
        targetDays: 100,
        rewardCoins: 1000000,
        rewardTitleId: 'title_vip_elite',
      ),
      const PlayerStreak(
        streakId: '365_day',
        title: '365-Day Immortal Crown',
        currentDays: 42,
        targetDays: 365,
        rewardCoins: 5000000,
        rewardTitleId: 'title_legend',
      ),
    ]);
  }

  // 🎁 Claim Daily Login Streak Reward
  bool claimStreakReward(String streakId) {
    final idx = activeStreaks.indexWhere((s) => s.streakId == streakId);
    if (idx == -1) return false;

    final streak = activeStreaks[idx];
    if (streak.isClaimed || streak.currentDays < streak.targetDays) {
      return false;
    }

    // Credit coins via PremiumHomeController
    if (Get.isRegistered<PremiumHomeController>()) {
      Get.find<PremiumHomeController>().coins.value += streak.rewardCoins;
    }

    // Grant title if applicable
    if (streak.rewardTitleId != null && Get.isRegistered<CosmeticManager>()) {
      Get.find<CosmeticManager>().unlockItem(streak.rewardTitleId!);
    }

    activeStreaks[idx] = streak.copyWith(isClaimed: true);
    AppLogger.i(
        '🎉 CLAIMED STREAK REWARD: ${streak.title} (+${streak.rewardCoins} Coins)!',
        tag: 'GrowthManager');
    return true;
  }

  // 📈 Simulate daily login progression for testing
  void simulateNextDayLogin() {
    currentDailyStreak.value++;
    hasClaimedToday.value = false;
    for (int i = 0; i < activeStreaks.length; i++) {
      final s = activeStreaks[i];
      if (!s.isClaimed && s.currentDays < s.targetDays) {
        activeStreaks[i] = s.copyWith(currentDays: s.currentDays + 1);
      }
    }
    AppLogger.i(
        '📈 Simulated Next Day Login. Current streak: ${currentDailyStreak.value} days.',
        tag: 'GrowthManager');
  }
}
