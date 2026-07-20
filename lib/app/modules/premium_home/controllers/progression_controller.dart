import 'dart:async';

import 'package:fortune_fiesta/app/modules/premium_home/services/storage_service.dart';
import 'package:get/get.dart';

import '../../../data/models/player_profile.dart';
import '../controllers/premium_home_controller.dart';

class ProgressionController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  static const String _profileKey = 'player_progression_profile';

  // Reactive player profile state
  final Rx<PlayerProfile> profile = PlayerProfile().obs;

  // Level Up architecture states
  final RxBool showLevelUpOverlay = false.obs;
  final RxInt levelUpTarget = 0.obs;

  int _lastCoinsValue = 0;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();

    // Listen reactively to spin state completion using GetX workers
    try {
      final homeController = Get.find<PremiumHomeController>();
      _lastCoinsValue = homeController.coins.value;

      ever<bool>(homeController.isSpinning, (isSpinning) {
        if (!isSpinning) {
          // Spin stopped: award XP and update statistics after a short delay
          Timer(const Duration(milliseconds: 600),
              () => _onSpinCompleted(homeController));
        }
      });
    } catch (_) {}
  }

  void _loadProfile() {
    final savedData = _storage.read<Map<String, dynamic>>(_profileKey);
    if (savedData != null) {
      profile.value = PlayerProfile.fromJson(savedData);
    } else {
      _saveProfile();
    }
  }

  Future<void> _saveProfile() async {
    await _storage.write(_profileKey, profile.value.toJson());
  }

  // Calculate XP threshold per level (e.g. Level 1 needs 500 XP, Level 2 needs 1000 XP)
  int getXpRequiredForLevel(int lvl) {
    return lvl * 500;
  }

  // Handle spin completion metrics
  void _onSpinCompleted(PremiumHomeController homeController) {
    final int currentCoins = homeController.coins.value;
    int xpGain = 10; // Base XP for completing a spin
    int winAmount = 0;
    bool isWin = false;

    // Detect if coin balance increased (indicating a win outcome)
    if (currentCoins > _lastCoinsValue) {
      winAmount = currentCoins - _lastCoinsValue;
      isWin = true;

      // Award scaled XP based on win size
      if (winAmount >= 1000) {
        xpGain += 150; // Big Win bonus XP
      } else {
        xpGain += 50; // Normal Win bonus XP
      }
    }

    _lastCoinsValue = currentCoins;

    // Build new updated Stats
    final oldStats = profile.value.stats;
    final newStats = oldStats.copyWith(
      lifetimeSpins: oldStats.lifetimeSpins + 1,
      totalWins: isWin ? oldStats.totalWins + 1 : oldStats.totalWins,
      highestWin:
          winAmount > oldStats.highestWin ? winAmount : oldStats.highestWin,
      jackpotsWon:
          winAmount >= 1000 ? oldStats.jackpotsWon + 1 : oldStats.jackpotsWon,
    );

    // Update Profile and award XP
    profile.value = profile.value.copyWith(stats: newStats);
    _addXp(xpGain);
  }

  void _addXp(int amount) {
    int currentXp = profile.value.xp + amount;
    int currentLvl = profile.value.level;
    int xpRequired = getXpRequiredForLevel(currentLvl);

    // Handle Level Up overflows
    while (currentXp >= xpRequired) {
      currentXp -= xpRequired;
      currentLvl++;
      xpRequired = getXpRequiredForLevel(currentLvl);

      // Trigger Level-Up presentation flag
      _triggerLevelUp(currentLvl);
    }

    profile.value = profile.value.copyWith(
      level: currentLvl,
      xp: currentXp,
    );

    _saveProfile();
  }

  void _triggerLevelUp(int targetLevel) {
    levelUpTarget.value = targetLevel;
    showLevelUpOverlay.value = true;

    // Future support: Automatically close after 3 seconds or on user tap
    Timer(const Duration(seconds: 4), () {
      showLevelUpOverlay.value = false;
    });
  }

  // Developer command to manually add XP/Reset for testing
  void cheatAddXp(int amount) {
    _addXp(amount);
  }
}
