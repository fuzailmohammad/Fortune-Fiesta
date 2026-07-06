import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/animations/glow_effects.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../../data/models/liveops_model.dart';
import '../controllers/liveops_controller.dart';

class EventHubScreen extends StatelessWidget {
  const EventHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put LiveOpsController lazily if not present
    final controller = Get.put(LiveOpsController());

    return Obx(() {
      final Color accentColor = controller.getThemeAccentColor();
      final bool hasEvents = controller.activeEvents.isNotEmpty;
      final event = hasEvents ? controller.activeEvents.first : null;

      return Scaffold(
        backgroundColor: const Color(0xFF07050F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF140F27),
          title: Text(
            'EVENT CENTER',
            style: TextStyle(
              color: accentColor,
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
                // 1. Featured Active Event Banner
                if (event != null) ...[
                  _buildEventBanner(controller, event, accentColor),
                  const SizedBox(height: 28),
                ],

                // 2. Season Pass Milestone progression track
                const Text(
                  'SEASON 1 PROGRESS TRACK',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSeasonPassTrack(controller, accentColor),

                const SizedBox(height: 28),

                // 3. News Bulletins
                const Text(
                  'NEWS & ANNOUNCEMENTS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                _buildNewsBulletinList(controller),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEventBanner(
      LiveOpsController controller, LiveEventModel event, Color accentColor) {
    final int sec = controller.eventCountdownSeconds.value;

    return GlowingEffect(
      glowColor: accentColor,
      maxSpread: 6.0,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: PremiumColors.purpleGlass.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ACTIVE EVENT',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.hourglass_empty_rounded,
                        color: accentColor, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      _formatFullCountdown(sec),
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              event.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('EVENT CURRENCY',
                        style: TextStyle(
                            color: Colors.white30,
                            fontSize: 8,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      event.currencyName.toUpperCase(),
                      style: TextStyle(
                          color: accentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('GRAND REWARD',
                        style: TextStyle(
                            color: Colors.white30,
                            fontSize: 8,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      '+${event.rewardValue} Coins',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonPassTrack(
      LiveOpsController controller, Color accentColor) {
    final season = controller.currentSeason.value;
    if (season == null) return const SizedBox.shrink();

    // Group milestones by level to display Free & Premium parallel rows
    final Map<int, List<dynamic>> levels = {};
    for (var reward in season.rewardsTrack) {
      final int level = reward['level'];
      levels.putIfAbsent(level, () => []).add(reward);
    }

    final sortedLevels = levels.keys.toList()..sort();

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sortedLevels.length,
        itemBuilder: (context, idx) {
          final int lvl = sortedLevels[idx];
          final rewards = levels[lvl]!;

          final freeReward = rewards.firstWhereOrNull((r) => !r['isPremium']);
          final premReward = rewards.firstWhereOrNull((r) => r['isPremium']);

          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: 140,
            decoration: BoxDecoration(
              color: PremiumColors.purpleGlass.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // LEVEL HEADER INDICATOR
                Text(
                  'MILESTONE $lvl',
                  style: const TextStyle(
                    color: Colors.white30,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // FREE TRACK REWARD
                if (freeReward != null)
                  _buildTrackRewardPill(
                    controller: controller,
                    reward: freeReward,
                    label: 'FREE',
                    accentColor: accentColor,
                  ),

                // Divider line
                Container(height: 1, color: Colors.white10),

                // PREMIUM TRACK REWARD
                if (premReward != null)
                  _buildTrackRewardPill(
                    controller: controller,
                    reward: premReward,
                    label: 'PREMIUM',
                    accentColor: PremiumColors.premiumGold,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrackRewardPill({
    required LiveOpsController controller,
    required Map<String, dynamic> reward,
    required String label,
    required Color accentColor,
  }) {
    final bool claimed = reward['claimed'];
    final String type = reward['rewardType'];
    final int amount = reward['amount'];
    final int level = reward['level'];
    final bool isPremium = reward['isPremium'];

    Widget pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: claimed ? Colors.black26 : Colors.white10,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              claimed ? Colors.transparent : accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: claimed ? Colors.white24 : accentColor,
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '+$amount ${type.toUpperCase()}',
                style: TextStyle(
                  color: claimed ? Colors.white24 : Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(
            claimed ? Icons.check_circle_rounded : Icons.lock_open_rounded,
            color: claimed ? PremiumColors.successGreen : Colors.white30,
            size: 14,
          ),
        ],
      ),
    );

    if (!claimed) {
      pill = TactilePressEffect(
        onPressed: () => controller.claimSeasonPassMilestone(level, isPremium),
        child: pill,
      );
    }

    return pill;
  }

  Widget _buildNewsBulletinList(LiveOpsController controller) {
    final unread = controller.announcements.where((a) => !a.isRead).toList();
    if (unread.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: const Text(
          'No new announcements!',
          style: TextStyle(color: Colors.white24, fontSize: 12),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: unread.length,
      itemBuilder: (context, index) {
        final ann = unread[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PremiumColors.purpleGlass.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ann.category == 'patch_notes'
                          ? PremiumColors.electricBlue
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ann.category.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.white30, size: 16),
                    onPressed: () => controller.dismissAnnouncement(ann.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ann.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                ann.content,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                    height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatFullCountdown(int totalSeconds) {
    if (totalSeconds <= 0) return 'ENDED';
    final int d = totalSeconds ~/ 86400;
    final int h = (totalSeconds % 86400) ~/ 3600;
    final int m = (totalSeconds % 3600) ~/ 60;
    final int s = totalSeconds % 60;

    return '${d}d ${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
