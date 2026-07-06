class StatisticsModel {
  final int totalSpins;
  final int totalWins;
  final int highestWin;

  StatisticsModel({
    required this.totalSpins,
    required this.totalWins,
    required this.highestWin,
  });

  StatisticsModel copyWith({
    int? totalSpins,
    int? totalWins,
    int? highestWin,
  }) {
    return StatisticsModel(
      totalSpins: totalSpins ?? this.totalSpins,
      totalWins: totalWins ?? this.totalWins,
      highestWin: highestWin ?? this.highestWin,
    );
  }

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalSpins: json['totalSpins'] as int? ?? 0,
      totalWins: json['totalWins'] as int? ?? 0,
      highestWin: json['highestWin'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalSpins': totalSpins,
        'totalWins': totalWins,
        'highestWin': highestWin,
      };
}
