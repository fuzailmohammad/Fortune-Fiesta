import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/app.dart';
import 'package:fortune_fiesta/app/core/error/error_handler.dart';
import 'package:fortune_fiesta/app/core/logger/app_logger.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize production error interception & custom error widgets
  AppErrorHandler.initialize();
  AppLogger.configure(enable: !kReleaseMode);
  
  await initGetStorage();
  runApp(const App());
}

Future initGetStorage() async {
  await GetStorage.init();
}

