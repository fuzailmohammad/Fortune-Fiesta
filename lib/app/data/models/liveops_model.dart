class LiveEventModel {
  final String id;
  final String title;
  final String description;
  final String theme; // 'halloween', 'christmas', 'diwali', 'none'
  final String startTime; // ISO-8601
  final String endTime; // ISO-8601
  final String rewardType;
  final int rewardValue;
  final String currencyName;

  LiveEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.theme,
    required this.startTime,
    required this.endTime,
    required this.rewardType,
    required this.rewardValue,
    required this.currencyName,
  });

  factory LiveEventModel.fromJson(Map<String, dynamic> json) {
    return LiveEventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      theme: json['theme'] ?? 'none',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      rewardType: json['rewardType'] ?? 'coins',
      rewardValue: json['rewardValue'] ?? 0,
      currencyName: json['currencyName'] ?? 'Snowflakes',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'theme': theme,
      'startTime': startTime,
      'endTime': endTime,
      'rewardType': rewardType,
      'rewardValue': rewardValue,
      'currencyName': currencyName,
    };
  }
}

class SeasonModel {
  final String id;
  final String name;
  final int currentLevel;
  final int currentXp;
  final int maxLevel;
  final List<dynamic> rewardsTrack; // List of maps representing level locking rewards

  SeasonModel({
    required this.id,
    required this.name,
    required this.currentLevel,
    required this.currentXp,
    required this.maxLevel,
    required this.rewardsTrack,
  });

  SeasonModel copyWith({
    int? currentLevel,
    int? currentXp,
  }) {
    return SeasonModel(
      id: id,
      name: name,
      currentLevel: currentLevel ?? this.currentLevel,
      currentXp: currentXp ?? this.currentXp,
      maxLevel: maxLevel,
      rewardsTrack: rewardsTrack,
    );
  }

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    return SeasonModel(
      id: json['id'],
      name: json['name'],
      currentLevel: json['currentLevel'] ?? 1,
      currentXp: json['currentXp'] ?? 0,
      maxLevel: json['maxLevel'] ?? 10,
      rewardsTrack: json['rewardsTrack'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currentLevel': currentLevel,
      'currentXp': currentXp,
      'maxLevel': maxLevel,
      'rewardsTrack': rewardsTrack,
    };
  }
}

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String category; // 'news', 'patch_notes', 'event'
  final bool isRead;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.isRead = false,
  });

  AnnouncementModel copyWith({
    bool? isRead,
  }) {
    return AnnouncementModel(
      id: id,
      title: title,
      content: content,
      category: category,
      isRead: isRead ?? this.isRead,
    );
  }

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? '',
      category: json['category'] ?? 'news',
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'isRead': isRead,
    };
  }
}
