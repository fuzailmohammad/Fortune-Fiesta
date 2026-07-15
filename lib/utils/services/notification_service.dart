import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Notification payload model
class NotificationPayload {
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final DateTime receivedTime;

  NotificationPayload({
    this.title,
    this.body,
    required this.data,
    required this.receivedTime,
  });

  @override
  String toString() => '''
NotificationPayload(
  title: $title,
  body: $body,
  data: $data,
  receivedTime: $receivedTime,
)''';
}

/// Firebase Cloud Messaging service for handling notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  late FirebaseMessaging _firebaseMessaging;
  final Rx<NotificationPayload?> currentNotification =
      Rx<NotificationPayload?>(null);
  final RxList<NotificationPayload> notificationHistory =
      <NotificationPayload>[].obs;

  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    try {
      _firebaseMessaging = FirebaseMessaging.instance;

      // Request user permission for iOS
      if (Platform.isIOS) {
        await _requestIOSPermission();
      }

      // Get and log FCM token
      String? token = await _firebaseMessaging.getToken();
      debugPrint('📱 FCM Token: $token');

      // Refresh token listener
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 New FCM Token: $newToken');
        // You can store the new token in your backend here
      });

      // Handle message when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle message when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Handle terminated state
      _handleTerminatedMessage();

      debugPrint('✅ Notification service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing notification service: $e');
    }
  }

  /// Request iOS notification permissions
  Future<void> _requestIOSPermission() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('iOS Permission status: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('Error requesting iOS permissions: $e');
    }
  }

  /// Handle foreground notifications
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('🎯 Foreground Message received:');
    _logMessage(message);

    final payload = NotificationPayload(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
      receivedTime: DateTime.now(),
    );

    currentNotification.value = payload;
    notificationHistory.add(payload);

    // You can show a custom notification dialog or snackbar here
    _showNotificationUI(payload);

    debugPrint('✅ Foreground message processed');
  }

  /// Handle background message (when user taps notification while app is in background)
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('🎯 Background Message opened:');
    _logMessage(message);

    final payload = NotificationPayload(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
      receivedTime: DateTime.now(),
    );

    currentNotification.value = payload;
    notificationHistory.add(payload);

    // Handle navigation based on payload data
    _handleNotificationNavigation(payload);

    debugPrint('✅ Background message processed');
  }

  /// Handle message when app is launched from terminated state
  Future<void> _handleTerminatedMessage() async {
    try {
      RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();

      if (initialMessage != null) {
        debugPrint('🎯 Terminated Message received:');
        _logMessage(initialMessage);

        final payload = NotificationPayload(
          title: initialMessage.notification?.title,
          body: initialMessage.notification?.body,
          data: initialMessage.data,
          receivedTime: DateTime.now(),
        );

        currentNotification.value = payload;
        notificationHistory.add(payload);

        // Handle navigation based on payload data
        _handleNotificationNavigation(payload);

        debugPrint('✅ Terminated message processed');
      }
    } catch (e) {
      debugPrint('Error handling terminated message: $e');
    }
  }

  /// Show notification in UI (foreground notification)
  void _showNotificationUI(NotificationPayload payload) {
    // Show custom notification dialog or snackbar
    Get.snackbar(
      payload.title ?? 'Notification',
      payload.body ?? 'You have a new message',
      duration: const Duration(seconds: 4),
      backgroundColor: const Color(0xFF1F1F1F),
      colorText: const Color(0xFFFFD700),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
      onTap: (_) => _handleNotificationNavigation(payload),
    );
  }

  /// Handle notification tap and navigation
  void _handleNotificationNavigation(NotificationPayload payload) {
    debugPrint('🧭 Handling notification navigation');

    // Extract navigation data from payload
    final String? screen = payload.data['screen'] as String?;
    final String? action = payload.data['action'] as String?;

    if (screen != null && Get.key.currentContext != null) {
      // Example navigation - customize based on your app routes
      // Get.toNamed(screen, arguments: payload.data);
      debugPrint('Navigate to screen: $screen with data: ${payload.data}');
    }

    if (action != null) {
      _handleCustomAction(action, payload.data);
    }
  }

  /// Handle custom actions from notifications
  void _handleCustomAction(String action, Map<String, dynamic> data) {
    debugPrint('⚙️ Executing action: $action');

    switch (action) {
      case 'open_promotion':
        debugPrint('Opening promotion: ${data['promo_id']}');
        // Handle promotion
        break;
      case 'show_reward':
        debugPrint('Showing reward: ${data['reward_id']}');
        // Handle reward
        break;
      case 'deep_link':
        debugPrint('Opening deep link: ${data['link']}');
        // Handle deep link
        break;
      default:
        debugPrint('Unknown action: $action');
    }
  }

  /// Log message details
  void _logMessage(RemoteMessage message) {
    debugPrint('Message ID: ${message.messageId}');
    debugPrint('Notification: ${message.notification}');
    debugPrint('Data: ${message.data}');
    debugPrint('Sent Time: ${message.sentTime}');
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Get notification permission status
  Future<AuthorizationStatus> getNotificationPermissionStatus() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus;
    } catch (e) {
      debugPrint('Error getting notification permission status: $e');
      return AuthorizationStatus.notDetermined;
    }
  }

  /// Clear current notification
  void clearCurrentNotification() {
    currentNotification.value = null;
  }

  /// Clear notification history
  void clearNotificationHistory() {
    notificationHistory.clear();
  }

  /// Get notification count
  int getNotificationCount() => notificationHistory.length;
}

// Top-level function to handle background messages (required by FCM)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🌍 Handling background message in isolate');
  debugPrint('Message ID: ${message.messageId}');
  debugPrint('Notification: ${message.notification}');
  debugPrint('Data: ${message.data}');

  // Here you can perform tasks like:
  // - Updating local database
  // - Making API calls
  // - Logging analytics
}
