import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/animations/breathing_animation.dart';
import 'package:fortune_fiesta/app/theme/animations/glow_effects.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../../data/models/retention_model.dart';
import '../controllers/retention_controller.dart';

class RetentionDashboardScreen extends StatelessWidget {
  const RetentionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put RetentionController lazily if not present
    final controller = Get.put(RetentionController());

    return Scaffold(
      backgroundColor: const Color(0xFF07050F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF140F27),
        title: const Text(
          'REWARDS & BONUSES',
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
              // 1. Streak Tracker Indicator
              _buildStreakBanner(controller),

              const SizedBox(height: 24),

              // 2. 7-Day Calendar check-in
              const Text(
                'DAILY LOGIN CALENDAR',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              _buildCalendarGrid(controller),

              const SizedBox(height: 28),

              // 3. Lucky Wheel Section
              const Text(
                'LUCKY SPIN WHEEL',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              _buildLuckyWheelSection(controller),

              const SizedBox(height: 28),

              // 4. Mystery Box & Hourly Gifts
              const Text(
                'FREE COOLDOWN CHESTS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              _buildCooldownChests(controller),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakBanner(RetentionController controller) {
    return Obx(() {
      final streak = controller.streak.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: PremiumColors.purpleGlass.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: PremiumColors.royalPurple.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: Colors.orange, size: 28),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${streak.currentStreak} DAY STREAK',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Longest: ${streak.longestStreak} days',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF07050F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: PremiumColors.premiumGold.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.ac_unit_rounded,
                      color: Colors.cyan, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${streak.freezeCardsCount} FREEZE',
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCalendarGrid(RetentionController controller) {
    return Obx(() {
      final days = controller.calendar;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final bool isClaimed = day.isClaimed;
          final bool isLocked = day.isLocked;
          final bool isCurrent = !isClaimed && !isLocked;

          Widget card = Container(
            decoration: BoxDecoration(
              color: isClaimed
                  ? Colors.black38
                  : isCurrent
                      ? const Color(0xFF140F27)
                      : PremiumColors.purpleGlass.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent
                    ? PremiumColors.premiumGold
                    : isClaimed
                        ? Colors.white10
                        : PremiumColors.royalPurple.withValues(alpha: 0.15),
                width: isCurrent ? 1.8 : 1.0,
              ),
              boxShadow: [
                if (isCurrent)
                  BoxShadow(
                    color: PremiumColors.premiumGold.withValues(alpha: 0.15),
                    blurRadius: 8,
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'DAY ${day.day}',
                  style: TextStyle(
                    color:
                        isCurrent ? PremiumColors.premiumGold : Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  _getRewardIcon(day.rewardType),
                  color: isClaimed
                      ? Colors.white24
                      : isCurrent
                          ? PremiumColors.premiumGold
                          : PremiumColors.electricBlue,
                  size: 20,
                ),
                const SizedBox(height: 6),
                Text(
                  '${day.amount}',
                  style: TextStyle(
                    color: isClaimed ? Colors.white24 : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );

          if (isCurrent) {
            card = GlowingEffect(
              glowColor: PremiumColors.premiumGold,
              maxSpread: 6.0,
              child: SleekBreathingAnimation(
                minScale: 0.98,
                maxScale: 1.02,
                child: TactilePressEffect(
                  onPressed: () => controller.claimCalendarDay(day.day),
                  child: card,
                ),
              ),
            );
          } else {
            card = IgnorePointer(child: card);
          }

          return card;
        },
      );
    });
  }

  Widget _buildLuckyWheelSection(RetentionController controller) {
    return Center(
      child: Column(
        children: [
          // Circular Wheel frame stack with rotating matrix transits
          Stack(
            alignment: Alignment.center,
            children: [
              // Neon Outer Shadow Ring
              Container(
                width: 208,
                height: 208,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PremiumColors.premiumGold,
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumColors.premiumGold.withValues(alpha: 0.2),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),

              // Segment custom paint wheel
              Obx(() {
                return Transform.rotate(
                  angle: controller.wheelRotationAngle.value,
                  child: CustomPaint(
                    size: const Size(200, 200),
                    painter:
                        _LuckyWheelPainter(segments: controller.wheelSegments),
                  ),
                );
              }),

              // Dial Pointer needle (Points directly top)
              Positioned(
                top: 4,
                child: Container(
                  width: 24,
                  height: 28,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/symbols/lucky_seven.png'), // Mock pointer asset
                      fit: BoxFit.contain,
                    ),
                  ),
                  alignment: Alignment.topCenter,
                  child: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),

              // Spin action button center caps
              Obx(() {
                final bool spinning = controller.isWheelSpinning.value;
                return SleekBreathingAnimation(
                  minScale: 0.95,
                  maxScale: 1.05,
                  child: TactilePressEffect(
                    onPressed:
                        spinning ? null : () => controller.spinLuckyWheel(),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: PremiumGradients.gold,
                        boxShadow: [
                          BoxShadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        spinning ? 'SPINNING' : 'SPIN',
                        style: const TextStyle(
                          color: PremiumColors.richBlack,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCooldownChests(RetentionController controller) {
    return Row(
      children: [
        // 1. Hourly Chest Card
        Expanded(
          child: Obx(() {
            final int sec = controller.hourlyTimerSeconds.value;
            final bool isReady = sec == 0;

            Widget chest = Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: isReady
                    ? const Color(0xFF140F27)
                    : PremiumColors.purpleGlass.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isReady ? PremiumColors.premiumGold : Colors.white10,
                  width: isReady ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: isReady ? PremiumColors.premiumGold : Colors.white30,
                    size: 32,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'HOURLY GIFT',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isReady ? 'CLAIM READY' : _formatCooldown(sec),
                    style: TextStyle(
                      color:
                          isReady ? PremiumColors.successGreen : Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );

            if (isReady) {
              chest = SleekBreathingAnimation(
                minScale: 0.97,
                maxScale: 1.03,
                child: TactilePressEffect(
                  onPressed: controller.claimHourlyGift,
                  child: chest,
                ),
              );
            }

            return chest;
          }),
        ),

        const SizedBox(width: 12),

        // 2. Mystery Chest Card
        Expanded(
          child: Obx(() {
            final int sec = controller.mysteryTimerSeconds.value;
            final bool isReady = sec == 0;

            Widget chest = Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: isReady
                    ? const Color(0xFF140F27)
                    : PremiumColors.purpleGlass.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isReady ? PremiumColors.premiumGold : Colors.white10,
                  width: isReady ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.card_giftcard_rounded,
                    color: isReady ? PremiumColors.premiumGold : Colors.white30,
                    size: 32,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'MYSTERY BOX',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isReady ? 'CLAIM READY' : _formatCooldown(sec),
                    style: TextStyle(
                      color:
                          isReady ? PremiumColors.successGreen : Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );

            if (isReady) {
              chest = SleekBreathingAnimation(
                minScale: 0.97,
                maxScale: 1.03,
                child: TactilePressEffect(
                  onPressed: controller.claimMysteryGift,
                  child: chest,
                ),
              );
            }

            return chest;
          }),
        ),
      ],
    );
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

  String _formatCooldown(int seconds) {
    final int h = seconds ~/ 3600;
    final int m = (seconds % 3600) ~/ 60;
    final int s = seconds % 60;

    final String hs = h > 0 ? '${h.toString().padLeft(2, '0')}:' : '';
    final String ms = '${m.toString().padLeft(2, '0')}:';
    final String ss = s.toString().padLeft(2, '0');

    return '$hs$ms$ss';
  }
}

// Custom Painter drawing segmented Lucky Wheel sectors
class _LuckyWheelPainter extends CustomPainter {
  final List<WheelSegment> segments;

  _LuckyWheelPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double sweepAngle = (math.pi * 2) / segments.length;

    for (int i = 0; i < segments.length; i++) {
      paint.color = Color(segments[i].colorHex);
      final double startAngle =
          (i * sweepAngle) - (math.pi / 2) - (sweepAngle / 2);

      // Draw segment arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw segment text details
      canvas.save();
      canvas.translate(radius, radius);
      canvas.rotate(startAngle + sweepAngle / 2);

      // Rotates text labels along segment direction
      final textSpan = TextSpan(
        text: segments[i].displayLabel,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          height: 1.1,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -radius * 0.75),
      );

      canvas.restore();
    }

    // Draw sector inner golden rings dividers
    paint.color = PremiumColors.premiumGold.withValues(alpha: 0.4);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
