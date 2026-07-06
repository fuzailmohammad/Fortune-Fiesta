import 'package:fortune_fiesta/app/data/models/adaptive_experience_model.dart';
import 'package:get/get.dart';

class RecommendationController extends GetxService {
  static RecommendationController get to => Get.find();

  final activeRecommendations = <SmartRecommendation>[].obs;
  final primaryRecommendation = Rx<SmartRecommendation?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadDefaultRecommendations();
  }

  void _loadDefaultRecommendations() {
    final list = [
      const SmartRecommendation(
        id: 'rec_mission',
        title: '🎯 MISSION RECOMMENDATION',
        subtitle:
            'Complete 50 spins today to claim your +10,000 Coin Quest chest!',
        actionLabel: 'VIEW QUEST',
        iconName: 'track_changes',
        priority: 1,
        targetRoute: '/retention',
      ),
      const SmartRecommendation(
        id: 'rec_wheel',
        title: '🎡 LUCKY WHEEL REMINDER',
        subtitle:
            'Your Free Daily Wheel Spin is ready! Spin now for instant jackpot prizes!',
        actionLabel: 'SPIN WHEEL',
        iconName: 'casino',
        priority: 2,
        targetRoute: '/retention',
      ),
      const SmartRecommendation(
        id: 'rec_shop',
        title: '💎 TREASURE VAULT DEAL',
        subtitle:
            'Explore our curated Starter Packs and VIP exclusive value bundles!',
        actionLabel: 'OPEN VAULT',
        iconName: 'diamond',
        priority: 3,
        targetRoute: '/shop',
      ),
      const SmartRecommendation(
        id: 'rec_profile',
        title: '👑 PROFILE COMPLETION',
        subtitle:
            'Equip your newest VIP Title and Avatar Frame to show off on leaderboards!',
        actionLabel: 'CUSTOMIZE',
        iconName: 'person_pin',
        priority: 4,
        targetRoute: '/growth_hub',
      ),
    ];

    activeRecommendations.assignAll(list);
    primaryRecommendation.value = list.first;
  }

  void updateContextualState(
      {required int coinBalance, required bool hasFreeWheel}) {
    // If balance is low, elevate Shop recommendation without forcing
    if (coinBalance < 5000) {
      final shopRec =
          activeRecommendations.firstWhereOrNull((r) => r.id == 'rec_shop');
      if (shopRec != null) {
        primaryRecommendation.value = shopRec;
      }
    } else if (hasFreeWheel) {
      final wheelRec =
          activeRecommendations.firstWhereOrNull((r) => r.id == 'rec_wheel');
      if (wheelRec != null) {
        primaryRecommendation.value = wheelRec;
      }
    }
  }

  void cycleNextRecommendation() {
    if (activeRecommendations.isEmpty) return;
    final currentIndex =
        activeRecommendations.indexOf(primaryRecommendation.value);
    final nextIndex = (currentIndex + 1) % activeRecommendations.length;
    primaryRecommendation.value = activeRecommendations[nextIndex];
  }
}
