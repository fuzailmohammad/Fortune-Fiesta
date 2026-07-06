import 'dart:async';
import 'dart:math' as math;

import 'package:fortune_fiesta/app/modules/premium_home/services/storage_service.dart';
import 'package:get/get.dart';

import '../../../data/models/retention_model.dart';
import '../controllers/premium_home_controller.dart';
import 'progression_controller.dart';

class RetentionController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  static const String _calendarKey = 'player_retention_calendar';
  static const String _streakKey = 'player_retention_streak';
  static const String _hourlyGiftKey = 'player_retention_hourly_gift';
  static const String _mysteryGiftKey = 'player_retention_mystery_gift';

  // State Lists
  final RxList<DailyRewardDay> calendar = <DailyRewardDay>[].obs;
  final Rx<StreakState> streak = StreakState().obs;
  final Rx<GiftState> hourlyGift = GiftState().obs;
  final Rx<GiftState> mysteryGift = GiftState().obs;

  // Active Countdown Ticker Values
  final RxInt hourlyTimerSeconds = 0.obs;
  final RxInt mysteryTimerSeconds = 0.obs;

  // Lucky Wheel States
  final RxDouble wheelRotationAngle = 0.0.obs;
  final RxBool isWheelSpinning = false.obs;

  final List<WheelSegment> wheelSegments = [
    WheelSegment(
        rewardType: 'coins',
        amount: 200,
        displayLabel: '200\nCOINS',
        colorHex: 0xFF8E24AA),
    WheelSegment(
        rewardType: 'xp',
        amount: 50,
        displayLabel: '50\nXP',
        colorHex: 0xFF1E88E5),
    WheelSegment(
        rewardType: 'diamonds',
        amount: 10,
        displayLabel: '10\nDIAMONDS',
        colorHex: 0xFFFFB300),
    WheelSegment(
        rewardType: 'coins',
        amount: 500,
        displayLabel: '500\nCOINS',
        colorHex: 0xFFE53935),
    WheelSegment(
        rewardType: 'xp',
        amount: 100,
        displayLabel: '100\nXP',
        colorHex: 0xFF43A047),
    WheelSegment(
        rewardType: 'diamonds',
        amount: 25,
        displayLabel: '25\nDIAMONDS',
        colorHex: 0xFF3949AB),
    WheelSegment(
        rewardType: 'coins',
        amount: 1000,
        displayLabel: '1000\nCOINS',
        colorHex: 0xFFFFD700), // Jackpot Golden segment
    WheelSegment(
        rewardType: 'diamonds',
        amount: 50,
        displayLabel: '50\nDIAMONDS',
        colorHex: 0xFF00ACC1),
  ];

  Timer? _tickerTimer;

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _startCountdownTicker();
  }

  @override
  void onClose() {
    _tickerTimer?.cancel();
    super.onClose();
  }

  void _loadData() {
    // 1. Calendar Check-In Setup
    final savedCalendar = _storage.read<List<dynamic>>(_calendarKey);
    if (savedCalendar != null) {
      calendar.value =
          savedCalendar.map((e) => DailyRewardDay.fromJson(e)).toList();
    } else {
      _loadDefaultCalendar();
    }

    // 2. Streak Setup
    final savedStreak = _storage.read<Map<String, dynamic>>(_streakKey);
    if (savedStreak != null) {
      streak.value = StreakState.fromJson(savedStreak);
    } else {
      streak.value = StreakState(currentStreak: 0, longestStreak: 0);
      _saveData();
    }

    // 3. Hourly Free Gift Setup
    final savedHourly = _storage.read<Map<String, dynamic>>(_hourlyGiftKey);
    if (savedHourly != null) {
      hourlyGift.value = GiftState.fromJson(savedHourly);
      _calculateHourlyRemaining();
    } else {
      hourlyGift.value = GiftState(cooldownSeconds: 0);
      hourlyTimerSeconds.value = 0;
    }

    // 4. Mystery Gift Setup
    final savedMystery = _storage.read<Map<String, dynamic>>(_mysteryGiftKey);
    if (savedMystery != null) {
      mysteryGift.value = GiftState.fromJson(savedMystery);
      _calculateMysteryRemaining();
    } else {
      mysteryGift.value = GiftState(cooldownSeconds: 0);
      mysteryTimerSeconds.value = 0;
    }
  }

  void _loadDefaultCalendar() {
    calendar.value = [
      DailyRewardDay(
          day: 1,
          rewardType: 'coins',
          amount: 250,
          isClaimed: false,
          isLocked: false),
      DailyRewardDay(
          day: 2,
          rewardType: 'coins',
          amount: 500,
          isClaimed: false,
          isLocked: true),
      DailyRewardDay(
          day: 3,
          rewardType: 'diamonds',
          amount: 15,
          isClaimed: false,
          isLocked: true),
      DailyRewardDay(
          day: 4,
          rewardType: 'coins',
          amount: 1000,
          isClaimed: false,
          isLocked: true),
      DailyRewardDay(
          day: 5,
          rewardType: 'xp',
          amount: 100,
          isClaimed: false,
          isLocked: true),
      DailyRewardDay(
          day: 6,
          rewardType: 'coins',
          amount: 2000,
          isClaimed: false,
          isLocked: true),
      DailyRewardDay(
          day: 7,
          rewardType: 'diamonds',
          amount: 100,
          isClaimed: false,
          isLocked: true),
    ];
    _saveData();
  }

  Future<void> _saveData() async {
    await _storage.write(
        _calendarKey, calendar.map((e) => e.toJson()).toList());
    await _storage.write(_streakKey, streak.value.toJson());
    await _storage.write(_hourlyGiftKey, hourlyGift.value.toJson());
    await _storage.write(_mysteryGiftKey, mysteryGift.value.toJson());
  }

  // Ticks remaining seconds reactively in a 1-second interval loop
  void _startCountdownTicker() {
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (hourlyTimerSeconds.value > 0) {
        hourlyTimerSeconds.value--;
      }
      if (mysteryTimerSeconds.value > 0) {
        mysteryTimerSeconds.value--;
      }
    });
  }

  void _calculateHourlyRemaining() {
    if (hourlyGift.value.lastOpenedTime == null) {
      hourlyTimerSeconds.value = 0;
      return;
    }
    final lastTime = DateTime.parse(hourlyGift.value.lastOpenedTime!);
    final diff = DateTime.now().difference(lastTime).inSeconds;
    final int remaining = math.max(0, 3600 - diff); // 1 hour cooldown
    hourlyTimerSeconds.value = remaining;
  }

  void _calculateMysteryRemaining() {
    if (mysteryGift.value.lastOpenedTime == null) {
      mysteryTimerSeconds.value = 0;
      return;
    }
    final lastTime = DateTime.parse(mysteryGift.value.lastOpenedTime!);
    final diff = DateTime.now().difference(lastTime).inSeconds;
    final int remaining = math.max(0, 14400 - diff); // 4 hours cooldown
    mysteryTimerSeconds.value = remaining;
  }

  // Claim Daily Login Check-In
  void claimCalendarDay(int dayNum) {
    final int idx = calendar.indexWhere((d) => d.day == dayNum);
    if (idx != -1 && !calendar[idx].isClaimed && !calendar[idx].isLocked) {
      // 1. Mark claimed
      calendar[idx] = calendar[idx].copyWith(isClaimed: true);

      // 2. Increment streak metrics
      final int newStreak = streak.value.currentStreak + 1;
      final int longest = math.max(newStreak, streak.value.longestStreak);
      streak.value = streak.value.copyWith(
        currentStreak: newStreak,
        longestStreak: longest,
        lastClaimDate: DateTime.now().toIso8601String(),
      );

      // 3. Unlock next day in calendar
      if (idx + 1 < calendar.length) {
        calendar[idx + 1] = calendar[idx + 1].copyWith(isLocked: false);
      }

      // 4. Award rewards
      _awardReward(calendar[idx].rewardType, calendar[idx].amount);
      _saveData();
    }
  }

  // Claim Hourly Free Coins
  void claimHourlyGift() {
    if (hourlyTimerSeconds.value == 0) {
      _awardReward('coins', 150);
      hourlyGift.value = hourlyGift.value.copyWith(
        lastOpenedTime: DateTime.now().toIso8601String(),
        cooldownSeconds: 3600,
      );
      hourlyTimerSeconds.value = 3600;
      _saveData();
    }
  }

  // Claim Mystery Chest Box
  void claimMysteryGift() {
    if (mysteryTimerSeconds.value == 0) {
      // Randomly award coins, diamonds or XP
      final rand = math.Random();
      final double r = rand.nextDouble();
      if (r < 0.45) {
        _awardReward('coins', 400);
      } else if (r < 0.8) {
        _awardReward('xp', 150);
      } else {
        _awardReward('diamonds', 20);
      }

      mysteryGift.value = mysteryGift.value.copyWith(
        lastOpenedTime: DateTime.now().toIso8601String(),
        cooldownSeconds: 14400,
      );
      mysteryTimerSeconds.value = 14400;
      _saveData();
    }
  }

  // Spin Lucky Wheel Segment
  Future<void> spinLuckyWheel() async {
    if (isWheelSpinning.value) return;
    isWheelSpinning.value = true;

    final rand = math.Random();
    final int targetSegment = rand.nextInt(8); // Select segment (0-7)

    // Physics Angle: 3 full spins + target segment offset
    final double segmentArc = (math.pi * 2) / 8;
    final double targetAngle = (math.pi * 2 * 4) + (targetSegment * segmentArc);

    wheelRotationAngle.value = 0.0;

    // Animate rotation angle via controller loop
    const int steps = 90;
    for (int i = 0; i <= steps; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      // Sinusoidal easing curve out for mechanical friction feel
      final double progress = math.sin((i / steps) * (math.pi / 2));
      wheelRotationAngle.value = targetAngle * progress;
    }

    // Award segment reward
    final selectedSegment = wheelSegments[targetSegment];
    _awardReward(selectedSegment.rewardType, selectedSegment.amount);

    isWheelSpinning.value = false;
  }

  void _awardReward(String type, int amount) {
    try {
      if (type == 'xp') {
        final progController = Get.find<ProgressionController>();
        progController.cheatAddXp(amount);
      } else if (type == 'coins') {
        final homeController = Get.find<PremiumHomeController>();
        homeController.coins.value += amount;
      } else if (type == 'diamonds') {
        final progController = Get.find<ProgressionController>();
        progController.profile.value = progController.profile.value.copyWith(
          diamonds: progController.profile.value.diamonds + amount,
        );
      }
    } catch (_) {}
  }
}
