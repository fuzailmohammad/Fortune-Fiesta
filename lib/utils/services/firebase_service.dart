import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Firebase service for initialization and configuration
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  late FirebaseAnalytics _analytics;
  late FirebaseCrashlytics _crashlytics;

  FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseAnalytics get analytics => _analytics;

  FirebaseCrashlytics get crashlytics => _crashlytics;

  /// Initialize Firebase with all services
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Configure Crashlytics in debug mode
      if (!kReleaseMode) {
        await _crashlytics.setCrashlyticsCollectionEnabled(true);
      }

      // Pass all uncaught errors from the Flutter framework to Crashlytics
      FlutterError.onError = _crashlytics.recordFlutterError;

      // Set user ID for analytics and crashlytics
      setUserId('anonymous');

      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Set user ID for analytics and crashlytics
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId);
    } catch (e) {
      debugPrint('Error setting user ID: $e');
    }
  }

  /// Log custom event to Firebase Analytics
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('Error logging analytics event: $e');
    }
  }

  /// Log screen view to Firebase Analytics
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );
    } catch (e) {
      debugPrint('Error logging screen view: $e');
    }
  }

  /// Record error in Firebase Crashlytics
  Future<void> recordError(
    dynamic exception,
    StackTrace stackTrace, {
    String? reason,
  }) async {
    try {
      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: false,
      );
    } catch (e) {
      debugPrint('Error recording to Crashlytics: $e');
    }
  }

  /// Set custom key-value data in Crashlytics
  Future<void> setCustomKey(String key, Object value) async {
    try {
      _crashlytics.setCustomKey(key, value);
    } catch (e) {
      debugPrint('Error setting custom key in Crashlytics: $e');
    }
  }

  /// Log message to Crashlytics
  void logMessage(String message) {
    _crashlytics.log(message);
  }
}
