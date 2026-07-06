import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/timeline_controller.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

class MemorableMomentOverlay extends StatelessWidget {
  const MemorableMomentOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TimelineController>()) return const SizedBox.shrink();
    final controller = TimelineController.to;

    return Obx(() {
      if (!controller.showCelebrationOverlay.value) {
        return const SizedBox.shrink();
      }
      final milestone = controller.activeCelebration.value;
      if (milestone == null) return const SizedBox.shrink();

      return Positioned.fill(
        child: Material(
          color: Colors.black54,
          child: Center(
            child: Container(
              width: 360,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3E1F00),
                    const Color(0xFF1B073A),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: PremiumColors.premiumGold, width: 3),
                boxShadow: [
                  BoxShadow(
                      color: PremiumColors.premiumGold.withValues(alpha: 0.6),
                      blurRadius: 40),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('✨ MEMORABLE MOMENT ACHIEVED! ✨',
                      style: TextStyle(
                          color: PremiumColors.premiumGold,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 24),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: PremiumColors.premiumGold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: PremiumColors.premiumGold, width: 2),
                    ),
                    child: Icon(
                      _getIcon(milestone.iconName),
                      color: PremiumColors.premiumGold,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    milestone.title,
                    style: PremiumTypography.headingStyle
                        .copyWith(fontSize: 22, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    milestone.category.toUpperCase(),
                    style: const TextStyle(
                        color: PremiumColors.electricBlue,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        fontSize: 11),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    milestone.description,
                    style: PremiumTypography.bodyStyle
                        .copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      controller.dismissCelebration();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumColors.premiumGold,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('AWESOME!',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'play_circle_filled':
        return Icons.play_circle_filled;
      case 'monetization_on':
        return Icons.monetization_on;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'military_tech':
        return Icons.military_tech;
      case 'diamond':
        return Icons.diamond;
      case 'public':
        return Icons.public;
      default:
        return Icons.stars;
    }
  }
}
