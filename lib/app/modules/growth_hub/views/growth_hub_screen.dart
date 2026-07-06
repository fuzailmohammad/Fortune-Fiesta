import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/growth_manager.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/views/collectible_albums_view.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/views/community_events_view.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/views/cosmetic_salon_view.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/views/photo_mode_studio.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

class GrowthHubScreen extends StatefulWidget {
  const GrowthHubScreen({super.key});

  @override
  State<GrowthHubScreen> createState() => _GrowthHubScreenState();
}

class _GrowthHubScreenState extends State<GrowthHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
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
                // Custom App Bar
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
                          const Icon(Icons.auto_awesome_mosaic,
                              color: PremiumColors.premiumGold, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'ENGAGEMENT & GROWTH HUB',
                            style: PremiumTypography.headingStyle
                                .copyWith(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt,
                            color: PremiumColors.premiumGold, size: 24),
                        tooltip: 'Open Photo Studio',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const PhotoModeStudio(),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Glassmorphic Tab Bar
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: PremiumColors.purpleGlass.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color:
                            PremiumColors.royalPurple.withValues(alpha: 0.4)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: PremiumColors.premiumGold,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 11),
                    unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 11),
                    tabs: const [
                      Tab(text: '📚 ALBUMS'),
                      Tab(text: '👗 SALON'),
                      Tab(text: '🌍 CO-OP'),
                      Tab(text: '🔥 STREAKS'),
                    ],
                  ),
                ),

                // Tab Views
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        const CollectibleAlbumsView(),
                        const CosmeticSalonView(),
                        const CommunityEventsView(),
                        _buildStreaksTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreaksTab() {
    final manager = GrowthManager.to;

    return Column(
      children: [
        // Top Loyalty Strip
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF6D00).withValues(alpha: 0.5),
                PremiumColors.royalPurple.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFFFF6D00).withValues(alpha: 0.6),
                width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department,
                  color: Color(0xFFFF6D00), size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LOYALTY STREAK ENGINE',
                        style: PremiumTypography.subHeadingStyle
                            .copyWith(color: const Color(0xFFFF6D00))),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          'Current Login Streak: ${manager.currentDailyStreak.value} Days 🔥',
                          style: PremiumTypography.captionSmall
                              .copyWith(color: Colors.white70),
                        )),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  manager.simulateNextDayLogin();
                  Get.snackbar('STREAK INCREASED!',
                      'Simulated login for tomorrow. Your streak is growing!',
                      backgroundColor: const Color(0xFFFF6D00),
                      colorText: Colors.black);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6D00),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('+1 DAY',
                    style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Streaks List
        Expanded(
          child: Obx(() {
            final streaks = manager.activeStreaks;
            return ListView.separated(
              itemCount: streaks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, idx) {
                final streak = streaks[idx];
                final bool isReady = streak.currentDays >= streak.targetDays &&
                    !streak.isClaimed;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PremiumColors.purpleGlass.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isReady ? PremiumColors.premiumGold : Colors.white24,
                      width: isReady ? 2.0 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(streak.title.toUpperCase(),
                              style: PremiumTypography.subHeadingStyle
                                  .copyWith(color: Colors.white, fontSize: 15)),
                          if (streak.isClaimed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: PremiumColors.electricBlue,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Text('CLAIMED',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900)),
                            )
                          else
                            Text(
                                '${streak.currentDays}/${streak.targetDays} Days',
                                style: PremiumTypography.numbersStyle.copyWith(
                                    fontSize: 13,
                                    color: PremiumColors.premiumGold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: streak.progressRatio,
                          backgroundColor: Colors.black45,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isReady
                                ? PremiumColors.premiumGold
                                : const Color(0xFFFF6D00),
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Reward: +${streak.rewardCoins} Coins',
                              style: const TextStyle(
                                  color: PremiumColors.premiumGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          if (isReady)
                            ElevatedButton(
                              onPressed: () {
                                if (GrowthManager.to
                                    .claimStreakReward(streak.streakId)) {
                                  Get.snackbar('STREAK CLAIMED!',
                                      '+${streak.rewardCoins} Coins added to your balance!',
                                      backgroundColor:
                                          PremiumColors.premiumGold,
                                      colorText: Colors.black);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PremiumColors.premiumGold,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('CLAIM REWARD',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11)),
                            )
                          else if (!streak.isClaimed)
                            Text(
                                '${streak.targetDays - streak.currentDays} days remaining',
                                style: PremiumTypography.captionSmall
                                    .copyWith(color: Colors.white54)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
