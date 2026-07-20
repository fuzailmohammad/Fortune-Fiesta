import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/core/error/crash_service.dart';
import 'package:fortune_fiesta/app/core/logger/app_logger.dart';
import 'package:get/get.dart';

class AppErrorHandler {
  AppErrorHandler._privateConstructor();

  static void initialize() {
    // 1. Intercept synchronous Flutter framework errors (e.g. build/layout exceptions)
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        FlutterError.presentError(details);
      }

      AppLogger.e(
        'Flutter Framework Exception caught: ${details.exceptionAsString()}',
        tag: 'AppErrorHandler',
        error: details.exception,
        stackTrace: details.stack,
      );

      if (Get.isRegistered<CrashService>()) {
        CrashService.to.recordError(
          details.exception,
          details.stack,
          reason: 'FlutterError: ${details.context ?? "Unknown context"}',
          fatal: false,
        );
      }
    };

    // 2. Intercept asynchronous platform dispatcher errors (e.g. unhandled futures)
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      AppLogger.e(
        'Async Platform Exception caught: $error',
        tag: 'AppErrorHandler',
        error: error,
        stackTrace: stack,
      );

      if (Get.isRegistered<CrashService>()) {
        CrashService.to.recordError(
          error,
          stack,
          reason: 'PlatformDispatcher unhandled exception',
          fatal: true,
        );
      }
      return true; // Prevent app crash propagation
    };

    // 3. Customize ErrorWidget.builder to show a premium fallback card in UI
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return _PremiumErrorFallbackWidget(details: details);
    };

    AppLogger.i('AppErrorHandler hooks initialized successfully.',
        tag: 'AppErrorHandler');
  }
}

class _PremiumErrorFallbackWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const _PremiumErrorFallbackWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      // In debug mode, show a scrollable red error for rapid developer debugging
      return Material(
        color: const Color(0xFF2A0808),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bug_report, color: Colors.redAccent, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'DEBUG ERROR CAUGHT',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  details.exceptionAsString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 13),
                ),
                const SizedBox(height: 12),
                if (details.stack != null)
                  Text(
                    details.stack.toString(),
                    style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'monospace',
                        fontSize: 11),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // In production, render a polished, game-aligned fallback card
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFFE5A93C).withValues(alpha: 0.4),
                width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome_motion,
                color: Color(0xFFE5A93C),
                size: 40,
              ),
              const SizedBox(height: 12),
              const Text(
                'Graphical Glitch Recovered',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We smoothed out a temporary visual hiccup so you can keep spinning!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (Get.key.currentContext != null) {
                    Get.forceAppUpdate();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5A93C),
                  foregroundColor: const Color(0xFF1A1A2E),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: const Text(
                  'REFRESH UI',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
