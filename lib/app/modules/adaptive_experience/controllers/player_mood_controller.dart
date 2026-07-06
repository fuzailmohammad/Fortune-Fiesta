import 'dart:async';

import 'package:fortune_fiesta/app/data/models/adaptive_experience_model.dart';
import 'package:get/get.dart';

class PlayerMoodController extends GetxService {
  static PlayerMoodController get to => Get.find();

  // Mood & Personality Observables
  final currentMood = PlayerMoodState.neutral.obs;
  final activePersonality = PlayerPersonality.casual.obs;

  // Session Tracking (Anonymous & Local)
  final sessionDurationSeconds = 0.obs;
  final sessionSpins = 0.obs;
  final spinsSinceLastWin = 0.obs;
  final lastWinAmount = 0.obs;

  // Presentation Triggers
  final showBreakReminder = false.obs;
  final showShortSessionShortcuts = false.obs;
  final visualEnergyMultiplier = 1.0.obs;
  final uiBrightnessBoost = 0.0.obs;

  Timer? _sessionTimer;

  @override
  void onInit() {
    super.onInit();
    _startSessionTimer();
    _evaluateInitialPersonality();
  }

  @override
  void onClose() {
    _sessionTimer?.cancel();
    super.onClose();
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      sessionDurationSeconds.value += 10;
      _evaluateSessionPacing();
    });
  }

  void _evaluateSessionPacing() {
    // Check for Short Session (< 3 minutes with low activity)
    if (sessionDurationSeconds.value < 180 && sessionSpins.value < 10) {
      if (currentMood.value != PlayerMoodState.hurriedShortSession) {
        currentMood.value = PlayerMoodState.hurriedShortSession;
        showShortSessionShortcuts.value = true;
      }
    } else {
      showShortSessionShortcuts.value = false;
    }

    // Check for Long Session (> 25 minutes or > 150 spins)
    if (sessionDurationSeconds.value >= 1500 || sessionSpins.value >= 150) {
      if (currentMood.value != PlayerMoodState.fatiguedLongSession) {
        currentMood.value = PlayerMoodState.fatiguedLongSession;
        showBreakReminder.value = true;
      }
    }
  }

  /// Called whenever a spin occurs without modifying any spin logic or reward math.
  void recordSpin({required bool isWin, required int winAmount}) {
    sessionSpins.value++;

    if (isWin) {
      spinsSinceLastWin.value = 0;
      lastWinAmount.value = winAmount;
      currentMood.value = PlayerMoodState.triumphantWinning;
      visualEnergyMultiplier.value = 1.25;
      uiBrightnessBoost.value = 0.05;

      // Revert mood to neutral after celebration delay
      Future.delayed(const Duration(seconds: 8), () {
        if (currentMood.value == PlayerMoodState.triumphantWinning) {
          currentMood.value = PlayerMoodState.neutral;
          visualEnergyMultiplier.value = 1.0;
          uiBrightnessBoost.value = 0.0;
        }
      });
    } else {
      spinsSinceLastWin.value++;

      // Long losing session trigger -> Presentation adaptation!
      if (spinsSinceLastWin.value >= 12) {
        currentMood.value = PlayerMoodState.frustratedLosing;
        // Machine visuals become more energetic, particles increase, UI slightly brighter!
        visualEnergyMultiplier.value = 1.45;
        uiBrightnessBoost.value = 0.15;
      } else if (currentMood.value == PlayerMoodState.neutral) {
        visualEnergyMultiplier.value = 1.0;
        uiBrightnessBoost.value = 0.0;
      }
    }

    // Update personality classification dynamically
    _updatePersonalityProfile();
  }

  void _evaluateInitialPersonality() {
    // Default starting classification
    activePersonality.value = PlayerPersonality.explorer;
  }

  void _updatePersonalityProfile() {
    if (sessionSpins.value > 100) {
      activePersonality.value = PlayerPersonality.vip;
    } else if (sessionSpins.value > 50) {
      activePersonality.value = PlayerPersonality.dailyPlayer;
    } else if (spinsSinceLastWin.value > 8) {
      activePersonality.value = PlayerPersonality.competitive;
    }
  }

  void dismissBreakReminder() {
    showBreakReminder.value = false;
  }

  void simulateStateForDemo(
      PlayerMoodState mood, PlayerPersonality personality) {
    currentMood.value = mood;
    activePersonality.value = personality;
    if (mood == PlayerMoodState.frustratedLosing) {
      visualEnergyMultiplier.value = 1.45;
      uiBrightnessBoost.value = 0.15;
    } else if (mood == PlayerMoodState.triumphantWinning) {
      visualEnergyMultiplier.value = 1.25;
      uiBrightnessBoost.value = 0.05;
    } else {
      visualEnergyMultiplier.value = 1.0;
      uiBrightnessBoost.value = 0.0;
    }
  }
}
