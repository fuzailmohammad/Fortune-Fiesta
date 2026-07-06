import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/views/growth_hub_screen.dart';
import 'package:fortune_fiesta/app/modules/premium_home/views/widgets/juice_decorators.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../controllers/premium_home_controller.dart';
import '../retention_dashboard_screen.dart';

class BottomActionDock extends StatelessWidget {
  const BottomActionDock({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PremiumHomeController>();

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: DockBackground(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 🎁 Rewards Action
              Obx(() {
                final bool available = controller.isRewardAvailable.value;
                final widget = ActionButton(
                  icon: Icons.card_giftcard_rounded,
                  label: 'Rewards',
                  color: PremiumColors.premiumGold,
                  isSelected: available,
                  notificationCount: available ? 1 : 0,
                  onPressed: () =>
                      Get.to(() => const RetentionDashboardScreen()),
                );
                return available ? JuiceWiggleDecorator(child: widget) : widget;
              }),

              // 🏆 Leaderboard Action
              ActionButton(
                icon: Icons.emoji_events_rounded,
                label: 'Leaderboard',
                color: PremiumColors.electricBlue,
                isSelected: false,
                onPressed: controller.openStats,
              ),

              // 📚 Albums / Growth Hub Action
              ActionButton(
                icon: Icons.auto_awesome_mosaic_rounded,
                label: 'Albums',
                color: const Color(0xFF00E5FF),
                isSelected: false,
                onPressed: () => Get.to(() => const GrowthHubScreen()),
              ),

              // 🛒 Shop Action
              ActionButton(
                icon: Icons.shopping_cart_rounded,
                label: 'Shop',
                color: const Color(0xFFFF9100),
                isSelected: false,
                onPressed: () {
                  Get.snackbar(
                    'GOLD STORE',
                    'Coin Shop is opening soon! Stay tuned!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: PremiumColors.purpleGlass,
                    colorText: PremiumColors.premiumGold,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),

              // ⚙️ More Actions
              ActionButton(
                icon: Icons.grid_view_rounded,
                label: 'More',
                color: const Color(0xFFE040FB),
                isSelected: false,
                onPressed: controller.openSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Glassmorphic Capsule Container
class DockBackground extends StatelessWidget {
  final Widget child;

  const DockBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: PremiumColors.purpleGlass.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: PremiumColors.royalPurple.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: PremiumColors.electricBlue.withValues(alpha: 0.04),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Single HUD Action Button with Tactile Press feedback
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final int notificationCount;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    this.notificationCount = 0,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isSelected ? color : PremiumColors.textLightGrey;

    return Expanded(
      child: TactilePressEffect(
        onPressed: onPressed,
        scaleFactor: 0.90, // Muted scale factor for small nav buttons
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topRight,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.08)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: activeColor,
                      size: 22,
                    ),
                  ),

                  // Notification Badge
                  if (notificationCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: NotificationBadge(count: notificationCount),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: activeColor,
                  fontSize: 9.5,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  final int count;

  const NotificationBadge({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: PremiumColors.dangerRed,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.0),
      ),
      constraints: const BoxConstraints(
        minWidth: 10,
        minHeight: 10,
      ),
    );
  }
}
