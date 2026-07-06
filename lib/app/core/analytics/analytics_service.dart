import 'package:flutter/foundation.dart';
import 'package:fortune_fiesta/app/core/logger/app_logger.dart';
import 'package:get/get.dart';

class AnalyticsService extends GetxService {
  static AnalyticsService get to => Get.find();

  final List<Map<String, dynamic>> _eventQueue = [];
  bool _initialized = false;
  String? _userId;

  Future<AnalyticsService> init() async {
    _initialized = true;
    AppLogger.i('AnalyticsService initialized.', tag: 'AnalyticsService');
    _flushQueue();
    return this;
  }

  void setUserId(String userId) {
    _userId = userId;
    AppLogger.d('User ID set: $userId', tag: 'AnalyticsService');
    // Hook for Firebase/Mixpanel/Amplitude setUserId
  }

  void setUserProperty(String name, String value) {
    AppLogger.v('User property set: $name = $value', tag: 'AnalyticsService');
    // Hook for analytics user property binding
  }

  void logScreenView(String screenName, {String? screenClass}) {
    _logEvent('screen_view', {
      'screen_name': screenName,
      'screen_class': screenClass ?? screenName,
    });
  }

  void logAppOpen() {
    _logEvent('app_open', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void logSpin({required int betAmount, required int winAmount, required String mode, required bool isJackpot}) {
    _logEvent('spin_completed', {
      'bet_amount': betAmount,
      'win_amount': winAmount,
      'net_result': winAmount - betAmount,
      'spin_mode': mode,
      'is_jackpot': isJackpot,
    });
  }

  void logRewardClaimed({required String rewardType, required String source, required int amount}) {
    _logEvent('reward_claimed', {
      'reward_type': rewardType,
      'source': source,
      'amount': amount,
    });
  }

  void logMissionCompleted({required String missionId, required String category, required int rewardValue}) {
    _logEvent('mission_completed', {
      'mission_id': missionId,
      'category': category,
      'reward_value': rewardValue,
    });
  }

  void logLevelUp({required int newLevel, required int xpTotal}) {
    _logEvent('level_up', {
      'new_level': newLevel,
      'xp_total': xpTotal,
    });
  }

  void logAdWatched({required String adType, required String placement, required bool rewardEarned}) {
    _logEvent('ad_watched', {
      'ad_type': adType,
      'placement': placement,
      'reward_earned': rewardEarned,
    });
  }

  void logPurchase({
    required String productId,
    required double price,
    required String currency,
    required String shopSection,
  }) {
    _logEvent('in_app_purchase', {
      'product_id': productId,
      'price': price,
      'currency': currency,
      'shop_section': shopSection,
    });
  }

  void logLiveEventParticipated({required String eventId, required String eventName}) {
    _logEvent('live_event_join', {
      'event_id': eventId,
      'event_name': eventName,
    });
  }

  void _logEvent(String eventName, Map<String, dynamic> parameters) {
    final enrichedParams = {
      ...parameters,
      'user_id': _userId ?? 'anonymous',
      'session_time': DateTime.now().millisecondsSinceEpoch,
    };

    if (!_initialized) {
      _eventQueue.add({'name': eventName, 'params': enrichedParams});
      return;
    }

    if (kDebugMode) {
      AppLogger.d('📊 Event: $eventName | Params: $enrichedParams', tag: 'AnalyticsService');
    } else {
      // In Production: Forward to Firebase Analytics / SDK telemetry bridge
      // FirebaseAnalytics.instance.logEvent(name: eventName, parameters: enrichedParams);
    }
  }

  void _flushQueue() {
    if (_eventQueue.isEmpty) return;
    AppLogger.d('Flushing ${_eventQueue.length} queued analytics events...', tag: 'AnalyticsService');
    for (final event in _eventQueue) {
      _logEvent(event['name'] as String, event['params'] as Map<String, dynamic>);
    }
    _eventQueue.clear();
  }
}
