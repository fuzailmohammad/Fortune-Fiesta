enum GraphicsQuality {
  low,
  medium,
  high,
  ultra,
}

enum FrameRate {
  fps60,
  fps90,
  fps120,
  adaptive,
}

enum ColorBlindMode {
  none,
  protanopia,
  deuteranopia,
  tritanopia,
}

class GameplaySettings {
  final bool autoSpin;
  final bool turboSpin;
  final bool showWinningLine;
  final bool autoCollect;

  GameplaySettings({
    this.autoSpin = false,
    this.turboSpin = false,
    this.showWinningLine = true,
    this.autoCollect = true,
  });

  GameplaySettings copyWith({
    bool? autoSpin,
    bool? turboSpin,
    bool? showWinningLine,
    bool? autoCollect,
  }) {
    return GameplaySettings(
      autoSpin: autoSpin ?? this.autoSpin,
      turboSpin: turboSpin ?? this.turboSpin,
      showWinningLine: showWinningLine ?? this.showWinningLine,
      autoCollect: autoCollect ?? this.autoCollect,
    );
  }

  factory GameplaySettings.fromJson(Map<String, dynamic> json) {
    return GameplaySettings(
      autoSpin: json['autoSpin'] ?? false,
      turboSpin: json['turboSpin'] ?? false,
      showWinningLine: json['showWinningLine'] ?? true,
      autoCollect: json['autoCollect'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoSpin': autoSpin,
      'turboSpin': turboSpin,
      'showWinningLine': showWinningLine,
      'autoCollect': autoCollect,
    };
  }
}

class GraphicsSettings {
  final GraphicsQuality quality;
  final FrameRate fps;
  final bool batterySaver;

  GraphicsSettings({
    this.quality = GraphicsQuality.high,
    this.fps = FrameRate.fps60,
    this.batterySaver = false,
  });

  GraphicsSettings copyWith({
    GraphicsQuality? quality,
    FrameRate? fps,
    bool? batterySaver,
  }) {
    return GraphicsSettings(
      quality: quality ?? this.quality,
      fps: fps ?? this.fps,
      batterySaver: batterySaver ?? this.batterySaver,
    );
  }

  factory GraphicsSettings.fromJson(Map<String, dynamic> json) {
    return GraphicsSettings(
      quality: GraphicsQuality.values.firstWhere((e) => e.toString() == json['quality'], orElse: () => GraphicsQuality.high),
      fps: FrameRate.values.firstWhere((e) => e.toString() == json['fps'], orElse: () => FrameRate.fps60),
      batterySaver: json['batterySaver'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quality': quality.toString(),
      'fps': fps.toString(),
      'batterySaver': batterySaver,
    };
  }
}

class AccessibilitySettings {
  final bool reduceMotion;
  final bool highContrast;
  final ColorBlindMode colorblind;
  final double textScale;

  AccessibilitySettings({
    this.reduceMotion = false,
    this.highContrast = false,
    this.colorblind = ColorBlindMode.none,
    this.textScale = 1.0,
  });

  AccessibilitySettings copyWith({
    bool? reduceMotion,
    bool? highContrast,
    ColorBlindMode? colorblind,
    double? textScale,
  }) {
    return AccessibilitySettings(
      reduceMotion: reduceMotion ?? this.reduceMotion,
      highContrast: highContrast ?? this.highContrast,
      colorblind: colorblind ?? this.colorblind,
      textScale: textScale ?? this.textScale,
    );
  }

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      reduceMotion: json['reduceMotion'] ?? false,
      highContrast: json['highContrast'] ?? false,
      colorblind: ColorBlindMode.values.firstWhere((e) => e.toString() == json['colorblind'], orElse: () => ColorBlindMode.none),
      textScale: (json['textScale'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reduceMotion': reduceMotion,
      'highContrast': highContrast,
      'colorblind': colorblind.toString(),
      'textScale': textScale,
    };
  }
}

class NotificationSettings {
  final bool dailyRewards;
  final bool friends;
  final bool offers;
  final bool leaderboards;

  NotificationSettings({
    this.dailyRewards = true,
    this.friends = true,
    this.offers = true,
    this.leaderboards = true,
  });

  NotificationSettings copyWith({
    bool? dailyRewards,
    bool? friends,
    bool? offers,
    bool? leaderboards,
  }) {
    return NotificationSettings(
      dailyRewards: dailyRewards ?? this.dailyRewards,
      friends: friends ?? this.friends,
      offers: offers ?? this.offers,
      leaderboards: leaderboards ?? this.leaderboards,
    );
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      dailyRewards: json['dailyRewards'] ?? true,
      friends: json['friends'] ?? true,
      offers: json['offers'] ?? true,
      leaderboards: json['leaderboards'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyRewards': dailyRewards,
      'friends': friends,
      'offers': offers,
      'leaderboards': leaderboards,
    };
  }
}

class SettingsModel {
  final GameplaySettings gameplay;
  final GraphicsSettings graphics;
  final AccessibilitySettings accessibility;
  final NotificationSettings notifications;

  SettingsModel({
    GameplaySettings? gameplay,
    GraphicsSettings? graphics,
    AccessibilitySettings? accessibility,
    NotificationSettings? notifications,
  })  : gameplay = gameplay ?? GameplaySettings(),
        graphics = graphics ?? GraphicsSettings(),
        accessibility = accessibility ?? AccessibilitySettings(),
        notifications = notifications ?? NotificationSettings();

  SettingsModel copyWith({
    GameplaySettings? gameplay,
    GraphicsSettings? graphics,
    AccessibilitySettings? accessibility,
    NotificationSettings? notifications,
  }) {
    return SettingsModel(
      gameplay: gameplay ?? this.gameplay,
      graphics: graphics ?? this.graphics,
      accessibility: accessibility ?? this.accessibility,
      notifications: notifications ?? this.notifications,
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      gameplay: json['gameplay'] != null ? GameplaySettings.fromJson(json['gameplay']) : GameplaySettings(),
      graphics: json['graphics'] != null ? GraphicsSettings.fromJson(json['graphics']) : GraphicsSettings(),
      accessibility: json['accessibility'] != null ? AccessibilitySettings.fromJson(json['accessibility']) : AccessibilitySettings(),
      notifications: json['notifications'] != null ? NotificationSettings.fromJson(json['notifications']) : NotificationSettings(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameplay': gameplay.toJson(),
      'graphics': graphics.toJson(),
      'accessibility': accessibility.toJson(),
      'notifications': notifications.toJson(),
    };
  }
}
