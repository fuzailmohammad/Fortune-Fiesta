import 'package:fortune_fiesta/utils/services/firebase_service.dart';
import 'package:fortune_fiesta/utils/services/notification_service.dart';
import 'package:get/get.dart';

/// Example integration helper for Firebase services
class FirebaseIntegrationHelper {
  /// Get Firebase services instances
  static FirebaseService get firebaseService => FirebaseService();
  static NotificationService get notificationService => NotificationService();

  /// Initialize user analytics
  static Future<void> initializeUserAnalytics(String userId) async {
    await firebaseService.setUserId(userId);
    await notificationService.subscribeToTopic('all_users');
  }

  /// Log game event
  static Future<void> logGameEvent({
    required String eventName,
    required int amount,
    String currency = 'USD',
    Map<String, dynamic>? additionalData,
  }) async {
    final parameters = {
      'amount': amount as Object,
      'currency': currency as Object,
    };
    if (additionalData != null) {
      additionalData.forEach((key, value) {
        if (value != null) {
          parameters[key] = value as Object;
        }
      });
    }
    await firebaseService.logEvent(
      name: eventName,
      parameters: parameters as Map<String, Object>?,
    );
  }

  /// Log spin event
  static Future<void> logSpinEvent({
    required int betAmount,
    required String? result,
    required int? winAmount,
  }) async {
    await logGameEvent(
      eventName: 'spin_wheel',
      amount: betAmount,
      additionalData: {
        'result': result ?? 'none',
        'win_amount': winAmount ?? 0,
      },
    );
  }

  /// Log level completion
  static Future<void> logLevelComplete({
    required int level,
    required int timeSpent,
    required bool success,
  }) async {
    await logGameEvent(
      eventName: 'level_complete',
      amount: level,
      additionalData: {
        'time_spent': timeSpent,
        'success': success,
      },
    );

    if (success) {
      await notificationService.subscribeToTopic('level_${level + 1}');
    }
  }

  /// Log purchase event
  static Future<void> logPurchaseEvent({
    required String productId,
    required double price,
    required String currency,
    String? transactionId,
  }) async {
    await firebaseService.logEvent(
      name: 'purchase',
      parameters: {
        'currency': currency,
        'value': price,
        'product_id': productId,
        'transaction_id': transactionId ?? 'unknown',
      },
    );
  }

  /// Log promotion/promo code usage
  static Future<void> logPromoCodeUsed({
    required String promoCode,
    required double discount,
  }) async {
    await logGameEvent(
      eventName: 'promo_code_used',
      amount: discount.toInt(),
      additionalData: {
        'promo_code': promoCode,
      },
    );
  }

  /// Log app crash (for custom crashes)
  static Future<void> logCrash({
    required dynamic exception,
    required StackTrace stackTrace,
    String? reason,
  }) async {
    await firebaseService.recordError(exception, stackTrace, reason: reason);
  }

  /// Log custom key for debugging
  static Future<void> setDebugInfo({
    required String key,
    required Object value,
  }) async {
    await firebaseService.setCustomKey(key, value);
  }

  /// Subscribe to promotional notifications
  static Future<void> subscribeToPromotions() async {
    await notificationService.subscribeToTopic('promotions');
  }

  /// Unsubscribe from promotional notifications
  static Future<void> unsubscribeFromPromotions() async {
    await notificationService.unsubscribeFromTopic('promotions');
  }

  /// Get device FCM token
  static Future<String?> getDeviceFCMToken() async {
    return await notificationService.getFCMToken();
  }

  /// Request notification permission (iOS)
  static Future<void> requestNotificationPermission() async {
    final status = await notificationService.getNotificationPermissionStatus();
    // status values: granted, denied, notDetermined, provisional
    if (status.name == 'denied') {
      Get.snackbar(
        'Notification Permission',
        'Please enable notifications to receive important updates',
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// Get notification count
  static int getNotificationCount() {
    return notificationService.getNotificationCount();
  }

  /// Watch current notification
  static dynamic watchCurrentNotification() {
    return notificationService.currentNotification;
  }

  /// Watch notification history
  static dynamic watchNotificationHistory() {
    return notificationService.notificationHistory;
  }
}
