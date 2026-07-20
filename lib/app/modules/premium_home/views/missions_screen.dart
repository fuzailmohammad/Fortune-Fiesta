import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/data/models/mission_model.dart';
import 'package:fortune_fiesta/app/theme/animations/breathing_animation.dart';
import 'package:fortune_fiesta/app/theme/animations/glow_effects.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../controllers/mission_controller.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MissionController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF07050F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF140F27),
          title: const Text(
            'FIESTA MISSIONS',
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
          bottom: TabBar(
            dividerColor: Colors.white10,
            indicatorColor: PremiumColors.premiumGold,
            labelColor: PremiumColors.premiumGold,
            unselectedLabelColor: Colors.white38,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 0.5),
            tabs: const [
              Tab(text: 'DAILY'),
              Tab(text: 'WEEKLY'),
              Tab(text: 'ACHIEVEMENTS'),
            ],
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
          child: TabBarView(
            children: [
              // Daily tab
              Obx(() {
                final dailies = controller.activeMissions
                    .where((m) => m.type == MissionType.daily)
                    .toList();
                return _buildMissionsList(dailies, controller);
              }),

              // Weekly tab
              Obx(() {
                final weeklies = controller.activeMissions
                    .where((m) => m.type == MissionType.weekly)
                    .toList();
                return _buildMissionsList(weeklies, controller);
              }),

              // Achievements tab
              Obx(() {
                final achs = controller.achievements;
                return _buildAchievementsList(achs, controller);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionsList(
      List<MissionModel> list, MissionController controller) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'NO ACTIVE MISSIONS',
          style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return MissionCard(
          mission: list[index],
          onClaim: () => controller.claimMission(list[index].id),
        );
      },
    );
  }

  Widget _buildAchievementsList(
      List<AchievementModel> list, MissionController controller) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'NO ACHIEVEMENTS',
          style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return AchievementCard(
          achievement: list[index],
          onClaim: () => controller.claimAchievement(list[index].id),
        );
      },
    );
  }
}

// Reusable beveled Card for Missions
class MissionCard extends StatelessWidget {
  final MissionModel mission;
  final VoidCallback onClaim;

  const MissionCard({
    super.key,
    required this.mission,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        (mission.currentValue / mission.targetValue).clamp(0.0, 1.0);
    final bool isCompleted = mission.state == MissionState.completed;
    final bool isClaimed = mission.state == MissionState.claimed;

    return Opacity(
      opacity: isClaimed ? 0.55 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PremiumColors.purpleGlass.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted && !isClaimed
                ? PremiumColors.premiumGold
                : PremiumColors.royalPurple.withValues(alpha: 0.2),
            width: isCompleted && !isClaimed ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (isCompleted && !isClaimed)
              BoxShadow(
                color: PremiumColors.premiumGold.withValues(alpha: 0.1),
                blurRadius: 10,
              ),
          ],
        ),
        child: Row(
          children: [
            // Emitter/Difficulty Badge details on the Left
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF07050F),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted && !isClaimed
                          ? PremiumColors.premiumGold
                          : Colors.white10,
                    ),
                  ),
                  child: Icon(
                    _getMissionIcon(mission.id),
                    color: isCompleted && !isClaimed
                        ? PremiumColors.premiumGold
                        : PremiumColors.electricBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(mission.difficulty)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _getDifficultyColor(mission.difficulty)
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    mission.difficulty.name.toUpperCase(),
                    style: TextStyle(
                      color: _getDifficultyColor(mission.difficulty),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // Content details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mission.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Progress metrics
                  Row(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 8,
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isCompleted && !isClaimed
                                          ? [
                                              PremiumColors.premiumGold,
                                              Colors.amber
                                            ]
                                          : [
                                              PremiumColors.neonCyan,
                                              PremiumColors.electricBlue
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${mission.currentValue}/${mission.targetValue}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Claim buttons
            if (isClaimed)
              const Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white30, size: 28)
            else if (isCompleted)
              SleekBreathingAnimation(
                minScale: 0.95,
                maxScale: 1.05,
                child: TactilePressEffect(
                  onPressed: onClaim,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: PremiumGradients.gold,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color:
                              PremiumColors.premiumGold.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Text(
                      'CLAIM',
                      style: TextStyle(
                        color: PremiumColors.richBlack,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              )
            else
              // Reward Preview
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getRewardIcon(mission.rewardType),
                    color: PremiumColors.premiumGold,
                    size: 16,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '+${mission.rewardValue}',
                    style: const TextStyle(
                      color: PremiumColors.premiumGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  IconData _getMissionIcon(String id) {
    if (id.contains('spin')) {
      return Icons.casino_outlined;
    } else if (id.contains('win')) {
      return Icons.workspace_premium_outlined;
    } else {
      return Icons.monetization_on_outlined;
    }
  }

  IconData _getRewardIcon(String type) {
    if (type == 'xp') {
      return Icons.star_rounded;
    } else if (type == 'diamonds') {
      return Icons.diamond_rounded;
    } else {
      return Icons.monetization_on_rounded;
    }
  }

  Color _getDifficultyColor(MissionDifficulty difficulty) {
    switch (difficulty) {
      case MissionDifficulty.easy:
        return PremiumColors.successGreen;
      case MissionDifficulty.medium:
        return PremiumColors.electricBlue;
      case MissionDifficulty.hard:
        return Colors.orangeAccent;
      case MissionDifficulty.legendary:
        return PremiumColors.premiumGold;
    }
  }
}

// Reusable bejeweled Card for Achievements
class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback onClaim;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        (achievement.currentValue / achievement.targetValue).clamp(0.0, 1.0);
    final bool isCompleted =
        achievement.currentValue >= achievement.targetValue;
    final bool isClaimed = achievement.isClaimed;

    return Opacity(
      opacity: isClaimed ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PremiumColors.purpleGlass.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted && !isClaimed
                ? _getTierColor(achievement.tier)
                : PremiumColors.royalPurple.withValues(alpha: 0.15),
            width: isCompleted && !isClaimed ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Bejeweled Badge frame on the Left
            Column(
              children: [
                GlowingEffect(
                  glowColor: _getTierColor(achievement.tier),
                  maxSpread: isCompleted && !isClaimed ? 8.0 : 0.0,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF07050F),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getTierColor(achievement.tier),
                        width: 2.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.shield_rounded,
                      color: _getTierColor(achievement.tier),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  achievement.tier.toUpperCase(),
                  style: TextStyle(
                    color: _getTierColor(achievement.tier),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // Content details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Progress indicators
                  Row(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 8,
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _getTierColor(achievement.tier),
                                        _getTierColor(achievement.tier)
                                            .withValues(alpha: 0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${achievement.currentValue}/${achievement.targetValue}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Action claiming
            if (isClaimed)
              const Icon(Icons.check_circle,
                  color: PremiumColors.successGreen, size: 28)
            else if (isCompleted)
              SleekBreathingAnimation(
                minScale: 0.95,
                maxScale: 1.05,
                child: TactilePressEffect(
                  onPressed: onClaim,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getTierColor(achievement.tier),
                          _getTierColor(achievement.tier)
                              .withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: _getTierColor(achievement.tier)
                              .withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Text(
                      'CLAIM',
                      style: TextStyle(
                        color: PremiumColors.richBlack,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              )
            else
              // Reward Preview
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    achievement.tier == 'diamond'
                        ? Icons.diamond_rounded
                        : Icons.monetization_on_rounded,
                    color: PremiumColors.premiumGold,
                    size: 16,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '+${achievement.rewardValue}',
                    style: const TextStyle(
                      color: PremiumColors.premiumGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'bronze':
        return const Color(0xFFCD7F32); // Bronze brown
      case 'silver':
        return const Color(0xFFC0C0C0); // Silver metallic
      case 'gold':
        return PremiumColors.premiumGold;
      case 'diamond':
      default:
        return PremiumColors.neonCyan;
    }
  }
}
