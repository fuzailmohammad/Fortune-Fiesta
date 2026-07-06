import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/audio_model.dart';
import '../services/storage_service.dart';

class AudioController extends GetxController with WidgetsBindingObserver {
  final StorageService _storage = Get.find<StorageService>();

  static const String _settingsKey = 'audio_mixer_settings';

  final Rx<AudioSettingsModel> settings = AudioSettingsModel().obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      stopAllMusic();
    } else if (state == AppLifecycleState.resumed) {
      resumeBackgroundMusic();
    }
  }

  void _loadData() {
    final savedSettings = _storage.read<Map<String, dynamic>>(_settingsKey);
    if (savedSettings != null) {
      settings.value = AudioSettingsModel.fromJson(savedSettings);
    }
  }

  Future<void> _saveSettings() async {
    await _storage.write(_settingsKey, settings.value.toJson());
  }

  // 🔉 Trigger Mock Audio Sound Effects
  void playEvent(AudioEvent event) {
    if (settings.value.isMuted) return;

    final double activeVolume =
        event == AudioEvent.coinBurst || event == AudioEvent.jackpot
            ? settings.value.sfxVolume * 1.0 // boost high value rewards
            : settings.value.sfxVolume;

    // Real implementation would load sound pool or just_audio asset streams.
    // We print simulated output matching designer specifications.
    debugPrint(
        '[AUDIO_ENGINE] Play Event: ${event.name} | Volume: ${activeVolume.toStringAsFixed(2)}');
  }

  void stopAllMusic() {
    debugPrint(
        '[AUDIO_ENGINE] Pausing/Stopping all music loops for background lifecycle.');
  }

  void resumeBackgroundMusic() {
    if (settings.value.isMuted) return;
    debugPrint('[AUDIO_ENGINE] Resuming background theme music loop.');
  }

  // 📳 Trigger Native Vibration Profiles
  Future<void> triggerHaptic(HapticProfile profile) async {
    if (!settings.value.hapticsEnabled) return;

    switch (profile) {
      case HapticProfile.veryLight:
        // Flutter doesn't have very light impact built in, we tick lightImpact
        await HapticFeedback.lightImpact();
        break;
      case HapticProfile.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticProfile.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticProfile.strong:
        await HapticFeedback.heavyImpact();
        break;
      case HapticProfile.success:
        await HapticFeedback.vibrate();
        break;
      case HapticProfile.celebration:
        // Double vibrate pattern simulation
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
        break;
    }
  }

  // Sliders
  void setMusicVolume(double vol) {
    settings.value = settings.value.copyWith(musicVolume: vol);
    _saveSettings();
  }

  void setSfxVolume(double vol) {
    settings.value = settings.value.copyWith(sfxVolume: vol);
    _saveSettings();
  }

  void toggleMute() {
    settings.value = settings.value.copyWith(isMuted: !settings.value.isMuted);
    _saveSettings();
  }

  void toggleHaptics(bool enabled) {
    settings.value = settings.value.copyWith(hapticsEnabled: enabled);
    _saveSettings();
  }
}
