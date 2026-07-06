import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/data/models/adaptive_experience_model.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/player_mood_controller.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/timeline_controller.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

class PlayerJourneyTimelineScreen extends StatelessWidget {
  const PlayerJourneyTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TimelineController.to;
    final mood = Get.isRegistered<PlayerMoodController>()
        ? PlayerMoodController.to
        : null;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F071D),
                  Color(0xFF1B0E33),
                  Color(0xFF0C0518),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 22),
                        onPressed: () => Get.back(),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timeline,
                              color: PremiumColors.premiumGold, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'PLAYER JOURNEY TIMELINE',
                            style: PremiumTypography.headingStyle
                                .copyWith(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.auto_awesome,
                            color: PremiumColors.electricBlue, size: 24),
                        tooltip: 'Simulate Next Milestone',
                        onPressed: () => _showSimulatePicker(context),
                      ),
                    ],
                  ),
                ),

                // Player Personality Strip
                if (mood != null)
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: PremiumColors.purpleGlass.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color:
                              PremiumColors.premiumGold.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: PremiumColors.premiumGold
                                  .withValues(alpha: 0.2),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.person_pin,
                              color: PremiumColors.premiumGold, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ENGAGEMENT PROFILE ANALYSIS',
                                  style: PremiumTypography.captionSmall
                                      .copyWith(color: Colors.white60)),
                              const SizedBox(height: 2),
                              Obx(() => Text(
                                    'Personality: ${mood.activePersonality.value.name.toUpperCase()} 🏆',
                                    style: PremiumTypography.subHeadingStyle
                                        .copyWith(
                                            color: PremiumColors.premiumGold,
                                            fontSize: 14),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Timeline List
                Expanded(
                  child: Obx(() {
                    final list = controller.milestones;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      itemCount: list.length,
                      itemBuilder: (context, idx) {
                        final item = list[idx];
                        final isLast = idx == list.length - 1;
                        return _buildTimelineNode(item, isLast);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(TimelineMilestone item, bool isLast) {
    final color = item.isUnlocked ? PremiumColors.premiumGold : Colors.white24;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical Line & Node
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.isUnlocked
                      ? color.withValues(alpha: 0.2)
                      : Colors.black45,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(
                  item.isUnlocked ? _getIcon(item.iconName) : Icons.lock,
                  color: color,
                  size: 18,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: color.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: item.isUnlocked
                    ? PremiumColors.purpleGlass.withValues(alpha: 0.8)
                    : Colors.black38,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: color.withValues(alpha: 0.6), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title,
                          style: PremiumTypography.subHeadingStyle.copyWith(
                              color: item.isUnlocked
                                  ? Colors.white
                                  : Colors.white38,
                              fontSize: 15)),
                      if (item.isUnlocked)
                        Text(
                          '${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year}',
                          style: const TextStyle(
                              color: PremiumColors.electricBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        )
                      else
                        const Text('LOCKED',
                            style: TextStyle(
                                color: Colors.white30,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.description,
                      style: PremiumTypography.bodyStyle.copyWith(
                          color: item.isUnlocked
                              ? Colors.white70
                              : Colors.white30)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSimulatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF19102A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨ SIMULATE MILESTONE CELEBRATION',
                style: TextStyle(
                    color: PremiumColors.premiumGold,
                    fontWeight: FontWeight.w900,
                    fontSize: 16)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: TimelineController.to.milestones.map((m) {
                return ActionChip(
                  label: Text(m.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                  backgroundColor: PremiumColors.purpleGlass,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    TimelineController.to.simulateMilestoneCelebration(m.id);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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
