enum AudioEvent {
  spinStart,
  reelStop,
  buttonPress,
  coinBurst,
  levelUp,
  winSmall,
  winBig,
  jackpot,
  winnerSpecial,
}

enum HapticProfile {
  veryLight,
  light,
  medium,
  strong,
  success,
  celebration,
}

class AudioSettingsModel {
  final double musicVolume;
  final double sfxVolume;
  final bool hapticsEnabled;
  final bool isMuted;

  AudioSettingsModel({
    this.musicVolume = 0.8,
    this.sfxVolume = 0.8,
    this.hapticsEnabled = true,
    this.isMuted = false,
  });

  AudioSettingsModel copyWith({
    double? musicVolume,
    double? sfxVolume,
    bool? hapticsEnabled,
    bool? isMuted,
  }) {
    return AudioSettingsModel(
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  factory AudioSettingsModel.fromJson(Map<String, dynamic> json) {
    return AudioSettingsModel(
      musicVolume: (json['musicVolume'] ?? 0.8).toDouble(),
      sfxVolume: (json['sfxVolume'] ?? 0.8).toDouble(),
      hapticsEnabled: json['hapticsEnabled'] ?? true,
      isMuted: json['isMuted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'musicVolume': musicVolume,
      'sfxVolume': sfxVolume,
      'hapticsEnabled': hapticsEnabled,
      'isMuted': isMuted,
    };
  }
}
