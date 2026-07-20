enum DailySurpriseType {
  luckyHour,
  goldenSpin,
  doubleCoinHour,
  happyHour,
  mysteryReward,
  secretChest,
  goldenReel,
  weekendBonus,
}

enum MysteryEventType {
  goldenMachine,
  rainbowReels,
  luckySymbols,
  treasureRain,
  coinStorm,
  diamondShower,
  mysteryJackpot,
  fireMachine,
  lightningMachine,
}

class CommunityGoal {
  final String id;
  final String title;
  final String description;
  final int currentProgress;
  final int targetProgress;
  final int rewardCoins;
  final int rewardDiamonds;
  final bool isCompleted;
  final bool isClaimed;

  const CommunityGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.currentProgress,
    required this.targetProgress,
    required this.rewardCoins,
    this.rewardDiamonds = 0,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  double get progressRatio => targetProgress <= 0 ? 0.0 : (currentProgress / targetProgress).clamp(0.0, 1.0);

  CommunityGoal copyWith({
    int? currentProgress,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return CommunityGoal(
      id: id,
      title: title,
      description: description,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress,
      rewardCoins: rewardCoins,
      rewardDiamonds: rewardDiamonds,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  factory CommunityGoal.fromJson(Map<String, dynamic> json) {
    return CommunityGoal(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Global Goal',
      description: json['description'] as String? ?? '',
      currentProgress: json['current_progress'] as int? ?? 0,
      targetProgress: json['target_progress'] as int? ?? 1000000,
      rewardCoins: json['reward_coins'] as int? ?? 50000,
      rewardDiamonds: json['reward_diamonds'] as int? ?? 100,
      isCompleted: json['is_completed'] as bool? ?? false,
      isClaimed: json['is_claimed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'current_progress': currentProgress,
      'target_progress': targetProgress,
      'reward_coins': rewardCoins,
      'reward_diamonds': rewardDiamonds,
      'is_completed': isCompleted,
      'is_claimed': isClaimed,
    };
  }
}

class PlayerStreak {
  final String streakId; // 'daily', 'weekly', 'monthly', '100_day', '365_day'
  final String title;
  final int currentDays;
  final int targetDays;
  final int rewardCoins;
  final String? rewardTitleId;
  final bool isClaimed;

  const PlayerStreak({
    required this.streakId,
    required this.title,
    required this.currentDays,
    required this.targetDays,
    required this.rewardCoins,
    this.rewardTitleId,
    this.isClaimed = false,
  });

  double get progressRatio => targetDays <= 0 ? 0.0 : (currentDays / targetDays).clamp(0.0, 1.0);

  PlayerStreak copyWith({
    int? currentDays,
    bool? isClaimed,
  }) {
    return PlayerStreak(
      streakId: streakId,
      title: title,
      currentDays: currentDays ?? this.currentDays,
      targetDays: targetDays,
      rewardCoins: rewardCoins,
      rewardTitleId: rewardTitleId,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  factory PlayerStreak.fromJson(Map<String, dynamic> json) {
    return PlayerStreak(
      streakId: json['streak_id'] as String? ?? 'daily',
      title: json['title'] as String? ?? 'Daily Streak',
      currentDays: json['current_days'] as int? ?? 1,
      targetDays: json['target_days'] as int? ?? 7,
      rewardCoins: json['reward_coins'] as int? ?? 5000,
      rewardTitleId: json['reward_title_id'] as String?,
      isClaimed: json['is_claimed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streak_id': streakId,
      'title': title,
      'current_days': currentDays,
      'target_days': targetDays,
      'reward_coins': rewardCoins,
      'reward_title_id': rewardTitleId,
      'is_claimed': isClaimed,
    };
  }
}
