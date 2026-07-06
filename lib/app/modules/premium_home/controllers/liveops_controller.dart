import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/modules/premium_home/services/storage_service.dart';
import 'package:get/get.dart';

import '../../../data/models/liveops_model.dart';
import '../controllers/premium_home_controller.dart';
import 'progression_controller.dart';

class LiveOpsController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  static const String _eventsKey = 'liveops_active_events';
  static const String _seasonKey = 'liveops_current_season';
  static const String _announcementsKey = 'liveops_announcements';

  final RxList<LiveEventModel> activeEvents = <LiveEventModel>[].obs;
  final Rx<SeasonModel?> currentSeason = Rx<SeasonModel?>(null);
  final RxList<AnnouncementModel> announcements = <AnnouncementModel>[].obs;

  final RxInt eventCountdownSeconds = 0.obs;
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _startEventTimer();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  void _loadData() {
    // 1. Events Calendar Loader
    final savedEvents = _storage.read<List<dynamic>>(_eventsKey);
    if (savedEvents != null) {
      activeEvents.value =
          savedEvents.map((e) => LiveEventModel.fromJson(e)).toList();
    } else {
      _loadDefaultEvents();
    }

    // 2. Season Pass Loader
    final savedSeason = _storage.read<Map<String, dynamic>>(_seasonKey);
    if (savedSeason != null) {
      currentSeason.value = SeasonModel.fromJson(savedSeason);
    } else {
      _loadDefaultSeason();
    }

    // 3. News Bulletins Loader
    final savedAnnouncements = _storage.read<List<dynamic>>(_announcementsKey);
    if (savedAnnouncements != null) {
      announcements.value =
          savedAnnouncements.map((e) => AnnouncementModel.fromJson(e)).toList();
    } else {
      _loadDefaultAnnouncements();
    }

    _calculateCountdown();
  }

  void _loadDefaultEvents() {
    // Default active Campaign is Halloween
    activeEvents.value = [
      LiveEventModel(
        id: 'event_halloween_2026',
        title: 'HALLOWEEN CARNIVAL',
        description:
            'Complete Halloween missions to unlock exclusive Jack-O-Lantern frames and coins!',
        theme: 'halloween',
        startTime: DateTime.now().toIso8601String(),
        endTime: DateTime.now().add(const Duration(days: 4)).toIso8601String(),
        rewardType: 'coins',
        rewardValue: 2500,
        currencyName: 'Pumpkins',
      ),
    ];
    _saveData();
  }

  void _loadDefaultSeason() {
    currentSeason.value = SeasonModel(
      id: 'season_1',
      name: 'SEASON 1: GOLDEN ERA',
      currentLevel: 1,
      currentXp: 120,
      maxLevel: 10,
      rewardsTrack: [
        {
          'level': 1,
          'rewardType': 'coins',
          'amount': 1000,
          'isPremium': false,
          'claimed': false
        },
        {
          'level': 1,
          'rewardType': 'diamonds',
          'amount': 50,
          'isPremium': true,
          'claimed': false
        },
        {
          'level': 2,
          'rewardType': 'coins',
          'amount': 2000,
          'isPremium': false,
          'claimed': false
        },
        {
          'level': 2,
          'rewardType': 'xp',
          'amount': 300,
          'isPremium': true,
          'claimed': false
        },
        {
          'level': 3,
          'rewardType': 'diamonds',
          'amount': 100,
          'isPremium': false,
          'claimed': false
        },
        {
          'level': 3,
          'rewardType': 'coins',
          'amount': 5000,
          'isPremium': true,
          'claimed': false
        },
      ],
    );
    _saveData();
  }

  void _loadDefaultAnnouncements() {
    announcements.value = [
      AnnouncementModel(
        id: 'ann_welcome',
        title: 'WELCOME TO FORTUNE FIESTA!',
        content:
            'Enjoy the premium slot experience. Spin reels, complete missions, and claim massive daily bonuses!',
        category: 'news',
      ),
      AnnouncementModel(
        id: 'ann_version_1_3',
        title: 'VERSION 1.3 UPDATE NOTES',
        content:
            'Added full progression systems, high-quality particles, a new Vault shop, and LiveOps check-in calendars!',
        category: 'patch_notes',
      ),
    ];
    _saveData();
  }

  Future<void> _saveData() async {
    await _storage.write(
        _eventsKey, activeEvents.map((e) => e.toJson()).toList());
    if (currentSeason.value != null) {
      await _storage.write(_seasonKey, currentSeason.value!.toJson());
    }
    await _storage.write(
        _announcementsKey, announcements.map((e) => e.toJson()).toList());
  }

  void _startEventTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (eventCountdownSeconds.value > 0) {
        eventCountdownSeconds.value--;
      }
    });
  }

  void _calculateCountdown() {
    if (activeEvents.isEmpty) {
      eventCountdownSeconds.value = 0;
      return;
    }
    final event = activeEvents.first;
    final endTime = DateTime.parse(event.endTime);
    final diff = endTime.difference(DateTime.now()).inSeconds;
    eventCountdownSeconds.value = diff > 0 ? diff : 0;
  }

  // Dismiss a news announcement bulletin card
  void dismissAnnouncement(String id) {
    final idx = announcements.indexWhere((a) => a.id == id);
    if (idx != -1) {
      announcements[idx] = announcements[idx].copyWith(isRead: true);
      _saveData();
    }
  }

  // Dynamic Theme Color override based on current LiveOps Event
  Color getThemeAccentColor() {
    if (activeEvents.isEmpty) return const Color(0xFFFFD700); // Premium Gold

    final theme = activeEvents.first.theme;
    if (theme == 'halloween') {
      return Colors.deepOrangeAccent;
    } else if (theme == 'christmas') {
      return Colors.redAccent;
    } else if (theme == 'diwali') {
      return Colors.amber;
    }

    return const Color(0xFFFFD700);
  }

  // Claim Season Pass reward milestone lock
  void claimSeasonPassMilestone(int level, bool isPremium) {
    if (currentSeason.value == null) return;

    final season = currentSeason.value!;
    final List<dynamic> track = List.from(season.rewardsTrack);

    final idx = track
        .indexWhere((r) => r['level'] == level && r['isPremium'] == isPremium);
    if (idx != -1 && !track[idx]['claimed']) {
      // Mark as claimed
      track[idx]['claimed'] = true;
      currentSeason.value = SeasonModel(
        id: season.id,
        name: season.name,
        currentLevel: season.currentLevel,
        currentXp: season.currentXp,
        maxLevel: season.maxLevel,
        rewardsTrack: track,
      );

      // Deliver reward payload
      final String type = track[idx]['rewardType'];
      final int amount = track[idx]['amount'];
      _deliverReward(type, amount);

      _saveData();
    }
  }

  void _deliverReward(String type, int amount) {
    try {
      if (type == 'coins') {
        final home = Get.find<PremiumHomeController>();
        home.coins.value += amount;
      } else if (type == 'diamonds') {
        final prog = Get.find<ProgressionController>();
        prog.profile.value = prog.profile.value.copyWith(
          diamonds: prog.profile.value.diamonds + amount,
        );
      } else if (type == 'xp') {
        final prog = Get.find<ProgressionController>();
        prog.cheatAddXp(amount);
      }
    } catch (_) {}
  }
}
