import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../../data/models/settings_model.dart';
import '../controllers/audio_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsDashboardScreen extends StatelessWidget {
  const SettingsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put SettingsController lazily if not present
    final controller = Get.put(SettingsController());
    final audioController = Get.put(AudioController());

    return Scaffold(
      backgroundColor: const Color(0xFF07050F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF140F27),
        title: const Text(
          'SETTINGS CENTER',
          style: TextStyle(
            color: PremiumColors.premiumGold,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF07050F), Color(0xFF140F27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Gameplay Settings Panel
              _buildGameplayPanel(controller),
              const SizedBox(height: 24),

              // 2. Graphics & Performance Panel
              _buildGraphicsPanel(controller),
              const SizedBox(height: 24),

              // 3. Audio & Haptics Mixer Panel
              _buildAudioMixerPanel(audioController),
              const SizedBox(height: 24),

              // 4. Accessibility Panel
              _buildAccessibilityPanel(controller),
              const SizedBox(height: 24),

              // 5. Account & Privacy Panel
              _buildAccountPrivacyPanel(controller),
              const SizedBox(height: 24),

              // 6. Developer Tools (Cheat Engine)
              Obx(() {
                if (controller.developerModeActive.value) {
                  return _buildDeveloperPanel(controller);
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameplayPanel(SettingsController controller) {
    return Obx(() {
      final gp = controller.settings.value.gameplay;
      return _buildSectionCard(
        title: 'GAMEPLAY PREFERENCES',
        children: [
          _buildSwitchTile(
            title: 'Auto Spin Reels',
            subtitle: 'Spins next round automatically',
            value: gp.autoSpin,
            onChanged: (val) =>
                controller.updateGameplay(gp.copyWith(autoSpin: val)),
          ),
          _buildSwitchTile(
            title: 'Turbo Spin Mode',
            subtitle: 'Reduces reel deceleration delay',
            value: gp.turboSpin,
            onChanged: (val) =>
                controller.updateGameplay(gp.copyWith(turboSpin: val)),
          ),
          _buildSwitchTile(
            title: 'Show Active Paylines',
            subtitle: 'Highlights winning paylines progressively',
            value: gp.showWinningLine,
            onChanged: (val) =>
                controller.updateGameplay(gp.copyWith(showWinningLine: val)),
          ),
        ],
      );
    });
  }

  Widget _buildGraphicsPanel(SettingsController controller) {
    return Obx(() {
      final gr = controller.settings.value.graphics;
      return _buildSectionCard(
        title: 'GRAPHICS & FRAME RATE',
        children: [
          // Selectable quality tier rows
          const Text('RENDER QUALITY PRESETS',
              style: TextStyle(
                  color: Colors.white30,
                  fontSize: 8,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: GraphicsQuality.values.map((q) {
              final bool isSelected = gr.quality == q;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: TactilePressEffect(
                    onPressed: () =>
                        controller.updateGraphics(gr.copyWith(quality: q)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF140F27)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: isSelected
                                ? PremiumColors.premiumGold
                                : Colors.transparent),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        q.name.toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? PremiumColors.premiumGold
                              : Colors.white54,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          // Selectable target frame rate pills
          const Text('TARGET FRAME RATE (FPS)',
              style: TextStyle(
                  color: Colors.white30,
                  fontSize: 8,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: FrameRate.values.map((fps) {
              final bool isSelected = gr.fps == fps;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: TactilePressEffect(
                    onPressed: () =>
                        controller.updateGraphics(gr.copyWith(fps: fps)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF140F27)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: isSelected
                                ? PremiumColors.premiumGold
                                : Colors.transparent),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        fps.name.replaceAll('fps', '').toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? PremiumColors.premiumGold
                              : Colors.white54,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'Battery Saver',
            subtitle: 'Caps frame rate at 60 FPS in background',
            value: gr.batterySaver,
            onChanged: (val) =>
                controller.updateGraphics(gr.copyWith(batterySaver: val)),
          ),
        ],
      );
    });
  }

  Widget _buildAudioMixerPanel(AudioController audioController) {
    return Obx(() {
      final s = audioController.settings.value;
      return _buildSectionCard(
        title: 'AUDIO & HAPTIX MIXER',
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Master Mute Toggles',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  s.isMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: s.isMuted
                      ? PremiumColors.dangerRed
                      : PremiumColors.premiumGold,
                ),
                onPressed: () => audioController.toggleMute(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            title: 'Casio Background Music',
            subtitle: 'Continuously playing retro arcade synth loop',
            value: s.musicVolume > 0 && !s.isMuted,
            onChanged: (enabled) => audioController.toggleMusic(enabled),
          ),
          const SizedBox(height: 12),
          const Text('MUSIC VOLUME',
              style: TextStyle(
                  color: Colors.white30,
                  fontSize: 8,
                  fontWeight: FontWeight.bold)),
          Slider(
            value: s.musicVolume,
            onChanged: s.isMuted ? null : audioController.setMusicVolume,
            activeColor: PremiumColors.premiumGold,
            inactiveColor: Colors.white10,
          ),
          const SizedBox(height: 8),
          const Text('EFFECTS VOLUME (SFX)',
              style: TextStyle(
                  color: Colors.white30,
                  fontSize: 8,
                  fontWeight: FontWeight.bold)),
          Slider(
            value: s.sfxVolume,
            onChanged: s.isMuted ? null : audioController.setSfxVolume,
            activeColor: PremiumColors.premiumGold,
            inactiveColor: Colors.white10,
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            title: 'Haptic Feedback Clicks',
            subtitle: 'Subtle physical vibration tick responses',
            value: s.hapticsEnabled,
            onChanged: audioController.toggleHaptics,
          ),
        ],
      );
    });
  }

  Widget _buildAccessibilityPanel(SettingsController controller) {
    return Obx(() {
      final acc = controller.settings.value.accessibility;
      return _buildSectionCard(
        title: 'ACCESSIBILITY CONTROLS',
        children: [
          _buildSwitchTile(
            title: 'Reduce Motion Settings',
            subtitle: 'Mutes high speed zooming and rumbling transitions',
            value: acc.reduceMotion,
            onChanged: (val) =>
                controller.updateAccessibility(acc.copyWith(reduceMotion: val)),
          ),
          _buildSwitchTile(
            title: 'High Contrast Mode',
            subtitle: 'Increases readability border thickness',
            value: acc.highContrast,
            onChanged: (val) =>
                controller.updateAccessibility(acc.copyWith(highContrast: val)),
          ),
          const SizedBox(height: 12),
          const Text('COLORBLINDNESS FILTERS',
              style: TextStyle(
                  color: Colors.white30,
                  fontSize: 8,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: ColorBlindMode.values.map((cb) {
              final bool isSelected = acc.colorblind == cb;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: TactilePressEffect(
                    onPressed: () => controller
                        .updateAccessibility(acc.copyWith(colorblind: cb)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF140F27)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: isSelected
                                ? PremiumColors.premiumGold
                                : Colors.transparent),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cb.name.replaceAll('none', 'Off').toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? PremiumColors.premiumGold
                              : Colors.white54,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildAccountPrivacyPanel(SettingsController controller) {
    return _buildSectionCard(
      title: 'ACCOUNT & PRIVACY',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connected Account',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Guest Mode Active',
                  style: TextStyle(color: Colors.white30, fontSize: 8),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('SYNC GOOGLE',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Danger Zone: Delete Account
        TactilePressEffect(
          onPressed: () {
            Get.snackbar(
              'DELETE ACCOUNT',
              'Account deletion is safe but locked in this sandbox build.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: PremiumColors.dangerRed,
              colorText: Colors.white,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: PremiumColors.dangerRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: PremiumColors.dangerRed.withValues(alpha: 0.35)),
            ),
            alignment: Alignment.center,
            child: const Text(
              'DELETE ACCOUNT DATA',
              style: TextStyle(
                  color: PremiumColors.dangerRed,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperPanel(SettingsController controller) {
    return _buildSectionCard(
      title: 'DEVELOPER DEBUGS (CHEAT BOX)',
      children: [
        _buildSwitchTile(
          title: 'Display Performance Metrics',
          subtitle: 'Draws native FPS graphs on screen',
          value: controller.showPerformanceOverlay.value,
          onChanged: (val) => controller.togglePerformanceOverlay(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TactilePressEffect(
                onPressed: controller.cheatAddCoins,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color:
                            PremiumColors.premiumGold.withValues(alpha: 0.35)),
                  ),
                  alignment: Alignment.center,
                  child: const Text('+100K GOLD',
                      style: TextStyle(
                          color: PremiumColors.premiumGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TactilePressEffect(
                onPressed: controller.cheatAddXp,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color:
                            PremiumColors.electricBlue.withValues(alpha: 0.35)),
                  ),
                  alignment: Alignment.center,
                  child: const Text('+250 XP',
                      style: TextStyle(
                          color: PremiumColors.electricBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helpers
  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PremiumColors.purpleGlass.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: PremiumColors.royalPurple.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white30, fontSize: 8),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: PremiumColors.premiumGold,
            activeTrackColor: PremiumColors.premiumGold.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}
