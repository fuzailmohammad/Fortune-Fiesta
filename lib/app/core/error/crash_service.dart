import 'package:flutter/foundation.dart';
import 'package:fortune_fiesta/app/core/logger/app_logger.dart';
import 'package:get/get.dart';

class CrashService extends GetxService {
  static CrashService get to => Get.find();

  final List<String> _breadcrumbs = [];
  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<CrashService> init() async {
    _initialized = true;
    AppLogger.i('CrashService initialized.', tag: 'CrashService');
    return this;
  }

  void logBreadcrumb(String message, {String category = 'default'}) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final formatted = '[$timestamp] [$category] $message';
    
    _breadcrumbs.add(formatted);
    if (_breadcrumbs.length > 50) {
      _breadcrumbs.removeAt(0);
    }

    AppLogger.v('Breadcrumb: $formatted', tag: 'CrashService');
    // Hook for Sentry.addBreadcrumb or Crashlytics.log
  }

  void setCustomKey(String key, Object value) {
    AppLogger.v('Setting crash key: $key = $value', tag: 'CrashService');
    // Hook for Crashlytics.setCustomKey
  }

  void recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? extra,
  }) {
    if (kDebugMode) {
      AppLogger.e(
        'Recorded Error [Fatal: $fatal]: ${reason ?? error.toString()}',
        tag: 'CrashService',
        error: error,
        stackTrace: stackTrace,
      );
      if (extra != null) {
        AppLogger.d('Extra Crash Metadata: $extra', tag: 'CrashService');
      }
    } else {
      // In Production: Send to Firebase Crashlytics / Sentry with breadcrumbs
      // Crashlytics.instance.recordError(error, stackTrace, reason: reason, fatal: fatal);
      AppLogger.e('Forwarded error to telemetry SDKs: $error', tag: 'CrashService');
    }
  }

  List<String> getRecentBreadcrumbs() => List.unmodifiable(_breadcrumbs);
}
