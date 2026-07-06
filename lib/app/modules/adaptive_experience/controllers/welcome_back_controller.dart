import 'package:fortune_fiesta/app/data/models/adaptive_experience_model.dart';
import 'package:get/get.dart';

class WelcomeBackController extends GetxService {
  static WelcomeBackController get to => Get.find();

  final showWelcomePopup = false.obs;
  final daysAway = 0.obs;
  final activeConfig = const WelcomeBackConfig(
    tier: WelcomeBackTier.oneDay,
    title: 'WELCOME BACK!',
    subtitle: '1 DAY AWAY',
    motivationalMessage:
        "We missed you yesterday! Here's a quick spin boost to keep your reels spinning high!",
    daysAway: 1,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    _evaluateAbsence();
  }

  void _evaluateAbsence() {
    // In production, compare current timestamp with stored SharedPreferences timestamp.
    // Here we initialize with 0 days (daily continuous player).
    daysAway.value = 0;
    showWelcomePopup.value = false;
  }

  void simulateReturn(WelcomeBackTier tier) {
    switch (tier) {
      case WelcomeBackTier.oneDay:
        daysAway.value = 1;
        activeConfig.value = const WelcomeBackConfig(
          tier: WelcomeBackTier.oneDay,
          title: 'WELCOME BACK, SPINNER!',
          subtitle: '1 DAY AWAY',
          motivationalMessage:
              "We missed you yesterday! Your machine is warmed up and ready for winning streaks!",
          daysAway: 1,
        );
        break;
      case WelcomeBackTier.threeDays:
        daysAway.value = 3;
        activeConfig.value = const WelcomeBackConfig(
          tier: WelcomeBackTier.threeDays,
          title: 'THE REELS ARE CALLING!',
          subtitle: '3 DAYS AWAY',
          motivationalMessage:
              "See what's new in the Fiesta! We've prepared special daily quests and live surprises just for you!",
          daysAway: 3,
        );
        break;
      case WelcomeBackTier.sevenDays:
        daysAway.value = 7;
        activeConfig.value = const WelcomeBackConfig(
          tier: WelcomeBackTier.sevenDays,
          title: '🌟 VIP RETURN 🌟',
          subtitle: '7 DAYS AWAY',
          motivationalMessage:
              "Your slot machine has been polished to perfection! Get ready for maximum excitement!",
          daysAway: 7,
        );
        break;
      case WelcomeBackTier.thirtyDays:
        daysAway.value = 30;
        activeConfig.value = const WelcomeBackConfig(
          tier: WelcomeBackTier.thirtyDays,
          title: '👑 LEGENDARY RETURN 👑',
          subtitle: '30+ DAYS AWAY',
          motivationalMessage:
              "Welcome back to Fortune Fiesta! The Treasure Vault is open and awaiting your legendary spin!",
          daysAway: 30,
        );
        break;
    }
    showWelcomePopup.value = true;
  }

  void dismissWelcomePopup() {
    showWelcomePopup.value = false;
  }
}
