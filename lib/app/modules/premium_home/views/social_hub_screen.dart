import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../controllers/social_controller.dart';

class SocialHubScreen extends StatelessWidget {
  const SocialHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put SocialController lazily if not present
    final controller = Get.put(SocialController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF07050F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF140F27),
          title: const Text(
            'SOCIAL LEAGUE',
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
          bottom: const TabBar(
            indicatorColor: PremiumColors.premiumGold,
            labelColor: PremiumColors.premiumGold,
            unselectedLabelColor: Colors.white38,
            tabs: [
              Tab(text: 'LEADERBOARD'),
              Tab(text: 'CUSTOMIZE'),
              Tab(text: 'FRIENDS'),
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
              // 1. LEADERBOARD LIST
              _buildLeaderboardTab(controller),

              // 2. PROFILE FRAMES & TITLE CUSTOMIZER
              _buildCustomizeTab(controller),

              // 3. FRIENDS LIST
              _buildFriendsTab(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab(SocialController controller) {
    return Obx(() {
      final list = controller.leaderboard;
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final entry = list[index];
          final bool isUser = entry.name.contains('You');

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isUser
                  ? PremiumColors.purpleGlass.withValues(alpha: 0.25)
                  : PremiumColors.purpleGlass.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUser
                    ? PremiumColors.premiumGold
                    : PremiumColors.royalPurple.withValues(alpha: 0.15),
                width: isUser ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Rank position
                    Container(
                      width: 24,
                      alignment: Alignment.center,
                      child: Text(
                        '#${entry.rank}',
                        style: TextStyle(
                          color: entry.rank == 1
                              ? PremiumColors.premiumGold
                              : entry.rank == 2
                                  ? Colors.grey
                                  : Colors.white60,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Profile frame avatar mockup
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white10,
                          child: Icon(Icons.person,
                              color: isUser
                                  ? PremiumColors.premiumGold
                                  : Colors.white24,
                              size: 16),
                        ),
                        if (entry.frame != 'none')
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: entry.frame == 'vip'
                                    ? const Color(0xFFE040FB)
                                    : PremiumColors.premiumGold,
                                width: 2.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.name,
                          style: TextStyle(
                            color: isUser
                                ? PremiumColors.premiumGold
                                : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'LVL ${entry.level}',
                          style: const TextStyle(
                              color: Colors.white30,
                              fontSize: 8,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Green online indicator
                    if (entry.isOnline)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: PremiumColors.successGreen),
                      ),

                    Text(
                      '${entry.score} pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildCustomizeTab(SocialController controller) {
    final titles = ['ROOKIE', 'SPIN MASTER', 'DIAMOND TYCOON', 'LEGENDARY'];
    final frames = ['none', 'gold', 'vip'];

    return Obx(() {
      final profile = controller.playerProfile.value;
      if (profile == null) return const SizedBox.shrink();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar Equip Preview
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor:
                        PremiumColors.purpleGlass.withValues(alpha: 0.4),
                    child: const Icon(Icons.person,
                        color: Colors.white30, size: 36),
                  ),
                  if (profile.frame != 'none')
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: profile.frame == 'vip'
                              ? const Color(0xFFE040FB)
                              : PremiumColors.premiumGold,
                          width: 3.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                profile.title.toUpperCase(),
                style: const TextStyle(
                  color: PremiumColors.premiumGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Select Custom Frame options
            const Text(
              'EQUIP COSMETIC FRAME',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: frames.map((f) {
                final bool isSelected = profile.frame == f;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TactilePressEffect(
                      onPressed: () => controller.equipFrame(f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF140F27)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? PremiumColors.premiumGold
                                : Colors.white10,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          f.toUpperCase(),
                          style: TextStyle(
                            color: isSelected
                                ? PremiumColors.premiumGold
                                : Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // Select Custom Title options
            const Text(
              'EQUIP PRESTIGE TITLE',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: titles.map((t) {
                final bool isSelected = profile.title == t;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: TactilePressEffect(
                    onPressed: () => controller.equipTitle(t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF140F27)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? PremiumColors.premiumGold
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            t,
                            style: TextStyle(
                              color: isSelected
                                  ? PremiumColors.premiumGold
                                  : Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded,
                                color: PremiumColors.premiumGold, size: 16),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFriendsTab(SocialController controller) {
    final TextEditingController inputController = TextEditingController();

    return Column(
      children: [
        // Friends input request box
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF140F27).withValues(alpha: 0.55),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: inputController,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: 'Enter Friend Username...',
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 11),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TactilePressEffect(
                onPressed: () {
                  final text = inputController.text.trim();
                  if (text.isNotEmpty) {
                    controller.addFriend(text);
                    inputController.clear();
                    Get.snackbar(
                      'FRIEND REQUEST',
                      'Mock request sent to $text!',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: PremiumColors.purpleGlass,
                      colorText: Colors.white,
                    );
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: PremiumGradients.gold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(
                        color: PremiumColors.richBlack,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Friends list builder
        Expanded(
          child: Obx(() {
            final list = controller.friends;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final f = list[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: PremiumColors.purpleGlass.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white10,
                                child: Icon(Icons.person,
                                    color: Colors.white30, size: 14),
                              ),
                              if (f.isOnline)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: PremiumColors.successGreen),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                f.recentActivity,
                                style: const TextStyle(
                                    color: Colors.white30, fontSize: 8),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Status pill tag
                      Text(
                        f.isOnline ? 'ONLINE' : 'OFFLINE',
                        style: TextStyle(
                          color: f.isOnline
                              ? PremiumColors.successGreen
                              : Colors.white24,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
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
