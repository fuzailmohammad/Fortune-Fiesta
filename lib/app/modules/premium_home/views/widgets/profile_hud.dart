import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/animations/glow_effects.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../controllers/progression_controller.dart';

class ProfileHudWidget extends StatelessWidget {
  const ProfileHudWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProgressionController>()) return const SizedBox.shrink();
    final controller = Get.find<ProgressionController>();

    return TactilePressEffect(
      onPressed: () => _openStatsDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Obx(() {
          final profile = controller.profile.value;
          final int level = profile.level;
          final int xp = profile.xp;
          final int xpRequired = controller.getXpRequiredForLevel(level);
          final double progress = (xp / xpRequired).clamp(0.0, 1.0);

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar Stack with Level Badge
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // Gold frame avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PremiumColors.premiumGold,
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              PremiumColors.premiumGold.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFF140F27),
                      backgroundImage: AssetImage(
                          'assets/images/symbols/cherries.png'), // Fallback placeholder asset
                      radius: 20,
                    ),
                  ),

                  // Level Badge
                  Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: PremiumGradients.gold,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 2),
                      ],
                    ),
                    child: Text(
                      '$level',
                      style: const TextStyle(
                        color: PremiumColors.richBlack,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Compact XP bar
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Mini Progress Bar
                  Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 72 * progress,
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF00C853)],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF)
                                  .withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  void _openStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87.withValues(alpha: 0.85),
      builder: (_) => const ProfileStatsDialog(),
    );
  }
}

class ProfileStatsDialog extends StatelessWidget {
  const ProfileStatsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgressionController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF140F27).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: PremiumColors.premiumGold,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: PremiumColors.royalPurple.withValues(alpha: 0.5),
              blurRadius: 30,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PLAYER PROFILE',
                    style: TextStyle(
                      color: PremiumColors.premiumGold,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: Colors.white10),

              const SizedBox(height: 12),

              // Avatar & Level HUD representation
              Obx(() {
                final profile = controller.profile.value;
                final xpRequired =
                    controller.getXpRequiredForLevel(profile.level);
                final double progress =
                    (profile.xp / xpRequired).clamp(0.0, 1.0);

                return Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GlowingEffect(
                          glowColor: PremiumColors.premiumGold,
                          maxSpread: 10,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: PremiumColors.premiumGold, width: 3),
                            ),
                            child: const CircleAvatar(
                              backgroundColor: Color(0xFF07050F),
                              backgroundImage: AssetImage(
                                  'assets/images/symbols/cherries.png'),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: PremiumGradients.gold,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Colors.white, width: 1.0),
                            ),
                            child: Text(
                              'LVL ${profile.level}',
                              style: const TextStyle(
                                color: PremiumColors.richBlack,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'XP: ${profile.xp} / $xpRequired',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Large XP Bar
                    Container(
                      height: 10,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00E5FF), Color(0xFF00C853)],
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 24),

              // Statistics grid (lifetime metrics)
              Obx(() {
                final stats = controller.profile.value.stats;
                final double winRate = stats.lifetimeSpins > 0
                    ? (stats.totalWins / stats.lifetimeSpins) * 100
                    : 0.0;

                return GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.2,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _StatCard(label: 'SPINS', value: '${stats.lifetimeSpins}'),
                    _StatCard(label: 'WINS', value: '${stats.totalWins}'),
                    _StatCard(
                        label: 'WIN RATE',
                        value: '${winRate.toStringAsFixed(1)}%'),
                    _StatCard(label: 'BEST WIN', value: '${stats.highestWin}'),
                    _StatCard(label: 'JACKPOTS', value: '${stats.jackpotsWon}'),
                    _StatCard(
                        label: 'STREAK',
                        value: '${controller.profile.value.streak} days'),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF07050F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PremiumColors.royalPurple.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: PremiumColors.premiumGold,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
