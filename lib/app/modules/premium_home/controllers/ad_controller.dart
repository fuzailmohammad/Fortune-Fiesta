import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/modules/premium_home/services/storage_service.dart';
import 'package:get/get.dart';

import '../../../data/models/ad_model.dart';
import 'progression_controller.dart';

class AdController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  static const String _analyticsKey = 'player_ad_analytics';
  static const String _lastAdTimeKey = 'player_last_ad_time';
  static const String _dailyCountKey = 'player_daily_ad_count';

  final Rx<AdState> rewardAdState = AdState.uninitialized.obs;
  final Rx<AdAnalytics> analytics = AdAnalytics().obs;
  final RxInt dailyImpressionsCount = 0.obs;
  final Rx<DateTime?> lastAdCompletedTime = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _preloadAdAssets();
  }

  void _loadData() {
    final savedAnalytics = _storage.read<Map<String, dynamic>>(_analyticsKey);
    if (savedAnalytics != null) {
      analytics.value = AdAnalytics.fromJson(savedAnalytics);
    }

    final savedTime = _storage.read<String>(_lastAdTimeKey);
    if (savedTime != null) {
      lastAdCompletedTime.value = DateTime.parse(savedTime);
    }

    final savedCount = _storage.read<int>(_dailyCountKey);
    if (savedCount != null) {
      dailyImpressionsCount.value = savedCount;
    }
  }

  Future<void> _saveData() async {
    await _storage.write(_analyticsKey, analytics.value.toJson());
    await _storage.write(_dailyCountKey, dailyImpressionsCount.value);
    if (lastAdCompletedTime.value != null) {
      await _storage.write(
          _lastAdTimeKey, lastAdCompletedTime.value!.toIso8601String());
    }
  }

  void _preloadAdAssets() {
    rewardAdState.value = AdState.preloading;
    // Simulate preloading delay
    Timer(const Duration(milliseconds: 1200), () {
      rewardAdState.value = AdState.ready;
    });
  }

  // Frequency and VIP checks
  bool canShowAd(AdPlacement placement) {
    try {
      final prog = Get.find<ProgressionController>();

      // VIP players bypass ads automatically (ad is skipped but reward is granted!)
      if (prog.profile.value.avatarFrame == 'vip') {
        return true;
      }
    } catch (_) {}

    // Check daily impression cap (e.g. max 5 ads daily)
    if (dailyImpressionsCount.value >= 5) {
      return false;
    }

    // Check cooldown period (e.g. 20 seconds for UI demo cooldown)
    if (lastAdCompletedTime.value != null) {
      final diff =
          DateTime.now().difference(lastAdCompletedTime.value!).inSeconds;
      if (diff < 20) {
        return false;
      }
    }

    return rewardAdState.value == AdState.ready;
  }

  // Play Rewarded Ad Simulator
  void showRewardedAd({
    required VoidCallback onComplete,
    required VoidCallback onError,
  }) {
    // 1. VIP bypass case
    try {
      final prog = Get.find<ProgressionController>();
      if (prog.profile.value.avatarFrame == 'vip') {
        onComplete();
        return;
      }
    } catch (_) {}

    // Check availability
    if (!canShowAd(AdPlacement.doubleWin)) {
      onError();
      return;
    }

    rewardAdState.value = AdState.playing;

    // 2. Launch full screen simulated player overlay
    Get.dialog(
      const _SimulatedAdOverlay(),
      barrierDismissible: false,
    );

    // 3. Complete playback after 2 seconds
    Timer(const Duration(seconds: 2), () {
      Get.back(); // Dismiss dialog player
      rewardAdState.value = AdState.ready;

      // Update analytics metrics
      dailyImpressionsCount.value++;
      lastAdCompletedTime.value = DateTime.now();

      analytics.value = analytics.value.copyWith(
        impressions: analytics.value.impressions + 1,
        completions: analytics.value.completions + 1,
        simulatedRevenue:
            analytics.value.simulatedRevenue + 0.045, // simulated eCPM
      );

      _saveData();
      onComplete();
    });
  }
}

// Full-screen Simulated Ad Video Player UI overlay
class _SimulatedAdOverlay extends StatefulWidget {
  const _SimulatedAdOverlay();

  @override
  State<_SimulatedAdOverlay> createState() => _SimulatedAdOverlayState();
}

class _SimulatedAdOverlayState extends State<_SimulatedAdOverlay> {
  int _secondsLeft = 2;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          if (_secondsLeft > 0) {
            _secondsLeft--;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.95),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.ondemand_video_rounded,
              color: Color(0xFFFFD700),
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'SPONSORED VIDEO ADVERT',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Simulating Ad Network Playback...',
              style: TextStyle(
                color: Colors.white30,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 32),
            Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFD700),
                    strokeWidth: 3,
                  ),
                ),
                Text(
                  '$_secondsLeft',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
