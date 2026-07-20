enum CosmeticType {
  title,
  avatar,
  frame,
  machineSkin,
  coinTrail,
  confettiTheme,
  background,
  banner,
}

enum SeasonalTheme {
  none,
  winter,
  summer,
  halloween,
  christmas,
  diwali,
  ramadan,
  anniversary,
}

class CosmeticItem {
  final String id;
  final String name;
  final String description;
  final CosmeticType type;
  final SeasonalTheme seasonalTheme;
  final String iconName;
  final int previewColorValue;
  final bool isUnlocked;
  final bool isEquipped;
  final String unlockRequirement;

  const CosmeticItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.seasonalTheme = SeasonalTheme.none,
    required this.iconName,
    required this.previewColorValue,
    this.isUnlocked = false,
    this.isEquipped = false,
    required this.unlockRequirement,
  });

  CosmeticItem copyWith({
    bool? isUnlocked,
    bool? isEquipped,
  }) {
    return CosmeticItem(
      id: id,
      name: name,
      description: description,
      type: type,
      seasonalTheme: seasonalTheme,
      iconName: iconName,
      previewColorValue: previewColorValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isEquipped: isEquipped ?? this.isEquipped,
      unlockRequirement: unlockRequirement,
    );
  }

  factory CosmeticItem.fromJson(Map<String, dynamic> json) {
    return CosmeticItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Cosmetic Item',
      description: json['description'] as String? ?? '',
      type: CosmeticType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'title'),
        orElse: () => CosmeticType.title,
      ),
      seasonalTheme: SeasonalTheme.values.firstWhere(
        (e) => e.name == (json['seasonal_theme'] as String? ?? 'none'),
        orElse: () => SeasonalTheme.none,
      ),
      iconName: json['icon_name'] as String? ?? 'stars',
      previewColorValue: json['preview_color_value'] as int? ?? 0xFFE5A93C,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      isEquipped: json['is_equipped'] as bool? ?? false,
      unlockRequirement: json['unlock_requirement'] as String? ?? 'Unlocked via Play',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'seasonal_theme': seasonalTheme.name,
      'icon_name': iconName,
      'preview_color_value': previewColorValue,
      'is_unlocked': isUnlocked,
      'is_equipped': isEquipped,
      'unlock_requirement': unlockRequirement,
    };
  }
}
