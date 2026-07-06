import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/animations/vfx_engine.dart';
import '../../../data/models/settings_model.dart';
import '../services/storage_service.dart';
import 'premium_home_controller.dart';
import 'progression_controller.dart';

class SettingsController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  static const String _settingsKey = 'player_preferences_settings';

  final Rx<SettingsModel> settings = SettingsModel().obs;

  // Developer Debug Flags
  final RxBool showPerformanceOverlay = false.obs;
  final RxBool developerModeActive = kDebugMode.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    final savedSettings = _storage.read<Map<String, dynamic>>(_settingsKey);
    if (savedSettings != null) {
      settings.value = SettingsModel.fromJson(savedSettings);
    }
  }

  Future<void> saveSettings() async {
    await _storage.write(_settingsKey, settings.value.toJson());
  }

  void updateGameplay(GameplaySettings newGameplay) {
    settings.value = settings.value.copyWith(gameplay: newGameplay);
    saveSettings();
  }

  void updateGraphics(GraphicsSettings newGraphics) {
    settings.value = settings.value.copyWith(graphics: newGraphics);
    saveSettings();
  }

  void updateAccessibility(AccessibilitySettings newAccessibility) {
    settings.value = settings.value.copyWith(accessibility: newAccessibility);
    saveSettings();
  }

  void updateNotifications(NotificationSettings newNotifications) {
    settings.value = settings.value.copyWith(notifications: newNotifications);
    saveSettings();
  }

  // Developer mode overrides
  void togglePerformanceOverlay() {
    showPerformanceOverlay.value = !showPerformanceOverlay.value;
  }

  void cheatAddCoins() {
    try {
      final home = Get.find<PremiumHomeController>();
      home.coins.value += 100000;

      // Play coin explosion VFX
      final Offset center = Offset(Get.width / 2, Get.height / 2);
      final Offset endPoint = Offset(Get.width - 90, 42);

      VfxController.instance.playEffect(
        EffectPreset.coinBurst,
        center,
        endPoint: endPoint,
      );
    } catch (_) {}
  }

  void cheatAddXp() {
    try {
      final prog = Get.find<ProgressionController>();
      prog.cheatAddXp(250);
    } catch (_) {}
  }

  void resetToDefault() {
    settings.value = SettingsModel();
    saveSettings();
  }
}
