import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/app.dart';
import 'package:fortune_fiesta/app/core/error/error_handler.dart';
import 'package:fortune_fiesta/app/core/logger/app_logger.dart';
import 'package:fortune_fiesta/utils/services/firebase_service.dart';
import 'package:fortune_fiesta/utils/services/notification_service.dart';
import 'package:get_storage/get_storage.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseService().initialize();
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseService().initialize();

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize notification service
  await NotificationService().initialize();

  // Initialize production error interception & custom error widgets
  AppErrorHandler.initialize();
  AppLogger.configure(enable: !kReleaseMode);

  await initGetStorage();
  runApp(const App());
}

Future initGetStorage() async {
  await GetStorage.init();
}
