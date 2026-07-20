enum MissionType {
  daily,
  weekly,
  special,
}

enum MissionState {
  locked,
  inProgress,
  completed,
  claimed,
  expired,
}

enum MissionDifficulty {
  easy,
  medium,
  hard,
  legendary,
}

class MissionModel {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final MissionDifficulty difficulty;
  final int targetValue;
  final int currentValue;
  final MissionState state;
  final String rewardType; // 'coins', 'diamonds', 'xp'
  final int rewardValue;
  final int priority;

  MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.targetValue,
    this.currentValue = 0,
    this.state = MissionState.inProgress,
    required this.rewardType,
    required this.rewardValue,
    this.priority = 10,
  });

  MissionModel copyWith({
    int? currentValue,
    MissionState? state,
  }) {
    return MissionModel(
      id: id,
      title: title,
      description: description,
      type: type,
      difficulty: difficulty,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
      state: state ?? this.state,
      rewardType: rewardType,
      rewardValue: rewardValue,
      priority: priority,
    );
  }

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: MissionType.values.firstWhere((e) => e.toString() == json['type'], orElse: () => MissionType.daily),
      difficulty: MissionDifficulty.values.firstWhere((e) => e.toString() == json['difficulty'], orElse: () => MissionDifficulty.easy),
      targetValue: json['targetValue'] ?? 10,
      currentValue: json['currentValue'] ?? 0,
      state: MissionState.values.firstWhere((e) => e.toString() == json['state'], orElse: () => MissionState.inProgress),
      rewardType: json['rewardType'] ?? 'coins',
      rewardValue: json['rewardValue'] ?? 100,
      priority: json['priority'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'difficulty': difficulty.toString(),
      'targetValue': targetValue,
      'currentValue': currentValue,
      'state': state.toString(),
      'rewardType': rewardType,
      'rewardValue': rewardValue,
      'priority': priority,
    };
  }
}

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final bool isClaimed;
  final String tier; // 'bronze', 'silver', 'gold', 'diamond'
  final int rewardValue;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    this.currentValue = 0,
    this.isClaimed = false,
    required this.tier,
    required this.rewardValue,
  });

  AchievementModel copyWith({
    int? currentValue,
    bool? isClaimed,
  }) {
    return AchievementModel(
      id: id,
      title: title,
      description: description,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
      isClaimed: isClaimed ?? this.isClaimed,
      tier: tier,
      rewardValue: rewardValue,
    );
  }

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetValue: json['targetValue'] ?? 100,
      currentValue: json['currentValue'] ?? 0,
      isClaimed: json['isClaimed'] ?? false,
      tier: json['tier'] ?? 'bronze',
      rewardValue: json['rewardValue'] ?? 500,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'isClaimed': isClaimed,
      'tier': tier,
      'rewardValue': rewardValue,
    };
  }
}
