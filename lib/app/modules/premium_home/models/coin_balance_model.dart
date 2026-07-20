class CoinBalanceModel {
  final int coins;
  final String lastUpdated;

  CoinBalanceModel({
    required this.coins,
    required this.lastUpdated,
  });

  CoinBalanceModel copyWith({
    int? coins,
    String? lastUpdated,
  }) {
    return CoinBalanceModel(
      coins: coins ?? this.coins,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory CoinBalanceModel.fromJson(Map<String, dynamic> json) {
    return CoinBalanceModel(
      coins: json['coins'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'lastUpdated': lastUpdated,
      };
}
