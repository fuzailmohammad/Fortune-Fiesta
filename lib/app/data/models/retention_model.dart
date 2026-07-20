class DailyRewardDay {
  final int day;
  final String rewardType; // 'coins', 'diamonds', 'xp'
  final int amount;
  final bool isClaimed;
  final bool isLocked;

  DailyRewardDay({
    required this.day,
    required this.rewardType,
    required this.amount,
    this.isClaimed = false,
    this.isLocked = true,
  });

  DailyRewardDay copyWith({
    bool? isClaimed,
    bool? isLocked,
  }) {
    return DailyRewardDay(
      day: day,
      rewardType: rewardType,
      amount: amount,
      isClaimed: isClaimed ?? this.isClaimed,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  factory DailyRewardDay.fromJson(Map<String, dynamic> json) {
    return DailyRewardDay(
      day: json['day'] ?? 1,
      rewardType: json['rewardType'] ?? 'coins',
      amount: json['amount'] ?? 100,
      isClaimed: json['isClaimed'] ?? false,
      isLocked: json['isLocked'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'rewardType': rewardType,
      'amount': amount,
      'isClaimed': isClaimed,
      'isLocked': isLocked,
    };
  }
}

class StreakState {
  final int currentStreak;
  final int longestStreak;
  final String? lastClaimDate;
  final int freezeCardsCount;

  StreakState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastClaimDate,
    this.freezeCardsCount = 1,
  });

  StreakState copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastClaimDate,
    int? freezeCardsCount,
  }) {
    return StreakState(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastClaimDate: lastClaimDate ?? this.lastClaimDate,
      freezeCardsCount: freezeCardsCount ?? this.freezeCardsCount,
    );
  }

  factory StreakState.fromJson(Map<String, dynamic> json) {
    return StreakState(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastClaimDate: json['lastClaimDate'],
      freezeCardsCount: json['freezeCardsCount'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastClaimDate': lastClaimDate,
      'freezeCardsCount': freezeCardsCount,
    };
  }
}

class GiftState {
  final String? lastOpenedTime;
  final int cooldownSeconds;

  GiftState({
    this.lastOpenedTime,
    this.cooldownSeconds = 0,
  });

  GiftState copyWith({
    String? lastOpenedTime,
    int? cooldownSeconds,
  }) {
    return GiftState(
      lastOpenedTime: lastOpenedTime ?? this.lastOpenedTime,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
    );
  }

  factory GiftState.fromJson(Map<String, dynamic> json) {
    return GiftState(
      lastOpenedTime: json['lastOpenedTime'],
      cooldownSeconds: json['cooldownSeconds'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastOpenedTime': lastOpenedTime,
      'cooldownSeconds': cooldownSeconds,
    };
  }
}

class WheelSegment {
  final String rewardType;
  final int amount;
  final String displayLabel;
  final int colorHex;

  WheelSegment({
    required this.rewardType,
    required this.amount,
    required this.displayLabel,
    required this.colorHex,
  });

  factory WheelSegment.fromJson(Map<String, dynamic> json) {
    return WheelSegment(
      rewardType: json['rewardType'] ?? 'coins',
      amount: json['amount'] ?? 100,
      displayLabel: json['displayLabel'] ?? '100',
      colorHex: json['colorHex'] ?? 0xFF140F27,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rewardType': rewardType,
      'amount': amount,
      'displayLabel': displayLabel,
      'colorHex': colorHex,
    };
  }
}
