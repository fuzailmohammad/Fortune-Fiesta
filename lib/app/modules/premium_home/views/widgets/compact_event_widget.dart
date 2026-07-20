import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/animations/breathing_animation.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../controllers/liveops_controller.dart';
import '../event_hub_screen.dart';

class CompactEventWidget extends StatelessWidget {
  const CompactEventWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LiveOpsController>()) return const SizedBox.shrink();
    final controller = Get.find<LiveOpsController>();

    return Obx(() {
      if (controller.activeEvents.isEmpty) return const SizedBox.shrink();

      final event = controller.activeEvents.first;
      final int sec = controller.eventCountdownSeconds.value;
      final Color accentColor = controller.getThemeAccentColor();

      return TactilePressEffect(
        onPressed: () {
          Get.to(() => const EventHubScreen());
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: PremiumColors.purpleGlass.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SleekBreathingAnimation(
                    minScale: 0.9,
                    maxScale: 1.1,
                    child: Icon(
                      Icons.celebration_rounded,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Unlock exclusive rewards!',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Countdown Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  _formatCountdown(sec),
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _formatCountdown(int seconds) {
    if (seconds <= 0) return 'ENDED';
    final int d = seconds ~/ 86400;
    final int h = (seconds % 86400) ~/ 3600;
    final int m = (seconds % 3600) ~/ 60;

    if (d > 0) {
      return '${d}d ${h}h';
    }
    return '${h}h ${m}m';
  }
}
