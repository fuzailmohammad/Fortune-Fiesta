import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/modules/premium_home/views/settings_dashboard_screen.dart';
import 'package:fortune_fiesta/app/modules/premium_home/views/shop_dashboard_screen.dart';
import 'package:fortune_fiesta/app/modules/premium_home/views/widgets/profile_hud.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../controllers/premium_home_controller.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _coinPulseController;
  int _lastCoinsValue = 0;

  @override
  void initState() {
    super.initState();
    _coinPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    final controller = Get.find<PremiumHomeController>();
    _lastCoinsValue = controller.coins.value;

    // Pulse the coin balance icon whenever coins value changes
    ever(controller.coins, (_) {
      if (mounted) {
        _coinPulseController.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _coinPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PremiumHomeController>();

    return RepaintBoundary(
      child: Container(
        height: 72,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Sleek Ambient Profile HUD & Level Progress
            const ProfileHudWidget(),

            // 2. Action widgets sub-row
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glassmorphic Capsule Coin Balance
                Obx(() {
                  final bool isSpinning = controller.isSpinning.value;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 36,
                    padding: const EdgeInsets.only(left: 6, right: 3),
                    decoration: BoxDecoration(
                      color: PremiumColors.purpleGlass.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSpinning
                            ? PremiumColors.electricBlue
                            : PremiumColors.premiumGold.withValues(alpha: 0.4),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSpinning
                              ? PremiumColors.electricBlue.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.15),
                          blurRadius: isSpinning ? 8 : 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Gold Coin Icon
                            ScaleTransition(
                              scale:
                                  Tween<double>(begin: 0.95, end: 1.12).animate(
                                CurvedAnimation(
                                  parent: _coinPulseController,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: PremiumGradients.gold,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.monetization_on_rounded,
                                    color: PremiumColors.richBlack,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Ticking Animated Number
                            TweenAnimationBuilder<int>(
                              tween: IntTween(
                                  begin: _lastCoinsValue,
                                  end: controller.coins.value),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutQuad,
                              builder: (context, value, child) {
                                _lastCoinsValue = value; // Keep synchronized
                                return Text(
                                  _formatCoins(value),
                                  style:
                                      PremiumTypography.numbersStyle.copyWith(
                                    fontSize: 15,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),

                            // Tactile Buy Coins button
                            TactilePressEffect(
                              onPressed: () =>
                                  Get.to(() => const ShopDashboardScreen()),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: PremiumGradients.gold,
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: PremiumColors.richBlack,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(width: 8),

                // 3. Tactile Settings gear button
                TactilePressEffect(
                  onPressed: () => Get.to(() => const SettingsDashboardScreen()),
                  child: Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: PremiumColors.purpleGlass.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PremiumColors.royalPurple.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCoins(int value) {
    if (value < 1000) return value.toString();
    final String valStr = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < valStr.length; i++) {
      if (i > 0 && (valStr.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(valStr[i]);
    }
    return buffer.toString();
  }
}
