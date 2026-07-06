import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/welcome_back_controller.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

class WelcomeBackDialog extends StatelessWidget {
  const WelcomeBackDialog({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<WelcomeBackController>()) {
      return const SizedBox.shrink();
    }
    final controller = WelcomeBackController.to;

    return Obx(() {
      if (!controller.showWelcomePopup.value) return const SizedBox.shrink();
      final config = controller.activeConfig.value;

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
                    const Color(0xFF2C0B53),
                    const Color(0xFF140C24),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(28),
                border:
                    Border.all(color: PremiumColors.premiumGold, width: 2.5),
                boxShadow: [
                  BoxShadow(
                      color: PremiumColors.premiumGold.withValues(alpha: 0.4),
                      blurRadius: 30),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: PremiumColors.premiumGold,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      config.subtitle,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.stars,
                      color: PremiumColors.premiumGold, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    config.title,
                    style: PremiumTypography.headingStyle
                        .copyWith(fontSize: 22, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    config.motivationalMessage,
                    style: PremiumTypography.bodyStyle
                        .copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      controller.dismissWelcomePopup();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumColors.premiumGold,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('LET\'S SPIN!',
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
}
