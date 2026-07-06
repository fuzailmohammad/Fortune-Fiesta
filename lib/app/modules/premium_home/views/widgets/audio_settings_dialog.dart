import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../controllers/audio_controller.dart';

class AudioSettingsDialog extends StatelessWidget {
  const AudioSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AudioController>()) return const SizedBox.shrink();
    final controller = Get.find<AudioController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF140F27).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: PremiumColors.premiumGold.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: PremiumColors.royalPurple.withValues(alpha: 0.4),
              blurRadius: 30,
            ),
          ],
        ),
        child: Obx(() {
          final s = controller.settings.value;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AUDIO MIXER',
                    style: TextStyle(
                      color: PremiumColors.premiumGold,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
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
                    onPressed: () => controller.toggleMute(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Music Volume Slider
              const Text(
                'BACKGROUND MUSIC',
                style: TextStyle(
                    color: Colors.white30,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
              ),
              Row(
                children: [
                  const Icon(Icons.music_note_rounded,
                      color: Colors.white60, size: 18),
                  Expanded(
                    child: Slider(
                      value: s.musicVolume,
                      onChanged: s.isMuted ? null : controller.setMusicVolume,
                      activeColor: PremiumColors.premiumGold,
                      inactiveColor: Colors.white10,
                    ),
                  ),
                  Text(
                    '${(s.musicVolume * 100).toInt()}%',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // SFX Volume Slider
              const Text(
                'SOUND EFFECTS (SFX)',
                style: TextStyle(
                    color: Colors.white30,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
              ),
              Row(
                children: [
                  const Icon(Icons.volume_up_rounded,
                      color: Colors.white60, size: 18),
                  Expanded(
                    child: Slider(
                      value: s.sfxVolume,
                      onChanged: s.isMuted ? null : controller.setSfxVolume,
                      activeColor: PremiumColors.premiumGold,
                      inactiveColor: Colors.white10,
                    ),
                  ),
                  Text(
                    '${(s.sfxVolume * 100).toInt()}%',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Haptics Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HAPTIC VIBRATION',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Physical tactile feedback',
                        style: TextStyle(color: Colors.white30, fontSize: 8),
                      ),
                    ],
                  ),
                  Switch(
                    value: s.hapticsEnabled,
                    onChanged: controller.toggleHaptics,
                    activeThumbColor: PremiumColors.premiumGold,
                    activeTrackColor:
                        PremiumColors.premiumGold.withValues(alpha: 0.3),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Close button
              TactilePressEffect(
                onPressed: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'SAVE SETTINGS',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
