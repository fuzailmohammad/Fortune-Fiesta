import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/surprise_manager.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/views/growth_hub_screen.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

class CompactGrowthWidget extends StatelessWidget {
  const CompactGrowthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SurpriseManager>()) {
      return const SizedBox.shrink();
    }
    final surprise = SurpriseManager.to;

    return RepaintBoundary(
      child: TactilePressEffect(
        onPressed: () => Get.to(() => const GrowthHubScreen()),
        scaleFactor: 0.96,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PremiumColors.royalPurple.withValues(alpha: 0.75),
                const Color(0xFF38106A).withValues(alpha: 0.85),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: PremiumColors.premiumGold.withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: PremiumColors.premiumGold.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: PremiumColors.premiumGold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_mosaic,
                  color: PremiumColors.premiumGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'GROWTH & ALBUMS HUB',
                          style: TextStyle(
                            color: PremiumColors.premiumGold,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: PremiumColors.electricBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('LIVE',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                          surprise.bannerMessage.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white70, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
