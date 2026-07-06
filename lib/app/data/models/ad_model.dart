enum AdPlacement {
  doubleWin,
  freeCoins,
  luckyWheelRetry,
  mysteryChestOpen,
  dailyMultiplier,
}

enum AdState {
  uninitialized,
  preloading,
  ready,
  playing,
  failed,
}

class PlacementConfig {
  final AdPlacement placement;
  final bool isEnabled;
  final int dailyLimit;
  final int cooldownSeconds;

  PlacementConfig({
    required this.placement,
    this.isEnabled = true,
    this.dailyLimit = 5,
    this.cooldownSeconds = 180, // 3 minutes
  });

  factory PlacementConfig.fromJson(Map<String, dynamic> json) {
    return PlacementConfig(
      placement: AdPlacement.values.firstWhere((e) => e.toString() == json['placement'], orElse: () => AdPlacement.doubleWin),
      isEnabled: json['isEnabled'] ?? true,
      dailyLimit: json['dailyLimit'] ?? 5,
      cooldownSeconds: json['cooldownSeconds'] ?? 180,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placement': placement.toString(),
      'isEnabled': isEnabled,
      'dailyLimit': dailyLimit,
      'cooldownSeconds': cooldownSeconds,
    };
  }
}

class AdAnalytics {
  final int impressions;
  final int clicks;
  final int completions;
  final double simulatedRevenue;

  AdAnalytics({
    this.impressions = 0,
    this.clicks = 0,
    this.completions = 0,
    this.simulatedRevenue = 0.0,
  });

  AdAnalytics copyWith({
    int? impressions,
    int? clicks,
    int? completions,
    double? simulatedRevenue,
  }) {
    return AdAnalytics(
      impressions: impressions ?? this.impressions,
      clicks: clicks ?? this.clicks,
      completions: completions ?? this.completions,
      simulatedRevenue: simulatedRevenue ?? this.simulatedRevenue,
    );
  }

  factory AdAnalytics.fromJson(Map<String, dynamic> json) {
    return AdAnalytics(
      impressions: json['impressions'] ?? 0,
      clicks: json['clicks'] ?? 0,
      completions: json['completions'] ?? 0,
      simulatedRevenue: (json['simulatedRevenue'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'impressions': impressions,
      'clicks': clicks,
      'completions': completions,
      'simulatedRevenue': simulatedRevenue,
    };
  }
}
