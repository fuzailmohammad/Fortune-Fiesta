import 'package:fortune_fiesta/utils/services/firebase_integration_helper.dart';
import 'package:get/get.dart';

/// Example controller demonstrating Firebase integration
/// This is a template - customize based on your app needs
class FirebaseExampleController extends GetxController {
  final userNotifications = <Map<String, dynamic>>[].obs;
  final notificationCount = 0.obs;

  @override
  void onInit() async {
    super.onInit();

    // Initialize user tracking
    await _initializeUserTracking();

    // Listen to notifications
    _listenToNotifications();
  }

  /// Initialize user tracking
  Future<void> _initializeUserTracking() async {
    try {
      // Set user ID for analytics and crashlytics
      await FirebaseIntegrationHelper.initializeUserAnalytics('user_123');

      // Get and log FCM token
      String? token = await FirebaseIntegrationHelper.getDeviceFCMToken();
      print('Device FCM Token: $token');

      // Subscribe to default topics
      await FirebaseIntegrationHelper.subscribeToPromotions();
      await FirebaseIntegrationHelper.notificationService
          .subscribeToTopic('all_users');

      print('✅ User tracking initialized');
    } catch (e) {
      print('❌ Error initializing user tracking: $e');
    }
  }

  /// Listen to incoming notifications
  void _listenToNotifications() {
    // Watch current notification
    FirebaseIntegrationHelper.watchCurrentNotification().listen((notification) {
      if (notification != null) {
        print('📱 New notification: ${notification.title}');
        userNotifications.add({
          'title': notification.title,
          'body': notification.body,
          'data': notification.data,
          'time': notification.receivedTime,
        });
        notificationCount.value =
            FirebaseIntegrationHelper.getNotificationCount();
      }
    });
  }

  /// Log game spin event
  Future<void> logSpinEvent({
    required int betAmount,
    required String? result,
    required int? winAmount,
  }) async {
    try {
      await FirebaseIntegrationHelper.logSpinEvent(
        betAmount: betAmount,
        result: result,
        winAmount: winAmount,
      );
      print('✅ Spin event logged');
    } catch (e) {
      print('❌ Error logging spin event: $e');
    }
  }

  /// Log level completion
  Future<void> logLevelComplete({
    required int level,
    required int timeSpent,
    required bool success,
  }) async {
    try {
      await FirebaseIntegrationHelper.logLevelComplete(
        level: level,
        timeSpent: timeSpent,
        success: success,
      );
      print('✅ Level complete event logged');
    } catch (e) {
      print('❌ Error logging level complete event: $e');
    }
  }

  /// Log purchase
  Future<void> logPurchase({
    required String productId,
    required double price,
  }) async {
    try {
      await FirebaseIntegrationHelper.logPurchaseEvent(
        productId: productId,
        price: price,
        currency: 'USD',
      );
      print('✅ Purchase event logged');
    } catch (e) {
      print('❌ Error logging purchase event: $e');
    }
  }

  /// Log promo code usage
  Future<void> logPromoCode(String promoCode, double discount) async {
    try {
      await FirebaseIntegrationHelper.logPromoCodeUsed(
        promoCode: promoCode,
        discount: discount,
      );
      print('✅ Promo code event logged');
    } catch (e) {
      print('❌ Error logging promo code event: $e');
    }
  }

  /// Log custom event
  Future<void> logCustomEvent({
    required String eventName,
    required Map<String, Object> data,
  }) async {
    try {
      await FirebaseIntegrationHelper.firebaseService.logEvent(
        name: eventName,
        parameters: data,
      );
      print('✅ Custom event logged: $eventName');
    } catch (e) {
      print('❌ Error logging custom event: $e');
    }
  }

  /// Request notification permission
  Future<void> requestNotificationPermission() async {
    try {
      await FirebaseIntegrationHelper.requestNotificationPermission();
      print('✅ Notification permission requested');
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
    }
  }

  /// Subscribe to specific topic
  Future<void> subscribeTopic(String topic) async {
    try {
      await FirebaseIntegrationHelper.notificationService
          .subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeTopic(String topic) async {
    try {
      await FirebaseIntegrationHelper.notificationService
          .unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Log error for debugging
  Future<void> logError(dynamic error, StackTrace stackTrace) async {
    try {
      await FirebaseIntegrationHelper.logCrash(
        exception: error,
        stackTrace: stackTrace,
        reason: 'App error',
      );
      print('✅ Error logged to Crashlytics');
    } catch (e) {
      print('❌ Error logging to Crashlytics: $e');
    }
  }

  /// Set debug information
  Future<void> setDebugInfo(String key, Object value) async {
    try {
      await FirebaseIntegrationHelper.setDebugInfo(
        key: key,
        value: value,
      );
      print('✅ Debug info set: $key = $value');
    } catch (e) {
      print('❌ Error setting debug info: $e');
    }
  }

  @override
  void onClose() {
    // Clean up
    userNotifications.clear();
    super.onClose();
  }
}

/// Usage example in a widget:
///
/// class MyGamePage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final firebaseCtrl = Get.put(FirebaseExampleController());
///
///     return Scaffold(
///       appBar: AppBar(title: Text('Game')),
///       body: Column(
///         children: [
///           ElevatedButton(
///             onPressed: () {
///               firebaseCtrl.logSpinEvent(
///                 betAmount: 100,
///                 result: 'win',
///                 winAmount: 500,
///               );
///             },
///             child: Text('Log Spin'),
///           ),
///           Obx(() => Text('Notifications: ${firebaseCtrl.notificationCount}')),
///         ],
///       ),
///     );
///   }
/// }
