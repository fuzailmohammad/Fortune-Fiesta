import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/reward_service.dart';
import '../services/stats_service.dart';
import '../services/storage_service.dart';

class PremiumHomeController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final RewardService _rewardService = Get.find<RewardService>();
  final StatsService _statsService = Get.find<StatsService>();

  static const String _coinKey = 'user_coin_balance';
  static const int spinCost = 100;

  // State Variables
  final RxInt coins = 50000.obs; // Default starting coins
  final RxBool isSpinning = false.obs;
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

  // Spin Logic (UI triggers only, business rules mocked for UI demo)
  Future<void> spin() async {
    if (isSpinning.value) return;

    if (coins.value < spinCost) {
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
    coins.value -= spinCost;
    await _storage.write(_coinKey, coins.value);
    isSpinning.value = true;

    // Generate random final indices (0-9 corresponding to images 0-9)
    final random = Random();
    final target1 = random.nextInt(10);
    final target2 = random.nextInt(10);
    final target3 = random.nextInt(10);

    reelTargetIndices.value = [target1, target2, target3];

    // Mock spin duration (e.g. 2.5 seconds)
    await Future.delayed(const Duration(milliseconds: 2500));

    isSpinning.value = false;

    // Mock winning rules:
    // If 3 symbols match -> Big Win (1000 coins)
    // If 2 symbols match -> Normal Win (250 coins)
    final bool allMatch = target1 == target2 && target2 == target3;
    final bool doubleMatch =
        (target1 == target2) || (target2 == target3) || (target1 == target3);

    int winAmount = 0;
    bool isWin = false;

    if (allMatch) {
      winAmount = 1000;
      isWin = true;
    } else if (doubleMatch) {
      winAmount = 250;
      isWin = true;
    }

    if (isWin) {
      coins.value += winAmount;
      await _storage.write(_coinKey, coins.value);

      Get.snackbar(
        allMatch ? 'BIG WIN!' : 'WINNER!',
        'You won +$winAmount coins!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.9),
        colorText: const Color(0xFF07050F),
        duration: const Duration(seconds: 2),
      );
    }

    // Track gameplay statistics
    await _statsService.recordSpin(isWin, winAmount);
    _updateStatsState();
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
