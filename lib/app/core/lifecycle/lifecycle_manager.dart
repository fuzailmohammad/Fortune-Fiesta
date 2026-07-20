import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/core/analytics/analytics_service.dart';
import 'package:fortune_fiesta/app/core/error/crash_service.dart';
import 'package:fortune_fiesta/app/core/logger/app_logger.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/audio_controller.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/juice_controller.dart';
import 'package:get/get.dart';

class AppLifecycleManager extends GetxService with WidgetsBindingObserver {
  static AppLifecycleManager get to => Get.find();

  DateTime? _lastBackgroundedTime;
  bool _isBackgrounded = false;

  bool get isBackgrounded => _isBackgrounded;

  Future<AppLifecycleManager> init() async {
    WidgetsBinding.instance.addObserver(this);
    AppLogger.i('AppLifecycleManager initialized and observing WidgetsBinding.', tag: 'LifecycleManager');
    return this;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppLogger.d('AppLifecycleState changed: $state', tag: 'LifecycleManager');
    
    if (Get.isRegistered<CrashService>()) {
      CrashService.to.logBreadcrumb('App lifecycle changed to $state', category: 'lifecycle');
    }

    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        if (!_isBackgrounded) {
          _onAppBackgrounded();
        }
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
    }
  }

  void _onAppBackgrounded() {
    _isBackgrounded = true;
    _lastBackgroundedTime = DateTime.now();
    AppLogger.i('App went to background. Pausing ambient loops and audio timers...', tag: 'LifecycleManager');

    // 1. Pause Juice Controller physics loop to save CPU & Battery
    if (Get.isRegistered<JuiceController>()) {
      Get.find<JuiceController>().setAmbientParticlesEnabled(false);
    }

    // 2. Mute / pause music loop if needed to obey OS audio guidelines
    if (Get.isRegistered<AudioController>()) {
      Get.find<AudioController>().stopAllMusic();
    }
  }

  void _onAppResumed() {
    _isBackgrounded = false;
    AppLogger.i('App resumed to foreground.', tag: 'LifecycleManager');

    if (_lastBackgroundedTime != null) {
      final elapsedSeconds = DateTime.now().difference(_lastBackgroundedTime!).inSeconds;
      AppLogger.d('App was in background for $elapsedSeconds seconds.', tag: 'LifecycleManager');
      if (Get.isRegistered<AnalyticsService>()) {
        AnalyticsService.to.logScreenView('app_resumed', screenClass: 'Lifecycle');
      }
    }

    // 1. Resume Juice Controller if battery saver is not active
    if (Get.isRegistered<JuiceController>()) {
      final juice = Get.find<JuiceController>();
      juice.setAmbientParticlesEnabled(!juice.isBatterySaver);
    }

    // 2. Resume music loop if user enabled it
    if (Get.isRegistered<AudioController>()) {
      Get.find<AudioController>().resumeBackgroundMusic();
    }
  }

  void _onAppDetached() {
    AppLogger.w('App is detaching/terminating. Flushing data...', tag: 'LifecycleManager');
  }
}
