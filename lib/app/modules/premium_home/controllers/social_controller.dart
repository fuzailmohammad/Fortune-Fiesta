import 'dart:math' as math;

import 'package:get/get.dart';

import '../../../data/models/social_model.dart';
import '../controllers/premium_home_controller.dart';
import '../services/storage_service.dart';
import 'progression_controller.dart';

class SocialController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  static const String _profileKey = 'social_player_profile';
  static const String _friendsKey = 'social_friends_list';
  static const String _leaderboardKey = 'social_leaderboard_list';

  final Rx<SocialPlayerProfileModel?> playerProfile =
      Rx<SocialPlayerProfileModel?>(null);
  final RxList<FriendModel> friends = <FriendModel>[].obs;
  final RxList<LeaderboardEntryModel> leaderboard =
      <LeaderboardEntryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _setupReactiveWorkers();
  }

  void _loadData() {
    // 1. Profile customization loader
    final savedProfile = _storage.read<Map<String, dynamic>>(_profileKey);
    if (savedProfile != null) {
      playerProfile.value = SocialPlayerProfileModel.fromJson(savedProfile);
    } else {
      _loadDefaultProfile();
    }

    // 2. Friends list loader
    final savedFriends = _storage.read<List<dynamic>>(_friendsKey);
    if (savedFriends != null) {
      friends.value = savedFriends.map((e) => FriendModel.fromJson(e)).toList();
    } else {
      _loadDefaultFriends();
    }

    // 3. Leaderboard list loader
    final savedLeaderboard = _storage.read<List<dynamic>>(_leaderboardKey);
    if (savedLeaderboard != null) {
      leaderboard.value = savedLeaderboard
          .map((e) => LeaderboardEntryModel.fromJson(e))
          .toList();
    } else {
      _loadDefaultLeaderboard();
    }
  }

  void _loadDefaultProfile() {
    try {
      final prog = Get.find<ProgressionController>();
      playerProfile.value = SocialPlayerProfileModel(
        id: 'user_player',
        name: 'LuckySpinner',
        level: prog.profile.value.level,
        frame: prog.profile.value.avatarFrame,
        title: 'ROOKIE',
        league: LeagueTier.gold,
        score: 4500,
        streak: prog.profile.value.streak,
        wins: 12,
        jackpots: 1,
      );
    } catch (_) {
      playerProfile.value = SocialPlayerProfileModel(
        id: 'user_player',
        name: 'LuckySpinner',
        level: 3,
        frame: 'none',
        title: 'ROOKIE',
        league: LeagueTier.gold,
        score: 4500,
        streak: 2,
        wins: 12,
        jackpots: 1,
      );
    }
    _saveData();
  }

  void _loadDefaultFriends() {
    friends.value = [
      FriendModel(
          id: 'friend_1',
          name: 'SpinKing',
          isOnline: true,
          recentActivity: 'Just hit Mega Win!'),
      FriendModel(
          id: 'friend_2',
          name: 'DiamondQueen',
          isOnline: true,
          recentActivity: 'Spinning Slot...'),
      FriendModel(
          id: 'friend_3',
          name: 'CoinCollector',
          isOnline: false,
          recentActivity: 'Active 2 hours ago'),
    ];
    _saveData();
  }

  void _loadDefaultLeaderboard() {
    leaderboard.value = [
      LeaderboardEntryModel(
          rank: 1,
          name: 'SlotsBoss',
          score: 12500,
          level: 14,
          frame: 'vip',
          trend: 'up',
          isOnline: true),
      LeaderboardEntryModel(
          rank: 2,
          name: 'VipFiesta',
          score: 9800,
          level: 9,
          frame: 'gold',
          trend: 'down',
          isOnline: false),
      LeaderboardEntryModel(
          rank: 3,
          name: 'ReelMaster',
          score: 7200,
          level: 7,
          frame: 'none',
          trend: 'stable',
          isOnline: true),
      // Player slot
      LeaderboardEntryModel(
          rank: 4,
          name: 'LuckySpinner (You)',
          score: 4500,
          level: 3,
          frame: 'none',
          trend: 'up',
          isOnline: true),
      LeaderboardEntryModel(
          rank: 5,
          name: 'DiamondJack',
          score: 3800,
          level: 4,
          frame: 'none',
          trend: 'stable',
          isOnline: false),
      LeaderboardEntryModel(
          rank: 6,
          name: 'GoldHunter',
          score: 2100,
          level: 2,
          frame: 'none',
          trend: 'down',
          isOnline: false),
    ];
    _saveData();
  }

  Future<void> _saveData() async {
    if (playerProfile.value != null) {
      await _storage.write(_profileKey, playerProfile.value!.toJson());
    }
    await _storage.write(_friendsKey, friends.map((e) => e.toJson()).toList());
    await _storage.write(
        _leaderboardKey, leaderboard.map((e) => e.toJson()).toList());
  }

  void _setupReactiveWorkers() {
    // Increment leaderboard score whenever user coins balance increases (reactive wins)
    try {
      final homeController = Get.find<PremiumHomeController>();
      ever(homeController.coins, (newCoins) {
        if (playerProfile.value != null) {
          // Increment score proportional to spins/wins
          final int winDiff =
              math.max(0, newCoins - 50000); // base threshold win
          if (winDiff > 0) {
            updateLeaderboardScore(
                playerProfile.value!.score + (winDiff ~/ 100));
          }
        }
      });
    } catch (_) {}
  }

  // Update leaderboard score and resort rank positions dynamically
  void updateLeaderboardScore(int newScore) {
    if (playerProfile.value == null) return;

    playerProfile.value = playerProfile.value!.copyWith(score: newScore);

    // Find player row in leaderboard list and update
    final int idx = leaderboard.indexWhere((e) => e.name.contains('You'));
    if (idx != -1) {
      leaderboard[idx] = LeaderboardEntryModel(
        rank: leaderboard[idx].rank,
        name: leaderboard[idx].name,
        score: newScore,
        level: playerProfile.value!.level,
        frame: playerProfile.value!.frame,
        trend: 'up',
        isOnline: true,
      );

      // Re-sort list by scores descending
      leaderboard.sort((a, b) => b.score.compareTo(a.score));

      // Update ranks based on sorted positions
      for (int i = 0; i < leaderboard.length; i++) {
        leaderboard[i] = LeaderboardEntryModel(
          rank: i + 1,
          name: leaderboard[i].name,
          score: leaderboard[i].score,
          level: leaderboard[i].level,
          frame: leaderboard[i].frame,
          trend: leaderboard[i].trend,
          isOnline: leaderboard[i].isOnline,
        );
      }
    }
    _saveData();
  }

  // Customize frames
  void equipFrame(String frameName) {
    if (playerProfile.value == null) return;

    playerProfile.value = playerProfile.value!.copyWith(frame: frameName);

    // Sync back to ProgressionController avatar frame
    try {
      final prog = Get.find<ProgressionController>();
      prog.profile.value = prog.profile.value.copyWith(avatarFrame: frameName);
    } catch (_) {}

    // Update in leaderboard rows
    final int idx = leaderboard.indexWhere((e) => e.name.contains('You'));
    if (idx != -1) {
      leaderboard[idx] = LeaderboardEntryModel(
        rank: leaderboard[idx].rank,
        name: leaderboard[idx].name,
        score: leaderboard[idx].score,
        level: leaderboard[idx].level,
        frame: frameName,
        trend: leaderboard[idx].trend,
        isOnline: leaderboard[idx].isOnline,
      );
    }

    _saveData();
  }

  // Equip customizable title tag
  void equipTitle(String titleName) {
    if (playerProfile.value == null) return;
    playerProfile.value = playerProfile.value!.copyWith(title: titleName);
    _saveData();
  }

  // Add friend mock request
  void addFriend(String name) {
    final randId = 'friend_${DateTime.now().millisecondsSinceEpoch}';
    friends.add(FriendModel(
      id: randId,
      name: name,
      isOnline: false,
      recentActivity: 'Joined community!',
    ));
    _storage.write(_friendsKey, friends.map((e) => e.toJson()).toList());
  }
}
