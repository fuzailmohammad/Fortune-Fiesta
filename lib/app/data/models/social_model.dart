enum LeagueTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  master,
  champion,
}

class SocialPlayerProfileModel {
  final String id;
  final String name;
  final int level;
  final String frame;
  final String title;
  final LeagueTier league;
  final int score;
  final int streak;
  final int wins;
  final int jackpots;

  SocialPlayerProfileModel({
    required this.id,
    required this.name,
    required this.level,
    required this.frame,
    required this.title,
    required this.league,
    required this.score,
    this.streak = 0,
    this.wins = 0,
    this.jackpots = 0,
  });

  SocialPlayerProfileModel copyWith({
    String? name,
    String? frame,
    String? title,
    LeagueTier? league,
    int? score,
    int? streak,
    int? wins,
    int? jackpots,
  }) {
    return SocialPlayerProfileModel(
      id: id,
      name: name ?? this.name,
      level: level,
      frame: frame ?? this.frame,
      title: title ?? this.title,
      league: league ?? this.league,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      wins: wins ?? this.wins,
      jackpots: jackpots ?? this.jackpots,
    );
  }

  factory SocialPlayerProfileModel.fromJson(Map<String, dynamic> json) {
    return SocialPlayerProfileModel(
      id: json['id'],
      name: json['name'],
      level: json['level'] ?? 1,
      frame: json['frame'] ?? 'none',
      title: json['title'] ?? 'ROOKIE',
      league: LeagueTier.values.firstWhere((e) => e.toString() == json['league'], orElse: () => LeagueTier.gold),
      score: json['score'] ?? 0,
      streak: json['streak'] ?? 0,
      wins: json['wins'] ?? 0,
      jackpots: json['jackpots'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'frame': frame,
      'title': title,
      'league': league.toString(),
      'score': score,
      'streak': streak,
      'wins': wins,
      'jackpots': jackpots,
    };
  }
}

class FriendModel {
  final String id;
  final String name;
  final bool isOnline;
  final String recentActivity;

  FriendModel({
    required this.id,
    required this.name,
    required this.isOnline,
    required this.recentActivity,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'],
      name: json['name'],
      isOnline: json['isOnline'] ?? false,
      recentActivity: json['recentActivity'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isOnline': isOnline,
      'recentActivity': recentActivity,
    };
  }
}

class LeaderboardEntryModel {
  final int rank;
  final String name;
  final int score;
  final int level;
  final String frame;
  final String trend; // 'up', 'down', 'stable'
  final bool isOnline;

  LeaderboardEntryModel({
    required this.rank,
    required this.name,
    required this.score,
    required this.level,
    required this.frame,
    required this.trend,
    required this.isOnline,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: json['rank'] ?? 1,
      name: json['name'],
      score: json['score'] ?? 0,
      level: json['level'] ?? 1,
      frame: json['frame'] ?? 'none',
      trend: json['trend'] ?? 'stable',
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'name': name,
      'score': score,
      'level': level,
      'frame': frame,
      'trend': trend,
      'isOnline': isOnline,
    };
  }
}
