import 'dart:async';

import 'package:fortune_fiesta/app/modules/premium_home/services/storage_service.dart';
import 'package:get/get.dart';

import '../../../data/models/mission_model.dart';
import '../controllers/premium_home_controller.dart';
import 'progression_controller.dart';

class MissionController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  static const String _missionsKey = 'player_active_missions';
  static const String _achievementsKey = 'player_active_achievements';

  final RxList<MissionModel> activeMissions = <MissionModel>[].obs;
  final RxList<AchievementModel> achievements = <AchievementModel>[].obs;

  int _lastCoinsValue = 0;

  @override
  void onInit() {
    super.onInit();
    _loadData();

    // Bind GetX worker listening reactively to gameplay spin completion events
    try {
      final homeController = Get.find<PremiumHomeController>();
      _lastCoinsValue = homeController.coins.value;

      ever<bool>(homeController.isSpinning, (isSpinning) {
        if (!isSpinning) {
          Timer(const Duration(milliseconds: 650),
              () => _updateGameplayObjectives(homeController));
        }
      });
    } catch (_) {}
  }

  void _loadData() {
    final savedMissions = _storage.read<List<dynamic>>(_missionsKey);
    final savedAchievements = _storage.read<List<dynamic>>(_achievementsKey);

    if (savedMissions != null) {
      activeMissions.value =
          savedMissions.map((json) => MissionModel.fromJson(json)).toList();
    } else {
      _loadDefaultMissions();
    }

    if (savedAchievements != null) {
      achievements.value = savedAchievements
          .map((json) => AchievementModel.fromJson(json))
          .toList();
    } else {
      _loadDefaultAchievements();
    }
  }

  Future<void> _saveData() async {
    await _storage.write(
        _missionsKey, activeMissions.map((e) => e.toJson()).toList());
    await _storage.write(
        _achievementsKey, achievements.map((e) => e.toJson()).toList());
  }

  void _loadDefaultMissions() {
    activeMissions.value = [
      MissionModel(
        id: 'daily_spin_10',
        title: 'Daily Spinner',
        description: 'Spin the slot reels 10 times.',
        type: MissionType.daily,
        difficulty: MissionDifficulty.easy,
        targetValue: 10,
        rewardType: 'xp',
        rewardValue: 200,
        priority: 1,
      ),
      MissionModel(
        id: 'daily_win_5',
        title: 'Cherries & Gold',
        description: 'Hit any winning match 5 times.',
        type: MissionType.daily,
        difficulty: MissionDifficulty.medium,
        targetValue: 5,
        rewardType: 'coins',
        rewardValue: 500,
        priority: 2,
      ),
      MissionModel(
        id: 'daily_collect_2000',
        title: 'Coin Collector',
        description: 'Collect 2,000 coins from rewards.',
        type: MissionType.daily,
        difficulty: MissionDifficulty.medium,
        targetValue: 2000,
        rewardType: 'diamonds',
        rewardValue: 25,
        priority: 3,
      ),
      MissionModel(
        id: 'weekly_spin_50',
        title: 'Weekly Marathon',
        description: 'Spin the reels 50 times this week.',
        type: MissionType.weekly,
        difficulty: MissionDifficulty.hard,
        targetValue: 50,
        rewardType: 'coins',
        rewardValue: 2500,
        priority: 5,
      ),
      MissionModel(
        id: 'weekly_big_win_3',
        title: 'Jackpot Chaser',
        description: 'Hit 3 Big Wins (triple matching symbols).',
        type: MissionType.weekly,
        difficulty: MissionDifficulty.legendary,
        targetValue: 3,
        rewardType: 'diamonds',
        rewardValue: 100,
        priority: 6,
      ),
    ];
    _saveData();
  }

  void _loadDefaultAchievements() {
    achievements.value = [
      AchievementModel(
        id: 'ach_spins_100',
        title: 'Fiesta Novice',
        description: 'Spin the slot machine 100 times.',
        targetValue: 100,
        tier: 'bronze',
        rewardValue: 1000,
      ),
      AchievementModel(
        id: 'ach_spins_1000',
        title: 'Slot Titan',
        description: 'Spin the slot machine 1,000 times.',
        targetValue: 1000,
        tier: 'silver',
        rewardValue: 5000,
      ),
      AchievementModel(
        id: 'ach_wins_50',
        title: 'Winning Streak',
        description: 'Hit 50 winning combinations.',
        targetValue: 50,
        tier: 'gold',
        rewardValue: 2500,
      ),
      AchievementModel(
        id: 'ach_jackpots_10',
        title: 'Triple Crown Hunter',
        description: 'Hit 10 Big Wins (3-matching combinations).',
        targetValue: 10,
        tier: 'diamond',
        rewardValue: 100,
      ),
    ];
    _saveData();
  }

  // Reactively track game loop actions
  void _updateGameplayObjectives(PremiumHomeController homeController) {
    final int currentCoins = homeController.coins.value;
    int gain = 0;
    bool isWin = false;

    if (currentCoins > _lastCoinsValue) {
      gain = currentCoins - _lastCoinsValue;
      isWin = true;
    }
    _lastCoinsValue = currentCoins;

    // 1. Update active missions
    for (int i = 0; i < activeMissions.length; i++) {
      final mission = activeMissions[i];
      if (mission.state == MissionState.claimed ||
          mission.state == MissionState.expired) {
        continue;
      }

      int progress = mission.currentValue;

      if (mission.id.contains('spin')) {
        progress += 1;
      } else if (mission.id.contains('win') && isWin) {
        progress += 1;
      } else if (mission.id.contains('collect')) {
        progress += gain;
      } else if (mission.id.contains('big_win') && gain >= 1000) {
        progress += 1;
      }

      progress = progress.clamp(0, mission.targetValue);
      final isCompleted = progress >= mission.targetValue;

      activeMissions[i] = mission.copyWith(
        currentValue: progress,
        state: isCompleted ? MissionState.completed : MissionState.inProgress,
      );
    }

    // 2. Update permanent achievements
    for (int i = 0; i < achievements.length; i++) {
      final ach = achievements[i];
      if (ach.isClaimed) continue;

      int progress = ach.currentValue;

      if (ach.id.contains('spins')) {
        progress += 1;
      } else if (ach.id.contains('wins') && isWin) {
        progress += 1;
      } else if (ach.id.contains('jackpots') && gain >= 1000) {
        progress += 1;
      }

      progress = progress.clamp(0, ach.targetValue);
      achievements[i] = ach.copyWith(currentValue: progress);
    }

    _saveData();
  }

  // Claim Rewards
  void claimMission(String id) {
    final int idx = activeMissions.indexWhere((m) => m.id == id);
    if (idx != -1 && activeMissions[idx].state == MissionState.completed) {
      activeMissions[idx] =
          activeMissions[idx].copyWith(state: MissionState.claimed);
      _awardReward(
          activeMissions[idx].rewardType, activeMissions[idx].rewardValue);
      _saveData();
    }
  }

  void claimAchievement(String id) {
    final int idx = achievements.indexWhere((a) => a.id == id);
    if (idx != -1 &&
        achievements[idx].currentValue >= achievements[idx].targetValue &&
        !achievements[idx].isClaimed) {
      achievements[idx] = achievements[idx].copyWith(isClaimed: true);
      _awardReward(achievements[idx].tier == 'diamond' ? 'diamonds' : 'coins',
          achievements[idx].rewardValue);
      _saveData();
    }
  }

  void _awardReward(String type, int amount) {
    // Progression links: trigger XP increments or coin increments safely
    try {
      if (type == 'xp') {
        final progController = Get.find<ProgressionController>();
        progController.cheatAddXp(amount);
      } else if (type == 'coins') {
        final homeController = Get.find<PremiumHomeController>();
        homeController.coins.value += amount;
        _lastCoinsValue = homeController.coins.value;
      } else if (type == 'diamonds') {
        final progController = Get.find<ProgressionController>();
        progController.profile.value = progController.profile.value.copyWith(
          diamonds: progController.profile.value.diamonds + amount,
        );
      }
    } catch (_) {}
  }
}
