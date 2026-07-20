import 'package:fortune_fiesta/app/data/models/adaptive_experience_model.dart';
import 'package:get/get.dart';

class TimelineController extends GetxService {
  static TimelineController get to => Get.find();

  final milestones = <TimelineMilestone>[].obs;
  final activeCelebration = Rx<TimelineMilestone?>(null);
  final showCelebrationOverlay = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initMilestones();
  }

  void _initMilestones() {
    final now = DateTime.now();
    milestones.assignAll([
      TimelineMilestone(
        id: 'ms_first_spin',
        title: '🌟 FIRST SPIN',
        description: 'Spun the Fortune Fiesta reels for the very first time!',
        timestamp: now.subtract(const Duration(days: 14)),
        category: 'First Spin',
        iconName: 'play_circle_filled',
        isUnlocked: true,
      ),
      TimelineMilestone(
        id: 'ms_first_win',
        title: '🎉 FIRST WIN',
        description: 'Landed your first winning symbol combination!',
        timestamp: now.subtract(const Duration(days: 14, hours: 2)),
        category: 'First Win',
        iconName: 'monetization_on',
        isUnlocked: true,
      ),
      TimelineMilestone(
        id: 'ms_first_big_win',
        title: '🎰 FIRST BIG WIN',
        description:
            'Achieved a massive celebratory Big Win payout multiplier!',
        timestamp: now.subtract(const Duration(days: 10)),
        category: 'First Big Win',
        iconName: 'auto_awesome',
        isUnlocked: true,
      ),
      TimelineMilestone(
        id: 'ms_level_10',
        title: '⚡ LEVEL 10 REACHED',
        description: 'Climbed the ranks to reach VIP Level 10 status!',
        timestamp: now.subtract(const Duration(days: 5)),
        category: 'Level 10',
        iconName: 'emoji_events',
        isUnlocked: true,
      ),
      TimelineMilestone(
        id: 'ms_100_spins',
        title: '🔥 100 SPINS CLUB',
        description:
            'Completed 100 total slot machine spins with unwavering energy!',
        timestamp: now.subtract(const Duration(days: 2)),
        category: '100 Spins',
        iconName: 'local_fire_department',
        isUnlocked: true,
      ),
      TimelineMilestone(
        id: 'ms_1000_spins',
        title: '👑 1,000 SPINS LEGEND',
        description:
            'Completed an incredible 1,000 total spins! A true Fiesta Master!',
        timestamp: now,
        category: '1000 Spins',
        iconName: 'military_tech',
        isUnlocked: false,
      ),
      TimelineMilestone(
        id: 'ms_first_purchase',
        title: '💎 TREASURE PATRON',
        description:
            'Opened the VIP Treasure Vault and made your first purchase!',
        timestamp: now,
        category: 'First Purchase',
        iconName: 'diamond',
        isUnlocked: false,
      ),
      TimelineMilestone(
        id: 'ms_365_streak',
        title: '🌍 365-DAY IMMORTAL',
        description:
            'Unbelievable consistency! Visited Fortune Fiesta for 365 days!',
        timestamp: now,
        category: '365 Day Streak',
        iconName: 'public',
        isUnlocked: false,
      ),
    ]);
  }

  void checkAndUnlockMilestone(String id) {
    final index = milestones.indexWhere((m) => m.id == id);
    if (index != -1 && !milestones[index].isUnlocked) {
      final unlocked = milestones[index]
          .copyWith(isUnlocked: true, timestamp: DateTime.now());
      milestones[index] = unlocked;
      _triggerCelebration(unlocked);
    }
  }

  void simulateMilestoneCelebration(String id) {
    final item = milestones.firstWhereOrNull((m) => m.id == id);
    if (item != null) {
      final updated =
          item.copyWith(isUnlocked: true, timestamp: DateTime.now());
      final idx = milestones.indexOf(item);
      milestones[idx] = updated;
      _triggerCelebration(updated);
    }
  }

  void _triggerCelebration(TimelineMilestone milestone) {
    activeCelebration.value = milestone;
    showCelebrationOverlay.value = true;
  }

  void dismissCelebration() {
    showCelebrationOverlay.value = false;
  }
}
