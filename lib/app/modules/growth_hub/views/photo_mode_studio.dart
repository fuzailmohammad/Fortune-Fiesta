import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/cosmetic_manager.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/share_manager.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

class PhotoModeStudio extends StatelessWidget {
  final int winAmount;
  final bool isJackpot;

  const PhotoModeStudio({
    super.key,
    this.winAmount = 250000,
    this.isJackpot = true,
  });

  @override
  Widget build(BuildContext context) {
    final title = CosmeticManager.to.equippedTitleId.value
        .replaceAll('title_', '')
        .toUpperCase();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF140C24),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: PremiumColors.premiumGold, width: 2.5),
          boxShadow: [
            BoxShadow(
                color: PremiumColors.premiumGold.withValues(alpha: 0.3),
                blurRadius: 30),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('📸 PHOTO MODE STUDIO',
                    style: TextStyle(
                        color: PremiumColors.premiumGold,
                        fontWeight: FontWeight.w900,
                        fontSize: 14)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 🎴 The Shareable Branded Card Preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF38106A),
                    const Color(0xFF190736),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: PremiumColors.electricBlue.withValues(alpha: 0.6),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 15),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: PremiumColors.premiumGold,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                            isJackpot ? '🎰 MEGA JACKPOT!' : '🎉 BIG WIN!',
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 10)),
                      ),
                      const Text('FORTUNE FIESTA',
                          style: TextStyle(
                              color: PremiumColors.textLightGrey,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Icon(Icons.auto_awesome,
                      color: PremiumColors.premiumGold, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    '+$winAmount COINS',
                    style: PremiumTypography.headingStyle.copyWith(
                        fontSize: 28, color: PremiumColors.premiumGold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'SPUN BY A LEGENDARY VIP',
                    style: PremiumTypography.captionSmall
                        .copyWith(color: Colors.white70, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars,
                            color: PremiumColors.electricBlue, size: 16),
                        const SizedBox(width: 8),
                        Text('TITLE: $title',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Share Reward Banner
            Obx(() {
              final canClaim = ShareManager.to.canClaimDailyShareReward.value;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: canClaim
                      ? PremiumColors.premiumGold.withValues(alpha: 0.15)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: canClaim
                          ? PremiumColors.premiumGold
                          : Colors.white24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_giftcard,
                        color: canClaim
                            ? PremiumColors.premiumGold
                            : Colors.white38,
                        size: 20),
                    const SizedBox(width: 10),
                    Text(
                      canClaim
                          ? 'Share now to claim +5,000 Coins!'
                          : 'Daily Share Reward claimed today.',
                      style: TextStyle(
                          color: canClaim
                              ? PremiumColors.premiumGold
                              : Colors.white60,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // Share Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildShareBtn(
                    context,
                    label: 'INSTAGRAM',
                    icon: Icons.camera_alt,
                    color: const Color(0xFFE040FB),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildShareBtn(
                    context,
                    label: 'WHATSAPP',
                    icon: Icons.chat_bubble,
                    color: const Color(0xFF00E676),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final claimed = await ShareManager.to.shareAndClaim(
                    title: 'General Share',
                    winAmount: winAmount,
                    isJackpot: isJackpot);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  if (claimed) {
                    Get.snackbar('VIRAL REWARD CLAIMED!',
                        '+5,000 Coins & +200 XP added to your balance!',
                        backgroundColor: PremiumColors.premiumGold,
                        colorText: Colors.black);
                  } else {
                    Get.snackbar(
                        'SHARED!', 'Thanks for sharing Fortune Fiesta!',
                        backgroundColor: PremiumColors.purpleGlass,
                        colorText: Colors.white);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PremiumColors.premiumGold,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.share, size: 20),
              label: const Text('SHARE & CLAIM REWARD',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareBtn(BuildContext context,
      {required String label, required IconData icon, required Color color}) {
    return ElevatedButton.icon(
      onPressed: () async {
        final claimed = await ShareManager.to.shareAndClaim(
            title: label, winAmount: winAmount, isJackpot: isJackpot);
        if (context.mounted) {
          Navigator.of(context).pop();
          if (claimed) {
            Get.snackbar('SHARED ON $label!', '+5,000 Coins reward added!',
                backgroundColor: color, colorText: Colors.black);
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: color)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
    );
  }
}
