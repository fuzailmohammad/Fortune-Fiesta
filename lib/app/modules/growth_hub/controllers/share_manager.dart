import 'package:fortune_fiesta/app/core/logger/app_logger.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/cosmetic_manager.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/premium_home_controller.dart';
import 'package:get/get.dart';

class ShareManager extends GetxController {
  static ShareManager get to => Get.find();

  final RxInt totalShares = 0.obs;
  final RxInt shareRewardCoins = 5000.obs;
  final RxInt shareRewardXp = 200.obs;
  final RxBool canClaimDailyShareReward = true.obs;
  final RxList<String> unlockedBadges = <String>['Social Starter'].obs;

  // 📸 Trigger Viral Share Sheet & Claim Rewards
  Future<bool> shareAndClaim(
      {required String title,
      required int winAmount,
      bool isJackpot = false}) async {
    AppLogger.i(
        '📸 INITIATING VIRAL SHARE: $title (Win: $winAmount, Jackpot: $isJackpot)',
        tag: 'ShareManager');

    // Simulate share dialog / social media export delay
    await Future.delayed(const Duration(milliseconds: 600));

    totalShares.value++;

    // Grant Share Reward if available today
    if (canClaimDailyShareReward.value) {
      canClaimDailyShareReward.value = false;

      // Credit coins via PremiumHomeController
      if (Get.isRegistered<PremiumHomeController>()) {
        Get.find<PremiumHomeController>().coins.value += shareRewardCoins.value;
      }

      // Check badge thresholds
      if (totalShares.value >= 5 &&
          !unlockedBadges.contains('Viral Influencer')) {
        unlockedBadges.add('Viral Influencer');
        if (Get.isRegistered<CosmeticManager>()) {
          Get.find<CosmeticManager>().unlockItem('title_legend');
        }
      }

      AppLogger.i(
          '🎁 CLAIMED SHARE REWARD: +${shareRewardCoins.value} Coins, +${shareRewardXp.value} XP!',
          tag: 'ShareManager');
      return true;
    }

    AppLogger.d(
        'Shared successfully without coin reward (already claimed today).',
        tag: 'ShareManager');
    return false;
  }

  void resetDailyShareLimit() {
    canClaimDailyShareReward.value = true;
    AppLogger.i('Daily Share Reward limit reset.', tag: 'ShareManager');
  }
}
