import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum LogLevel { verbose, debug, info, warning, error, wtf }

class AppLogger {
  AppLogger._privateConstructor();

  static const String _defaultTag = 'FortuneFiesta';
  static bool _enableLogging = !kReleaseMode;
  static LogLevel _minLevel = kReleaseMode ? LogLevel.error : LogLevel.verbose;

  static void configure({bool? enable, LogLevel? minLevel}) {
    if (enable != null) _enableLogging = enable;
    if (minLevel != null) _minLevel = minLevel;
  }

  static void v(String message,
      {String tag = _defaultTag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.verbose, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  static void d(String message,
      {String tag = _defaultTag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  static void i(String message,
      {String tag = _defaultTag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  static void w(String message,
      {String tag = _defaultTag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  static void e(String message,
      {String tag = _defaultTag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  static void wtf(String message,
      {String tag = _defaultTag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.wtf, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    required String tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enableLogging && level.index < _minLevel.index) {
      return;
    }

    if (level.index < _minLevel.index) {
      return;
    }

    final sanitizedMessage = _sanitizeMessage(message);
    final timestamp = DateTime.now().toIso8601String();
    final prefix = _getPrefix(level);

    final formatted = '[$timestamp] $prefix [$tag] $sanitizedMessage';

    if (!kReleaseMode) {
      developer.log(
        formatted,
        time: DateTime.now(),
        level: _getDeveloperLevel(level),
        name: tag,
        error: error,
        stackTrace: stackTrace,
      );
    } else if (level == LogLevel.error || level == LogLevel.wtf) {
      // In production, route critical errors to Crashlytics / Sentry telemetry
      _forwardToCrashReporting(sanitizedMessage, error, stackTrace);
    }
  }

  static String _sanitizeMessage(String message) {
    // Mask sensitive keys if accidentally dumped into log messages
    final sensitiveKeys = [
      'token',
      'password',
      'secret',
      'auth',
      'credit_card',
      'jwt'
    ];
    String sanitized = message;
    for (final key in sensitiveKeys) {
      final regex =
          RegExp('("$key"|"$key"\\s*:\\s*)"([^"]+)"', caseSensitive: false);
      sanitized = sanitized.replaceAllMapped(
          regex, (match) => '${match.group(1)}"********"');
    }
    return sanitized;
  }

  static String _getPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return '🟢 [VERB]';
      case LogLevel.debug:
        return '🔵 [DEBUG]';
      case LogLevel.info:
        return 'ℹ️ [INFO]';
      case LogLevel.warning:
        return '⚠️ [WARN]';
      case LogLevel.error:
        return '🛑 [ERROR]';
      case LogLevel.wtf:
        return '🔥 [WTF]';
    }
  }

  static int _getDeveloperLevel(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return 500;
      case LogLevel.debug:
        return 700;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.wtf:
        return 1200;
    }
  }

  static void _forwardToCrashReporting(
      String message, Object? error, StackTrace? stackTrace) {
    // Hook for Sentry / Firebase Crashlytics non-fatal reporting in release mode
    // Example: CrashService.recordError(error ?? message, stackTrace, reason: message);
  }
}
