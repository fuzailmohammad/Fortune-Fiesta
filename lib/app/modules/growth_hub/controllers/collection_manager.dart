import 'dart:math' as math;

import 'package:fortune_fiesta/app/core/logger/app_logger.dart';
import 'package:fortune_fiesta/app/data/models/collection_model.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/cosmetic_manager.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/premium_home_controller.dart';
import 'package:get/get.dart';

class CollectionManager extends GetxController {
  static CollectionManager get to => Get.find();

  final RxList<CollectibleAlbum> albums = <CollectibleAlbum>[].obs;
  final RxInt duplicateDust = 0.obs; // Earned from duplicate card recycling

  @override
  void onInit() {
    super.onInit();
    _loadInitialAlbums();
  }

  void _loadInitialAlbums() {
    albums.assignAll([
      CollectibleAlbum(
        id: 'album_fruit',
        title: 'Fruit Collection',
        description: 'Classic Vegas fruit symbols and lucky cherries.',
        category: 'fruit',
        rewardCoins: 25000,
        rewardDiamonds: 50,
        rewardTitleId: 'title_collector',
        cards: [
          const CollectibleCard(
              id: 'f_cherry',
              albumId: 'album_fruit',
              name: 'Neon Cherry',
              description: 'Sweet beginner symbol.',
              iconName: 'cherry',
              rarity: CollectibleRarity.common,
              isUnlocked: true,
              recycleCoinValue: 100),
          const CollectibleCard(
              id: 'f_lemon',
              albumId: 'album_fruit',
              name: 'Golden Lemon',
              description: 'Zesty luck booster.',
              iconName: 'lemon',
              rarity: CollectibleRarity.common,
              isUnlocked: true,
              recycleCoinValue: 100),
          const CollectibleCard(
              id: 'f_melon',
              albumId: 'album_fruit',
              name: 'Royal Watermelon',
              description: 'Juicy jackpot symbol.',
              iconName: 'melon',
              rarity: CollectibleRarity.rare,
              isUnlocked: true,
              recycleCoinValue: 250),
          const CollectibleCard(
              id: 'f_grape',
              albumId: 'album_fruit',
              name: 'Vegas Grapes',
              description: 'Classic cluster win.',
              iconName: 'grape',
              rarity: CollectibleRarity.rare,
              isUnlocked: false,
              recycleCoinValue: 250),
          const CollectibleCard(
              id: 'f_starfruit',
              albumId: 'album_fruit',
              name: 'Cosmic Starfruit',
              description: 'Legendary space fruit.',
              iconName: 'star',
              rarity: CollectibleRarity.legendary,
              isUnlocked: false,
              recycleCoinValue: 1000),
        ],
      ),
      CollectibleAlbum(
        id: 'album_gem',
        title: 'Gem Collection',
        description: 'Precious rubies, sapphires, and royal diamonds.',
        category: 'gem',
        rewardCoins: 75000,
        rewardDiamonds: 150,
        rewardTitleId: 'title_diamond_king',
        cards: [
          const CollectibleCard(
              id: 'g_ruby',
              albumId: 'album_gem',
              name: 'Fiery Ruby',
              description: 'Blazing fortune gem.',
              iconName: 'ruby',
              rarity: CollectibleRarity.rare,
              isUnlocked: true,
              recycleCoinValue: 300),
          const CollectibleCard(
              id: 'g_sapphire',
              albumId: 'album_gem',
              name: 'Ocean Sapphire',
              description: 'Deep sea treasures.',
              iconName: 'sapphire',
              rarity: CollectibleRarity.rare,
              isUnlocked: true,
              recycleCoinValue: 300),
          const CollectibleCard(
              id: 'g_emerald',
              albumId: 'album_gem',
              name: 'Jungle Emerald',
              description: 'Ancient Aztec crystal.',
              iconName: 'emerald',
              rarity: CollectibleRarity.epic,
              isUnlocked: false,
              recycleCoinValue: 500),
          const CollectibleCard(
              id: 'g_diamond',
              albumId: 'album_gem',
              name: 'Flawless Diamond',
              description: 'The ultimate luxury stone.',
              iconName: 'diamond',
              rarity: CollectibleRarity.legendary,
              isUnlocked: false,
              recycleCoinValue: 1500),
          const CollectibleCard(
              id: 'g_prism',
              albumId: 'album_gem',
              name: 'Rainbow Prism',
              description: 'Reflects infinite luck.',
              iconName: 'prism',
              rarity: CollectibleRarity.mythic,
              isUnlocked: false,
              recycleCoinValue: 3000),
        ],
      ),
      CollectibleAlbum(
        id: 'album_golden',
        title: 'Golden Symbols',
        description: 'Solid gold bars, lucky bells, and horseshoes.',
        category: 'golden_symbols',
        rewardCoins: 150000,
        rewardDiamonds: 300,
        rewardTitleId: 'title_coin_hunter',
        cards: [
          const CollectibleCard(
              id: 'gs_bell',
              albumId: 'album_golden',
              name: 'Liberty Bell',
              description: 'Ring for Mega Wins.',
              iconName: 'bell',
              rarity: CollectibleRarity.common,
              isUnlocked: true,
              recycleCoinValue: 150),
          const CollectibleCard(
              id: 'gs_shoe',
              albumId: 'album_golden',
              name: 'Golden Horseshoe',
              description: 'Attracts good fortune.',
              iconName: 'shoe',
              rarity: CollectibleRarity.rare,
              isUnlocked: true,
              recycleCoinValue: 350),
          const CollectibleCard(
              id: 'gs_bar',
              albumId: 'album_golden',
              name: 'Triple Gold Bar',
              description: 'Vault standard ingot.',
              iconName: 'bar',
              rarity: CollectibleRarity.epic,
              isUnlocked: true,
              recycleCoinValue: 700),
          const CollectibleCard(
              id: 'gs_crown',
              albumId: 'album_golden',
              name: 'Imperial Crown',
              description: 'Worn by High Rollers.',
              iconName: 'crown',
              rarity: CollectibleRarity.legendary,
              isUnlocked: false,
              recycleCoinValue: 2000),
          const CollectibleCard(
              id: 'gs_vault',
              albumId: 'album_golden',
              name: 'Master Vault Door',
              description: 'Unlocks infinite wealth.',
              iconName: 'vault',
              rarity: CollectibleRarity.mythic,
              isUnlocked: false,
              recycleCoinValue: 5000),
        ],
      ),
      CollectibleAlbum(
        id: 'album_legendary',
        title: 'Legendary Symbols',
        description: 'Mythic beasts, dragons, and phoenix wings.',
        category: 'legendary',
        rewardCoins: 500000,
        rewardDiamonds: 1000,
        rewardTitleId: 'title_legend',
        cards: [
          const CollectibleCard(
              id: 'l_dragon',
              albumId: 'album_legendary',
              name: 'Golden Dragon',
              description: 'Guardian of jackpots.',
              iconName: 'dragon',
              rarity: CollectibleRarity.epic,
              isUnlocked: true,
              recycleCoinValue: 800),
          const CollectibleCard(
              id: 'l_phoenix',
              albumId: 'album_legendary',
              name: 'Solar Phoenix',
              description: 'Rises from the ashes with coins.',
              iconName: 'phoenix',
              rarity: CollectibleRarity.legendary,
              isUnlocked: false,
              recycleCoinValue: 2500),
          const CollectibleCard(
              id: 'l_peacock',
              albumId: 'album_legendary',
              name: 'Royal Peacock',
              description: 'Displays radiant fortunes.',
              iconName: 'peacock',
              rarity: CollectibleRarity.epic,
              isUnlocked: true,
              recycleCoinValue: 800),
          const CollectibleCard(
              id: 'l_tiger',
              albumId: 'album_legendary',
              name: 'Jade Tiger',
              description: 'Fierce winning streak.',
              iconName: 'tiger',
              rarity: CollectibleRarity.legendary,
              isUnlocked: false,
              recycleCoinValue: 2500),
          const CollectibleCard(
              id: 'l_qilin',
              albumId: 'album_legendary',
              name: 'Celestial Qilin',
              description: 'The rarest beast of Vegas.',
              iconName: 'qilin',
              rarity: CollectibleRarity.mythic,
              isUnlocked: false,
              recycleCoinValue: 10000),
        ],
      ),
      CollectibleAlbum(
        id: 'album_season',
        title: 'Season Collection',
        description: 'Limited-time festival souvenirs and event badges.',
        category: 'season',
        rewardCoins: 200000,
        rewardDiamonds: 500,
        rewardTitleId: 'title_champion',
        cards: [
          const CollectibleCard(
              id: 's_mask',
              albumId: 'album_season',
              name: 'Fiesta Mask',
              description: 'Carnival celebration gear.',
              iconName: 'mask',
              rarity: CollectibleRarity.rare,
              isUnlocked: true,
              recycleCoinValue: 400),
          const CollectibleCard(
              id: 's_firework',
              albumId: 'album_season',
              name: 'Midnight Firework',
              description: 'Lights up the night sky.',
              iconName: 'firework',
              rarity: CollectibleRarity.epic,
              isUnlocked: true,
              recycleCoinValue: 900),
          const CollectibleCard(
              id: 's_trophy',
              albumId: 'album_season',
              name: 'Grand Fiesta Trophy',
              description: 'Awarded to top spinners.',
              iconName: 'trophy',
              rarity: CollectibleRarity.legendary,
              isUnlocked: false,
              recycleCoinValue: 3000),
          const CollectibleCard(
              id: 's_confetti',
              albumId: 'album_season',
              name: 'Golden Confetti Cannon',
              description: 'Never-ending celebration.',
              iconName: 'confetti',
              rarity: CollectibleRarity.epic,
              isUnlocked: false,
              recycleCoinValue: 900),
        ],
      ),
      CollectibleAlbum(
        id: 'album_machine',
        title: 'Machine Collection',
        description: 'Blueprints for iconic slot machine visual themes.',
        category: 'machine',
        rewardCoins: 350000,
        rewardDiamonds: 750,
        rewardTitleId: 'title_jackpot_master',
        cards: [
          const CollectibleCard(
              id: 'm_classic',
              albumId: 'album_machine',
              name: 'Classic Blueprint',
              description: 'Original 1970s Vegas mechanical reels.',
              iconName: 'slot',
              rarity: CollectibleRarity.common,
              isUnlocked: true,
              recycleCoinValue: 200),
          const CollectibleCard(
              id: 'm_cyber',
              albumId: 'album_machine',
              name: 'Cyber 2077 Matrix',
              description: 'Neon grid futuristic reels.',
              iconName: 'cyber',
              rarity: CollectibleRarity.rare,
              isUnlocked: true,
              recycleCoinValue: 500),
          const CollectibleCard(
              id: 'm_galaxy',
              albumId: 'album_machine',
              name: 'Deep Space Nebula',
              description: 'Spin among constellations.',
              iconName: 'galaxy',
              rarity: CollectibleRarity.epic,
              isUnlocked: false,
              recycleCoinValue: 1000),
          const CollectibleCard(
              id: 'm_ancient',
              albumId: 'album_machine',
              name: 'Pharaoh Gold Vault',
              description: 'Secrets of the pyramids.',
              iconName: 'pyramid',
              rarity: CollectibleRarity.legendary,
              isUnlocked: false,
              recycleCoinValue: 3500),
          const CollectibleCard(
              id: 'm_steampunk',
              albumId: 'album_machine',
              name: 'Brass Gear Engine',
              description: 'Steam-powered mechanical marvel.',
              iconName: 'gear',
              rarity: CollectibleRarity.mythic,
              isUnlocked: false,
              recycleCoinValue: 7500),
        ],
      ),
    ]);
  }

  // 🎁 Simulate opening a Mystery Symbol Booster Pack
  CollectibleCard openBoosterPack() {
    final math.Random random = math.Random();
    final allCards = albums.expand((a) => a.cards).toList();
    final CollectibleCard drawnCard = allCards[random.nextInt(allCards.length)];

    // Find album and update card
    for (int i = 0; i < albums.length; i++) {
      final album = albums[i];
      final cardIdx = album.cards.indexWhere((c) => c.id == drawnCard.id);
      if (cardIdx != -1) {
        final currentCard = album.cards[cardIdx];
        final updatedCards = List<CollectibleCard>.from(album.cards);

        if (!currentCard.isUnlocked) {
          updatedCards[cardIdx] = currentCard.copyWith(isUnlocked: true);
          AppLogger.i(
              '✨ UNLOCKED NEW CARD: ${currentCard.name} in ${album.title}!',
              tag: 'CollectionManager');
        } else {
          updatedCards[cardIdx] = currentCard.copyWith(
              duplicateCount: currentCard.duplicateCount + 1);
          duplicateDust.value += currentCard.recycleCoinValue;
          AppLogger.d(
              'Recycled duplicate ${currentCard.name} for +${currentCard.recycleCoinValue} dust.',
              tag: 'CollectionManager');
        }

        // Check if album completed
        final bool nowCompleted = updatedCards.every((c) => c.isUnlocked);
        albums[i] =
            album.copyWith(cards: updatedCards, isCompleted: nowCompleted);
        break;
      }
    }
    return drawnCard;
  }

  // 🏆 Claim Album Completion Jackpot
  bool claimAlbumReward(String albumId) {
    final idx = albums.indexWhere((a) => a.id == albumId);
    if (idx == -1) return false;

    final album = albums[idx];
    if (album.unlockedCount < album.cards.length || album.isRewardClaimed) {
      return false;
    }

    // Grant Coins via PremiumHomeController
    if (Get.isRegistered<PremiumHomeController>()) {
      Get.find<PremiumHomeController>().coins.value += album.rewardCoins;
    }

    // Grant Unlockable Title via CosmeticManager
    if (album.rewardTitleId != null && Get.isRegistered<CosmeticManager>()) {
      Get.find<CosmeticManager>().unlockItem(album.rewardTitleId!);
    }

    albums[idx] = album.copyWith(isRewardClaimed: true);
    AppLogger.i(
        '🎉 CLAIMED ALBUM REWARD: ${album.title} (+${album.rewardCoins} Coins)!',
        tag: 'CollectionManager');
    return true;
  }
}
