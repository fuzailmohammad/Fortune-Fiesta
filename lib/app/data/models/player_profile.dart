class PlayerStats {
  final int lifetimeSpins;
  final int totalWins;
  final int highestWin;
  final int jackpotsWon;
  final int daysPlayed;
  final int adsWatched;

  PlayerStats({
    this.lifetimeSpins = 0,
    this.totalWins = 0,
    this.highestWin = 0,
    this.jackpotsWon = 0,
    this.daysPlayed = 1,
    this.adsWatched = 0,
  });

  PlayerStats copyWith({
    int? lifetimeSpins,
    int? totalWins,
    int? highestWin,
    int? jackpotsWon,
    int? daysPlayed,
    int? adsWatched,
  }) {
    return PlayerStats(
      lifetimeSpins: lifetimeSpins ?? this.lifetimeSpins,
      totalWins: totalWins ?? this.totalWins,
      highestWin: highestWin ?? this.highestWin,
      jackpotsWon: jackpotsWon ?? this.jackpotsWon,
      daysPlayed: daysPlayed ?? this.daysPlayed,
      adsWatched: adsWatched ?? this.adsWatched,
    );
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      lifetimeSpins: json['lifetimeSpins'] ?? 0,
      totalWins: json['totalWins'] ?? 0,
      highestWin: json['highestWin'] ?? 0,
      jackpotsWon: json['jackpotsWon'] ?? 0,
      daysPlayed: json['daysPlayed'] ?? 1,
      adsWatched: json['adsWatched'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lifetimeSpins': lifetimeSpins,
      'totalWins': totalWins,
      'highestWin': highestWin,
      'jackpotsWon': jackpotsWon,
      'daysPlayed': daysPlayed,
      'adsWatched': adsWatched,
    };
  }
}

class PlayerProfile {
  final String name;
  final int level;
  final int xp;
  final int streak;
  final int diamonds;
  final String avatarFrame;
  final PlayerStats stats;

  PlayerProfile({
    this.name = 'FIESTA PLAYER',
    this.level = 1,
    this.xp = 0,
    this.streak = 1,
    this.diamonds = 150,
    this.avatarFrame = 'gold',
    PlayerStats? stats,
  }) : stats = stats ?? PlayerStats();

  PlayerProfile copyWith({
    String? name,
    int? level,
    int? xp,
    int? streak,
    int? diamonds,
    String? avatarFrame,
    PlayerStats? stats,
  }) {
    return PlayerProfile(
      name: name ?? this.name,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      diamonds: diamonds ?? this.diamonds,
      avatarFrame: avatarFrame ?? this.avatarFrame,
      stats: stats ?? this.stats,
    );
  }

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      name: json['name'] ?? 'FIESTA PLAYER',
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      streak: json['streak'] ?? 1,
      diamonds: json['diamonds'] ?? 150,
      avatarFrame: json['avatarFrame'] ?? 'gold',
      stats: json['stats'] != null 
          ? PlayerStats.fromJson(json['stats']) 
          : PlayerStats(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'xp': xp,
      'streak': streak,
      'diamonds': diamonds,
      'avatarFrame': avatarFrame,
      'stats': stats.toJson(),
    };
  }
}
