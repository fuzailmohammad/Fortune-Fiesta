enum PlayerMoodState {
  neutral,
  energetic,
  frustratedLosing,
  triumphantWinning,
  fatiguedLongSession,
  hurriedShortSession,
  curiousExplorer,
}

enum PlayerPersonality {
  collector,
  competitive,
  casual,
  dailyPlayer,
  weekendPlayer,
  explorer,
  vip,
}

enum WelcomeBackTier {
  oneDay,
  threeDays,
  sevenDays,
  thirtyDays,
}

enum AtmosphereMode {
  morning,
  day,
  night,
  weekend,
  festival,
}

class TimelineMilestone {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String category;
  final String iconName;
  final bool isUnlocked;

  const TimelineMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    required this.iconName,
    this.isUnlocked = false,
  });

  TimelineMilestone copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    String? category,
    String? iconName,
    bool? isUnlocked,
  }) {
    return TimelineMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class SmartRecommendation {
  final String id;
  final String title;
  final String subtitle;
  final String actionLabel;
  final String iconName;
  final int priority;
  final String targetRoute;

  const SmartRecommendation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.iconName,
    required this.priority,
    required this.targetRoute,
  });
}

class WelcomeBackConfig {
  final WelcomeBackTier tier;
  final String title;
  final String subtitle;
  final String motivationalMessage;
  final int daysAway;

  const WelcomeBackConfig({
    required this.tier,
    required this.title,
    required this.subtitle,
    required this.motivationalMessage,
    required this.daysAway,
  });
}
