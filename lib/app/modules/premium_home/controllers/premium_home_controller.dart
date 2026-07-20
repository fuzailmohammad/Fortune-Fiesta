import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/audio_model.dart';
import '../services/reward_service.dart';
import '../services/stats_service.dart';
import '../services/storage_service.dart';
import 'audio_controller.dart';
import 'settings_controller.dart';

class PremiumHomeController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final RewardService _rewardService = Get.find<RewardService>();
  final StatsService _statsService = Get.find<StatsService>();

  static const String _coinKey = 'user_coin_balance';
  static const int spinCost = 100;

  // State Variables
  final RxInt coins = 50000.obs; // Default starting coins
  final RxInt currentBet = 100.obs; // Dynamic bet amount
  final RxBool isSpinning = false.obs;
  final RxBool isReelsSpinning = false.obs;
  final RxList<int> reelTargetIndices = <int>[0, 0, 0].obs;
  final RxInt currentTab = 0.obs;

  // Daily Reward State
  final RxBool isRewardAvailable = false.obs;
  final RxString cooldownText = ''.obs;
  Timer? _cooldownTimer;

  // Stats State
  final RxInt totalSpins = 0.obs;
  final RxInt totalWins = 0.obs;
  final RxInt highestWin = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _startCooldownTimer();
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    super.onClose();
  }

  void _loadUserData() {
    // Coins
    final savedCoins = _storage.read<int>(_coinKey);
    if (savedCoins != null) {
      coins.value = savedCoins;
    } else {
      _storage.write(_coinKey, coins.value);
    }

    // Stats
    _updateStatsState();
  }

  void _updateStatsState() {
    final stats = _statsService.getStats();
    totalSpins.value = stats.totalSpins;
    totalWins.value = stats.totalWins;
    highestWin.value = stats.highestWin;
  }

  void _startCooldownTimer() {
    _updateRewardAvailability();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRewardAvailability();
    });
  }

  void _updateRewardAvailability() {
    final available = _rewardService.isRewardAvailable;
    isRewardAvailable.value = available;

    if (available) {
      cooldownText.value = 'CLAIM NOW';
    } else {
      final timeLeft = _rewardService.timeUntilNextReward;
      final hours = timeLeft.inHours.toString().padLeft(2, '0');
      final minutes = (timeLeft.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (timeLeft.inSeconds % 60).toString().padLeft(2, '0');
      cooldownText.value = '$hours:$minutes:$seconds';
    }
  }

  int _pendingWinAmount = 0;
  bool _pendingIsWin = false;
  bool _pendingAllMatch = false;

  // Bet Management
  void increaseBet([int step = 100]) {
    if (isSpinning.value) return;
    if (coins.value <= 100) {
      currentBet.value = coins.value > 0 ? coins.value : 100;
      return;
    }
    if (currentBet.value + step <= coins.value) {
      currentBet.value += step;
    } else {
      currentBet.value = coins.value;
    }
    _playBetSound();
  }

  void decreaseBet([int step = 100]) {
    if (isSpinning.value) return;
    if (currentBet.value - step >= 100) {
      currentBet.value -= step;
    } else {
      currentBet.value = 100;
    }
    _playBetSound();
  }

  void setMaxBet() {
    if (isSpinning.value) return;
    if (coins.value >= 100) {
      currentBet.value = coins.value;
    } else if (coins.value > 0) {
      currentBet.value = coins.value;
    }
    _playBetSound();
  }

  void _playBetSound() {
    if (Get.isRegistered<AudioController>()) {
      final audio = Get.find<AudioController>();
      audio.triggerHaptic(HapticProfile.light);
      audio.playEvent(AudioEvent.buttonPress);
    }
  }

  // Spin Logic
  Future<void> spin() async {
    if (isSpinning.value) return;

    final int activeBet = currentBet.value;
    if (coins.value < activeBet) {
      Get.snackbar(
        'Out of Coins!',
        'Wait for the daily reward or spin again later!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF140F27),
        colorText: const Color(0xFFFFD700),
      );
      return;
    }

    // Deduct spin cost
    coins.value -= activeBet;
    await _storage.write(_coinKey, coins.value);
    isSpinning.value = true;
    isReelsSpinning.value = true;

    if (Get.isRegistered<AudioController>()) {
      Get.find<AudioController>().playEvent(AudioEvent.spinStart);
    }

    // Generate random final indices (0-9 corresponding to images 0-9)
    final random = Random();
    final target1 = random.nextInt(10);
    final target2 = random.nextInt(10);
    final target3 = random.nextInt(10);

    reelTargetIndices.value = [target1, target2, target3];

    // Mock winning rules:
    // If 3 symbols match -> Big Win (1000 coins)
    // If 2 symbols match -> Normal Win (250 coins)
    final bool allMatch = target1 == target2 && target2 == target3;
    final bool doubleMatch =
        (target1 == target2) || (target2 == target3) || (target1 == target3);

    int winAmount = 0;
    bool isWin = false;

    if (allMatch) {
      winAmount = currentBet.value * 10;
      isWin = true;
    } else if (doubleMatch) {
      winAmount = (currentBet.value * 2.5).toInt();
      isWin = true;
    }

    _pendingWinAmount = winAmount;
    _pendingIsWin = isWin;
    _pendingAllMatch = allMatch;

    final bool isTurbo = Get.isRegistered<SettingsController>() &&
        Get.find<SettingsController>().settings.value.gameplay.turboSpin;
    await Future.delayed(Duration(milliseconds: isTurbo ? 750 : 2500));

    // Signal reels to start deceleration (isSpinning remains true to keep SPIN button disabled)
    isReelsSpinning.value = false;

    // Safety fallback: ensure spin completes even if screen navigated away
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (isSpinning.value) {
        onReelsStopped();
      }
    });
  }

  // Called after the reels finish their stopping animation
  Future<void> onReelsStopped() async {
    if (!isSpinning.value) return;

    isSpinning.value = false;
    isReelsSpinning.value = false;

    final int winAmount = _pendingWinAmount;
    final bool allMatch = _pendingAllMatch;
    final bool isWin = _pendingIsWin;

    // Reset pending state immediately
    _pendingWinAmount = 0;
    _pendingIsWin = false;
    _pendingAllMatch = false;

    if (isWin && winAmount > 0) {
      coins.value += winAmount;
      await _storage.write(_coinKey, coins.value);

      if (Get.isRegistered<AudioController>()) {
        Get.find<AudioController>().playEvent(AudioEvent.winnerSpecial);
      }

      Get.snackbar(
        allMatch ? 'BIG WIN!' : 'WINNER!',
        'You won +$winAmount coins!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.9),
        colorText: const Color(0xFF07050F),
        duration: const Duration(seconds: 2),
      );
    }

    // Track gameplay statistics after reel stop
    await _statsService.recordSpin(isWin, winAmount);
    _updateStatsState();

    // Auto Spin execution
    if (Get.isRegistered<SettingsController>()) {
      final settings = Get.find<SettingsController>().settings.value;
      if (settings.gameplay.autoSpin && coins.value >= currentBet.value) {
        Future.delayed(
            Duration(milliseconds: settings.gameplay.turboSpin ? 600 : 1400),
            () {
          if (!isSpinning.value &&
              Get.find<SettingsController>().settings.value.gameplay.autoSpin) {
            spin();
          }
        });
      }
    }
  }


  // Claim Daily Reward
  Future<void> claimDailyReward() async {
    if (!isRewardAvailable.value) {
      Get.snackbar(
        'Daily Reward Cooldown',
        'Next reward in ${cooldownText.value}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF140F27),
        colorText: const Color(0xFFB0AEC4),
      );
      return;
    }

    final reward = await _rewardService.claimReward();
    if (reward > 0) {
      coins.value += reward;
      await _storage.write(_coinKey, coins.value);
      _updateRewardAvailability();

      Get.snackbar(
        'Daily Reward Claimed!',
        'You received +$reward free coins!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFD700).withValues(alpha: 0.9),
        colorText: const Color(0xFF07050F),
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Settings Action
  void openSettings() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF140F27),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF6A1B9A), width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'SETTINGS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingsOption('Sound Effects', true),
            _buildSettingsOption('Background Music', false),
            _buildSettingsOption('Haptic Feedback', true),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Get.back(),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
  }

  // Statistics Action
  void openStats() {
    _updateStatsState();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF140F27),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF6A1B9A), width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'GAME STATISTICS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => _buildStatRow('Total Spins', '${totalSpins.value}')),
            const SizedBox(height: 10),
            Obx(() => _buildStatRow('Total Wins', '${totalWins.value}')),
            const SizedBox(height: 10),
            Obx(() =>
                _buildStatRow('Highest Payout', '${highestWin.value} Coins')),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: const Color(0xFF07050F),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Get.back(),
              child: const Text('CLOSE',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption(String title, bool defaultValue) {
    var val = defaultValue.obs;
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Switch(
              value: val.value,
              activeThumbColor: const Color(0xFF00E5FF),
              inactiveTrackColor: const Color(0xFF07050F),
              onChanged: (newValue) => val.value = newValue,
            ),
          ],
        ));
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFB0AEC4), fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void changeTab(int index) {
    currentTab.value = index;
  }
}
