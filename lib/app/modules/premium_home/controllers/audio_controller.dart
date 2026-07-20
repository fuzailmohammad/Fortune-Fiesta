import 'package:audioplayers/audioplayers.dart' hide AudioEvent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/audio_model.dart';
import '../services/storage_service.dart';

class AudioController extends GetxController with WidgetsBindingObserver {
  final StorageService _storage = Get.find<StorageService>();

  static const String _settingsKey = 'audio_mixer_settings';

  final Rx<AudioSettingsModel> settings = AudioSettingsModel().obs;

  AudioPlayer? _bgmPlayer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _initBackgroundMusic();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgmPlayer?.dispose();
    super.onClose();
  }

  Future<void> _initBackgroundMusic() async {
    try {
      _bgmPlayer = AudioPlayer();
      await _bgmPlayer?.setReleaseMode(ReleaseMode.loop);
      await _updateBackgroundMusicState();
    } catch (e) {
      debugPrint('[AUDIO_ENGINE] Error initializing BGM: $e');
    }
  }

  Future<void> _updateBackgroundMusicState() async {
    if (_bgmPlayer == null) return;
    try {
      if (settings.value.isMuted || settings.value.musicVolume <= 0.01) {
        await _bgmPlayer?.pause();
      } else {
        await _bgmPlayer?.setVolume(settings.value.musicVolume.clamp(0.0, 1.0));
        if (_bgmPlayer?.state != PlayerState.playing) {
          await _bgmPlayer?.play(AssetSource('audio/bgm.wav'));
        }
      }
    } catch (e) {
      debugPrint('[AUDIO_ENGINE] Error updating BGM state: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
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

  // 🔉 Play Retro Casio Sound Effects
  Future<void> playEvent(AudioEvent event) async {
    if (settings.value.isMuted) return;

    final double activeVolume =
        event == AudioEvent.coinBurst ||
                event == AudioEvent.jackpot ||
                event == AudioEvent.winnerSpecial
            ? (settings.value.sfxVolume * 1.0).clamp(0.0, 1.0)
            : settings.value.sfxVolume.clamp(0.0, 1.0);

    String assetName;
    switch (event) {
      case AudioEvent.spinStart:
        assetName = 'audio/spin_start.wav';
        break;
      case AudioEvent.reelStop:
        assetName = 'audio/reel_stop.wav';
        break;
      case AudioEvent.buttonPress:
        assetName = 'audio/button_press.wav';
        break;
      case AudioEvent.coinBurst:
        assetName = 'audio/coin_burst.wav';
        break;
      case AudioEvent.levelUp:
        assetName = 'audio/level_up.wav';
        break;
      case AudioEvent.winSmall:
        assetName = 'audio/win_small.wav';
        break;
      case AudioEvent.winBig:
        assetName = 'audio/win_big.wav';
        break;
      case AudioEvent.jackpot:
        assetName = 'audio/jackpot.wav';
        break;
      case AudioEvent.winnerSpecial:
        assetName = 'audio/winner_special.wav';
        break;
    }

    try {
      final player = AudioPlayer();
      await player.setVolume(activeVolume);
      await player.play(AssetSource(assetName));
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (e) {
      debugPrint('[AUDIO_ENGINE] Error playing sound $assetName: $e');
    }
  }

  void stopAllMusic() {
    _bgmPlayer?.pause();
  }

  void resumeBackgroundMusic() {
    _updateBackgroundMusicState();
  }

  // 📳 Trigger Native Vibration Profiles
  Future<void> triggerHaptic(HapticProfile profile) async {
    if (!settings.value.hapticsEnabled) return;

    switch (profile) {
      case HapticProfile.veryLight:
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
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
        break;
    }
  }

  // Sliders & Toggles
  void setMusicVolume(double vol) {
    settings.value = settings.value.copyWith(musicVolume: vol);
    _saveSettings();
    _updateBackgroundMusicState();
  }

  void setSfxVolume(double vol) {
    settings.value = settings.value.copyWith(sfxVolume: vol);
    _saveSettings();
  }

  void toggleMute() {
    settings.value = settings.value.copyWith(isMuted: !settings.value.isMuted);
    _saveSettings();
    _updateBackgroundMusicState();
  }

  void toggleMusic([bool? enabled]) {
    final bool turnOn = enabled ?? (settings.value.musicVolume <= 0.01);
    settings.value = settings.value.copyWith(musicVolume: turnOn ? 0.8 : 0.0);
    _saveSettings();
    _updateBackgroundMusicState();
  }

  void toggleHaptics(bool enabled) {
    settings.value = settings.value.copyWith(hapticsEnabled: enabled);
    _saveSettings();
  }
}
