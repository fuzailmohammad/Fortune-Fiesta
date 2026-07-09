import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/dynamic_atmosphere_controller.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/player_mood_controller.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/recommendation_controller.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/views/player_journey_timeline_screen.dart';
import 'package:fortune_fiesta/app/modules/premium_home/views/retention_dashboard_screen.dart';
import 'package:fortune_fiesta/app/modules/premium_home/views/shop_dashboard_screen.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

class AdaptiveHudOverlay extends StatelessWidget {
  const AdaptiveHudOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PlayerMoodController>() ||
        !Get.isRegistered<RecommendationController>() ||
        !Get.isRegistered<DynamicAtmosphereController>()) {
      return const SizedBox.shrink();
    }

    final mood = PlayerMoodController.to;
    final rec = RecommendationController.to;
    final atmosphere = DynamicAtmosphereController.to;

    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        // 1. Long Session Break / Stretch Reminder Banner
        Obx(() {
          if (!mood.showBreakReminder.value) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00E676).withValues(alpha: 0.25),
                  const Color(0xFF1B0E33).withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00E676), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.self_improvement,
                    color: Color(0xFF00E676), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PAUSE & REFRESH',
                          style: PremiumTypography.subHeadingStyle.copyWith(
                              color: const Color(0xFF00E676), fontSize: 13)),
                      const Text(
                          "You've been spinning like a champion! Great time to stretch or hydrate without losing your luck!",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.close, color: Colors.white70, size: 18),
                  onPressed: mood.dismissBreakReminder,
                ),
              ],
            ),
          );
        }),

        // 2. Short Session Quick Access Shortcuts
        Obx(() {
          if (!mood.showShortSessionShortcuts.value) {
            return const SizedBox.shrink();
          }
          return Dismissible(
            key: const ValueKey('rapid_access_banner'),
            direction: DismissDirection.horizontal,
            onDismissed: (_) => mood.dismissShortSessionShortcuts(),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6, left: 14, right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: PremiumColors.purpleGlass.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: PremiumColors.electricBlue.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Text('⚡ RAPID ACCESS:',
                      style: TextStyle(
                          color: PremiumColors.electricBlue,
                          fontWeight: FontWeight.w900,
                          fontSize: 11)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildShortcutPill(
                              'Wheel', Icons.casino, () => Get.to(() => const RetentionDashboardScreen())),
                          const SizedBox(width: 6),
                          _buildShortcutPill('Quests', Icons.track_changes,
                              () => Get.to(() => const RetentionDashboardScreen())),
                          const SizedBox(width: 6),
                          _buildShortcutPill(
                              'Shop', Icons.diamond, () => Get.to(() => const ShopDashboardScreen())),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: mood.dismissShortSessionShortcuts,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.close, color: Colors.white70, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        // 3. Smart Contextual Recommendation Banner
        Obx(() {
          final item = rec.primaryRecommendation.value;
          if (item == null) return const SizedBox.shrink();

          return Dismissible(
            key: ValueKey('rec_${item.id}'),
            direction: DismissDirection.horizontal,
            onDismissed: (_) => rec.dismissPrimaryRecommendation(),
            child: GestureDetector(
              onTap: () {
                if (item.targetRoute == '/growth_hub') {
                  Get.to(() => const PlayerJourneyTimelineScreen());
                } else if (item.targetRoute == '/shop') {
                  Get.to(() => const ShopDashboardScreen());
                } else if (item.targetRoute == '/retention') {
                  Get.to(() => const RetentionDashboardScreen());
                } else {
                  Get.to(() => const RetentionDashboardScreen());
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumColors.royalPurple.withValues(alpha: 0.8),
                      const Color(0xFF2C0B53).withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: PremiumColors.premiumGold.withValues(alpha: 0.5),
                      width: 1.2),
                  boxShadow: [
                    BoxShadow(
                        color: PremiumColors.premiumGold.withValues(alpha: 0.1),
                        blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _getRecIcon(item.iconName),
                      color: PremiumColors.premiumGold,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                      color: PremiumColors.premiumGold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (atmosphere.atmosphereTitle.value.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  flex: 2,
                                  child: Text(
                                    atmosphere.atmosphereTitle.value,
                                    style: const TextStyle(
                                        color: PremiumColors.electricBlue,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(item.subtitle,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: PremiumColors.premiumGold,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(item.actionLabel,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 9)),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: rec.dismissPrimaryRecommendation,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.close, color: Colors.white70, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    ),
    );
  }

  Widget _buildShortcutPill(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: PremiumColors.premiumGold.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: PremiumColors.premiumGold, size: 13),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }

  IconData _getRecIcon(String name) {
    switch (name) {
      case 'track_changes':
        return Icons.track_changes;
      case 'casino':
        return Icons.casino;
      case 'diamond':
        return Icons.diamond;
      case 'person_pin':
        return Icons.person_pin;
      default:
        return Icons.auto_awesome;
    }
  }
}
