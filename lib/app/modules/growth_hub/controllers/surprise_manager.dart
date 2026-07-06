import 'dart:async';
import 'dart:math' as math;

import 'package:fortune_fiesta/app/core/logger/app_logger.dart';
import 'package:fortune_fiesta/app/data/models/growth_model.dart';
import 'package:fortune_fiesta/app/data/models/juice_model.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/juice_controller.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/premium_home_controller.dart';
import 'package:get/get.dart';

class SurpriseManager extends GetxController {
  static SurpriseManager get to => Get.find();

  final Rx<DailySurpriseType?> activeDailySurprise =
      DailySurpriseType.doubleCoinHour.obs;
  final Rx<MysteryEventType?> activeMysteryEvent = Rx<MysteryEventType?>(null);
  final RxString bannerMessage =
      '⚡ DOUBLE COIN HOUR IS LIVE! All spin rewards doubled!'.obs;
  final RxBool isMysteryOverlayVisible = false.obs;

  Timer? _randomMomentTimer;

  @override
  void onInit() {
    super.onInit();
    _startRandomSurpriseLoop();
  }

  @override
  void onClose() {
    _randomMomentTimer?.cancel();
    super.onClose();
  }

  // 🎲 Periodically trigger rare visual surprise moments (e.g. Floating Gold Coin, Lucky Butterfly)
  void _startRandomSurpriseLoop() {
    _randomMomentTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      final math.Random random = math.Random();
      final int chance = random.nextInt(100);

      if (chance < 35 && Get.isRegistered<JuiceController>()) {
        final juice = Get.find<JuiceController>();
        if (chance < 18) {
          juice.triggerMicroSurprise(JuiceEffectType.rollingCoin);
          AppLogger.d('✨ SURPRISE MOMENT: Golden Coin floating across screen.',
              tag: 'SurpriseManager');
        } else {
          juice.triggerMicroSurprise(JuiceEffectType.butterfly);
          AppLogger.d('🦋 SURPRISE MOMENT: Lucky Butterfly fluttering.',
              tag: 'SurpriseManager');
        }
      }
    });
  }

  // ⚡ Activate a Daily Surprise
  void setDailySurprise(DailySurpriseType type, String message) {
    activeDailySurprise.value = type;
    bannerMessage.value = message;
    AppLogger.i('🎁 DAILY SURPRISE ACTIVATED: ${type.name} ($message)',
        tag: 'SurpriseManager');
  }

  // 🌈 Trigger a Rare Mystery Event (e.g. Coin Storm, Treasure Rain, Diamond Shower)
  void triggerMysteryEvent(MysteryEventType eventType) {
    activeMysteryEvent.value = eventType;
    isMysteryOverlayVisible.value = true;
    AppLogger.i('🚨 MYSTERY EVENT TRIGGERED: ${eventType.name.toUpperCase()}!',
        tag: 'SurpriseManager');

    // Grant bonus coins or diamonds during rare events
    if (Get.isRegistered<PremiumHomeController>()) {
      final home = Get.find<PremiumHomeController>();
      switch (eventType) {
        case MysteryEventType.coinStorm:
        case MysteryEventType.treasureRain:
          home.coins.value += 50000;
          break;
        case MysteryEventType.diamondShower:
          // Simulate diamond bonus
          break;
        default:
          home.coins.value += 25000;
          break;
      }
    }

    // Auto dismiss overlay after 4 seconds
    Timer(const Duration(seconds: 4), () {
      isMysteryOverlayVisible.value = false;
      activeMysteryEvent.value = null;
    });
  }

  // 🎁 Claim Secret Mystery Chest
  void openSecretChest() {
    if (Get.isRegistered<PremiumHomeController>()) {
      Get.find<PremiumHomeController>().coins.value += 100000;
    }
    AppLogger.i('🎁 OPENED SECRET CHEST: +100,000 Coins!',
        tag: 'SurpriseManager');
  }
}
