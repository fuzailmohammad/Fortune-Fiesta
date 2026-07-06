enum CollectibleRarity { common, rare, epic, legendary, mythic }

class CollectibleCard {
  final String id;
  final String albumId;
  final String name;
  final String description;
  final String iconName;
  final CollectibleRarity rarity;
  final bool isUnlocked;
  final int duplicateCount;
  final int recycleCoinValue;

  const CollectibleCard({
    required this.id,
    required this.albumId,
    required this.name,
    required this.description,
    required this.iconName,
    required this.rarity,
    this.isUnlocked = false,
    this.duplicateCount = 0,
    required this.recycleCoinValue,
  });

  CollectibleCard copyWith({
    bool? isUnlocked,
    int? duplicateCount,
  }) {
    return CollectibleCard(
      id: id,
      albumId: albumId,
      name: name,
      description: description,
      iconName: iconName,
      rarity: rarity,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      recycleCoinValue: recycleCoinValue,
    );
  }

  factory CollectibleCard.fromJson(Map<String, dynamic> json) {
    return CollectibleCard(
      id: json['id'] as String? ?? '',
      albumId: json['album_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Mystery Symbol',
      description: json['description'] as String? ?? '',
      iconName: json['icon_name'] as String? ?? 'sparkle',
      rarity: CollectibleRarity.values.firstWhere(
        (e) => e.name == (json['rarity'] as String? ?? 'common'),
        orElse: () => CollectibleRarity.common,
      ),
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      duplicateCount: json['duplicate_count'] as int? ?? 0,
      recycleCoinValue: json['recycle_coin_value'] as int? ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'album_id': albumId,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'rarity': rarity.name,
      'is_unlocked': isUnlocked,
      'duplicate_count': duplicateCount,
      'recycle_coin_value': recycleCoinValue,
    };
  }
}

class CollectibleAlbum {
  final String id;
  final String title;
  final String description;
  final String category; // 'fruit', 'gem', 'golden_symbols', 'legendary', 'season', 'machine'
  final List<CollectibleCard> cards;
  final int rewardCoins;
  final int rewardDiamonds;
  final String? rewardTitleId;
  final bool isCompleted;
  final bool isRewardClaimed;

  const CollectibleAlbum({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.cards,
    required this.rewardCoins,
    this.rewardDiamonds = 0,
    this.rewardTitleId,
    this.isCompleted = false,
    this.isRewardClaimed = false,
  });

  int get unlockedCount => cards.where((c) => c.isUnlocked).length;
  double get progressRatio => cards.isEmpty ? 0.0 : unlockedCount / cards.length;

  CollectibleAlbum copyWith({
    List<CollectibleCard>? cards,
    bool? isCompleted,
    bool? isRewardClaimed,
  }) {
    return CollectibleAlbum(
      id: id,
      title: title,
      description: description,
      category: category,
      cards: cards ?? this.cards,
      rewardCoins: rewardCoins,
      rewardDiamonds: rewardDiamonds,
      rewardTitleId: rewardTitleId,
      isCompleted: isCompleted ?? this.isCompleted,
      isRewardClaimed: isRewardClaimed ?? this.isRewardClaimed,
    );
  }

  factory CollectibleAlbum.fromJson(Map<String, dynamic> json) {
    final rawCards = json['cards'] as List<dynamic>? ?? [];
    return CollectibleAlbum(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Vault Album',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      cards: rawCards.map((c) => CollectibleCard.fromJson(c as Map<String, dynamic>)).toList(),
      rewardCoins: json['reward_coins'] as int? ?? 10000,
      rewardDiamonds: json['reward_diamonds'] as int? ?? 50,
      rewardTitleId: json['reward_title_id'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      isRewardClaimed: json['is_reward_claimed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'cards': cards.map((c) => c.toJson()).toList(),
      'reward_coins': rewardCoins,
      'reward_diamonds': rewardDiamonds,
      'reward_title_id': rewardTitleId,
      'is_completed': isCompleted,
      'is_reward_claimed': isRewardClaimed,
    };
  }
}
