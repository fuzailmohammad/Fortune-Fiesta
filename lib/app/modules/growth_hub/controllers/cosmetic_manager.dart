import 'package:fortune_fiesta/app/core/logger/app_logger.dart';
import 'package:fortune_fiesta/app/data/models/cosmetic_model.dart';
import 'package:get/get.dart';

class CosmeticManager extends GetxController {
  static CosmeticManager get to => Get.find();

  final RxList<CosmeticItem> allItems = <CosmeticItem>[].obs;
  final Rx<SeasonalTheme> activeSeasonalTheme = SeasonalTheme.none.obs;

  // Equipped shortcuts
  final RxString equippedTitleId = 'title_lucky_spinner'.obs;
  final RxString equippedMachineSkinId = 'skin_classic'.obs;
  final RxString equippedAvatarId = 'avatar_king'.obs;
  final RxString equippedCoinTrailId = 'trail_gold'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialCosmetics();
  }

  void _loadInitialCosmetics() {
    allItems.assignAll([
      // 🏆 Player Titles
      const CosmeticItem(
          id: 'title_lucky_spinner',
          name: 'Lucky Spinner',
          description: 'Beginner spinner title.',
          type: CosmeticType.title,
          iconName: 'stars',
          previewColorValue: 0xFF00E676,
          isUnlocked: true,
          isEquipped: true,
          unlockRequirement: 'Default Unlocked'),
      const CosmeticItem(
          id: 'title_coin_hunter',
          name: 'Coin Hunter',
          description: 'Master of treasure collection.',
          type: CosmeticType.title,
          iconName: 'monetization_on',
          previewColorValue: 0xFFFFD700,
          isUnlocked: true,
          unlockRequirement: 'Complete Golden Symbols Album'),
      const CosmeticItem(
          id: 'title_diamond_king',
          name: 'Diamond King',
          description: 'High roller gemstone royalty.',
          type: CosmeticType.title,
          iconName: 'diamond',
          previewColorValue: 0xFF00E5FF,
          isUnlocked: false,
          unlockRequirement: 'Complete Gem Collection Album'),
      const CosmeticItem(
          id: 'title_jackpot_master',
          name: 'Jackpot Master',
          description: 'Unlocking Vegas mega wins.',
          type: CosmeticType.title,
          iconName: 'emoji_events',
          previewColorValue: 0xFFFF9100,
          isUnlocked: false,
          unlockRequirement: 'Win 5 Mega Jackpots'),
      const CosmeticItem(
          id: 'title_legend',
          name: 'Legend',
          description: 'The absolute pinnacle of Fiesta luck.',
          type: CosmeticType.title,
          iconName: 'military_tech',
          previewColorValue: 0xFFE040FB,
          isUnlocked: false,
          unlockRequirement: 'Complete Legendary Symbols Album'),
      const CosmeticItem(
          id: 'title_vip_elite',
          name: 'VIP Elite',
          description: 'Exclusive lounge member.',
          type: CosmeticType.title,
          iconName: 'workspace_premium',
          previewColorValue: 0xFFD500F9,
          isUnlocked: true,
          unlockRequirement: 'Reach VIP Level 3'),
      const CosmeticItem(
          id: 'title_collector',
          name: 'Collector',
          description: 'Archivist of all symbol sets.',
          type: CosmeticType.title,
          iconName: 'collections_bookmark',
          previewColorValue: 0xFF76FF03,
          isUnlocked: false,
          unlockRequirement: 'Complete Fruit Collection Album'),
      const CosmeticItem(
          id: 'title_champion',
          name: 'Champion',
          description: 'Victor of seasonal festivals.',
          type: CosmeticType.title,
          iconName: 'social_leaderboard',
          previewColorValue: 0xFFFF1744,
          isUnlocked: false,
          unlockRequirement: 'Complete Season Collection Album'),

      // 🎰 Special Machines (Visual Skins Only)
      const CosmeticItem(
          id: 'skin_classic',
          name: 'Classic Machine',
          description: 'Original gold & purple Vegas reels.',
          type: CosmeticType.machineSkin,
          iconName: 'casino',
          previewColorValue: 0xFFFFD700,
          isUnlocked: true,
          isEquipped: true,
          unlockRequirement: 'Default Unlocked'),
      const CosmeticItem(
          id: 'skin_cyber',
          name: 'Cyber Machine',
          description: 'Neon cyan cyberpunk matrix grid.',
          type: CosmeticType.machineSkin,
          iconName: 'memory',
          previewColorValue: 0xFF00E5FF,
          isUnlocked: true,
          unlockRequirement: 'Complete Machine Collection'),
      const CosmeticItem(
          id: 'skin_neon',
          name: 'Neon Machine',
          description: '80s synthwave pink & violet glow.',
          type: CosmeticType.machineSkin,
          iconName: 'lightbulb',
          previewColorValue: 0xFFFF007F,
          isUnlocked: false,
          unlockRequirement: 'Spin 1,000 Times'),
      const CosmeticItem(
          id: 'skin_galaxy',
          name: 'Galaxy Machine',
          description: 'Deep space nebula starlight reels.',
          type: CosmeticType.machineSkin,
          iconName: 'public',
          previewColorValue: 0xFF651FFF,
          isUnlocked: false,
          unlockRequirement: 'Reach Level 20'),
      const CosmeticItem(
          id: 'skin_ancient',
          name: 'Ancient Machine',
          description: 'Pharaoh gold and hieroglyph vault.',
          type: CosmeticType.machineSkin,
          iconName: 'account_balance',
          previewColorValue: 0xFFFFAB00,
          isUnlocked: false,
          unlockRequirement: 'Win 500,000 Total Coins'),
      const CosmeticItem(
          id: 'skin_halloween',
          name: 'Halloween Machine',
          description: 'Spooky pumpkins & green ecto-glow.',
          type: CosmeticType.machineSkin,
          seasonalTheme: SeasonalTheme.halloween,
          iconName: 'local_fire_department',
          previewColorValue: 0xFFFF6D00,
          isUnlocked: true,
          unlockRequirement: 'Halloween Event Special'),
      const CosmeticItem(
          id: 'skin_christmas',
          name: 'Christmas Machine',
          description: 'Frosty snow crystals & holiday lights.',
          type: CosmeticType.machineSkin,
          seasonalTheme: SeasonalTheme.christmas,
          iconName: 'ac_unit',
          previewColorValue: 0xFF00E676,
          isUnlocked: true,
          unlockRequirement: 'Winter Holiday Special'),
      const CosmeticItem(
          id: 'skin_steampunk',
          name: 'Steampunk Machine',
          description: 'Brass gears and steam pressure gauges.',
          type: CosmeticType.machineSkin,
          iconName: 'build_circle',
          previewColorValue: 0xFF8D6E63,
          isUnlocked: false,
          unlockRequirement: 'VIP Level 10'),

      // 👤 Animated Avatars & Coin Trails
      const CosmeticItem(
          id: 'avatar_king',
          name: 'Royal King Avatar',
          description: 'Golden crown avatar frame.',
          type: CosmeticType.avatar,
          iconName: 'face',
          previewColorValue: 0xFFFFD700,
          isUnlocked: true,
          isEquipped: true,
          unlockRequirement: 'Default'),
      const CosmeticItem(
          id: 'avatar_phoenix',
          name: 'Fire Phoenix Avatar',
          description: 'Radiant solar flames.',
          type: CosmeticType.avatar,
          iconName: 'whatshot',
          previewColorValue: 0xFFFF3D00,
          isUnlocked: true,
          unlockRequirement: 'Complete Daily Streak'),
      const CosmeticItem(
          id: 'trail_gold',
          name: 'Golden Spark Trail',
          description: 'Trailing coins shimmer when winning.',
          type: CosmeticType.coinTrail,
          iconName: 'auto_awesome',
          previewColorValue: 0xFFFFD700,
          isUnlocked: true,
          isEquipped: true,
          unlockRequirement: 'Default'),
      const CosmeticItem(
          id: 'trail_rainbow',
          name: 'Rainbow Stardust',
          description: 'Prismatic color burst behind coins.',
          type: CosmeticType.coinTrail,
          iconName: 'color_lens',
          previewColorValue: 0xFF00B0FF,
          isUnlocked: false,
          unlockRequirement: 'Trigger Rainbow Reels'),
    ]);
  }

  // 🔓 Unlock an item by ID
  void unlockItem(String id) {
    final idx = allItems.indexWhere((i) => i.id == id);
    if (idx != -1 && !allItems[idx].isUnlocked) {
      allItems[idx] = allItems[idx].copyWith(isUnlocked: true);
      AppLogger.i('👗 UNLOCKED COSMETIC ITEM: ${allItems[idx].name}!',
          tag: 'CosmeticManager');
    }
  }

  // 🛡️ Equip a cosmetic item
  bool equipItem(String id) {
    final idx = allItems.indexWhere((i) => i.id == id);
    if (idx == -1 || !allItems[idx].isUnlocked) return false;

    final targetItem = allItems[idx];

    // Unequip current item of same type
    for (int i = 0; i < allItems.length; i++) {
      if (allItems[i].type == targetItem.type && allItems[i].isEquipped) {
        allItems[i] = allItems[i].copyWith(isEquipped: false);
      }
    }

    // Equip new item
    allItems[idx] = targetItem.copyWith(isEquipped: true);

    // Update shortcut observables
    switch (targetItem.type) {
      case CosmeticType.title:
        equippedTitleId.value = targetItem.id;
        break;
      case CosmeticType.machineSkin:
        equippedMachineSkinId.value = targetItem.id;
        break;
      case CosmeticType.avatar:
        equippedAvatarId.value = targetItem.id;
        break;
      case CosmeticType.coinTrail:
        equippedCoinTrailId.value = targetItem.id;
        break;
      default:
        break;
    }

    AppLogger.i('✨ EQUIPPED COSMETIC: ${targetItem.name}',
        tag: 'CosmeticManager');
    return true;
  }

  // 🎄 Override Seasonal Atmosphere
  void setSeasonalTheme(SeasonalTheme theme) {
    activeSeasonalTheme.value = theme;
    AppLogger.i('🌍 SEASONAL THEME SWITCHED: ${theme.name.toUpperCase()}',
        tag: 'CosmeticManager');
  }

  CosmeticItem? getEquippedItem(CosmeticType type) {
    return allItems.firstWhereOrNull((i) => i.type == type && i.isEquipped);
  }
}
