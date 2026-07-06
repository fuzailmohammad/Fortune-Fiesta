import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/animations/glow_effects.dart';
import 'package:fortune_fiesta/app/theme/animations/press_effect.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../../data/models/shop_model.dart';
import '../controllers/progression_controller.dart';
import '../controllers/shop_controller.dart';

class ShopDashboardScreen extends StatelessWidget {
  const ShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put ShopController lazily if not present
    final controller = Get.put(ShopController());
    final progController = Get.find<ProgressionController>();

    return Scaffold(
      backgroundColor: const Color(0xFF07050F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF140F27),
        title: const Text(
          'TREASURE VAULT',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. VIP Wallet Overview Header
              _buildWalletHeader(progController),

              const SizedBox(height: 24),

              // 2. Starter Bundle (Hero banner)
              const Text(
                'EXCLUSIVE STARTER OFFER',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              _buildStarterBundleCard(controller),

              const SizedBox(height: 24),

              // 3. Coin Packs Grid
              const Text(
                'GOLD COIN PACKS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              _buildProductsGrid(controller, ProductType.coins),

              const SizedBox(height: 24),

              // 4. Diamond Packs Grid
              const Text(
                'CRYSTAL GEMS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              _buildProductsGrid(controller, ProductType.diamonds),

              const SizedBox(height: 24),

              // 5. VIP Vault Pass Card
              const Text(
                'VIP MEMBERSHIP',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              _buildVipPassCard(controller),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletHeader(ProgressionController progController) {
    return Obx(() {
      final profile = progController.profile.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PremiumColors.purpleGlass.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: PremiumColors.royalPurple.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildWalletStat(Icons.workspace_premium_rounded, 'VIP FRAME',
                profile.avatarFrame.toUpperCase(), PremiumColors.premiumGold),
            Container(width: 1, height: 32, color: Colors.white10),
            _buildWalletStat(Icons.diamond_rounded, 'DIAMONDS',
                '${profile.diamonds}', PremiumColors.neonCyan),
            Container(width: 1, height: 32, color: Colors.white10),
            _buildWalletStat(Icons.local_fire_department, 'STREAK',
                '${profile.streak} Days', Colors.orange),
          ],
        ),
      );
    });
  }

  Widget _buildWalletStat(
      IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white30,
                fontSize: 8,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildStarterBundleCard(ShopController controller) {
    final starter = controller.products
        .firstWhereOrNull((p) => p.type == ProductType.bundle);
    if (starter == null) return const SizedBox.shrink();

    return GlowingEffect(
      glowColor: PremiumColors.premiumGold,
      maxSpread: 8.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E1C0C), Color(0xFF140F27)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: PremiumColors.premiumGold, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: PremiumColors.dangerRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    starter.discountLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                const Text(
                  'FIRST PURCHASE ONLY',
                  style: TextStyle(
                      color: PremiumColors.premiumGold,
                      fontSize: 10,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              starter.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0),
            ),
            const SizedBox(height: 4),
            Text(
              starter.description,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
            ),
            const SizedBox(height: 16),

            // Payload list item previews
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBundlePayloadItem(
                    Icons.monetization_on_rounded, '+10K', 'COINS'),
                _buildBundlePayloadItem(Icons.diamond_rounded, '+500', 'GEMS'),
                _buildBundlePayloadItem(
                    Icons.workspace_premium_rounded, 'GOLD', 'FRAME'),
              ],
            ),

            const SizedBox(height: 18),

            // Buy Button
            TactilePressEffect(
              onPressed: () => controller.buyProduct(starter),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: PremiumGradients.gold,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color:
                            PremiumColors.premiumGold.withValues(alpha: 0.35),
                        blurRadius: 10),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'CLAIM NOW - \$${starter.price}',
                  style: const TextStyle(
                      color: PremiumColors.richBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBundlePayloadItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.black38, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: PremiumColors.premiumGold, size: 24),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 8,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProductsGrid(ShopController controller, ProductType filterType) {
    final list =
        controller.products.where((p) => p.type == filterType).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final product = list[index];
        final bool isCoins = filterType == ProductType.coins;
        final bool hasBadge = product.badge.isNotEmpty;

        Widget card = Container(
          decoration: BoxDecoration(
            color: PremiumColors.purpleGlass.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: product.isBestOffer
                  ? PremiumColors.premiumGold
                  : isCoins
                      ? PremiumColors.royalPurple.withValues(alpha: 0.2)
                      : PremiumColors.neonCyan.withValues(alpha: 0.3),
              width: product.isBestOffer ? 1.5 : 1.0,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge
              if (hasBadge)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: product.badge == 'best_value'
                        ? PremiumColors.successGreen
                        : PremiumColors.electricBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.badge.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold),
                  ),
                )
              else
                const SizedBox(height: 12),

              // Illustration Icon
              Icon(
                isCoins ? Icons.monetization_on_rounded : Icons.diamond_rounded,
                color: isCoins
                    ? PremiumColors.premiumGold
                    : PremiumColors.neonCyan,
                size: 32,
              ),

              // Details
              Column(
                children: [
                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCoins
                        ? '${product.coinAmount}'
                        : '${product.diamondAmount}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),

              // Button Buy Price
              TactilePressEffect(
                onPressed: () => controller.buyProduct(product),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: isCoins
                        ? PremiumGradients.gold
                        : const LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF0060B7)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '\$${product.price}',
                    style: TextStyle(
                      color: isCoins ? PremiumColors.richBlack : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        if (product.isBestOffer) {
          card = GlowingEffect(
            glowColor:
                isCoins ? PremiumColors.premiumGold : PremiumColors.neonCyan,
            maxSpread: 6.0,
            child: card,
          );
        }

        return card;
      },
    );
  }

  Widget _buildVipPassCard(ShopController controller) {
    final vip =
        controller.products.firstWhereOrNull((p) => p.type == ProductType.vip);
    if (vip == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B0C2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE040FB), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFE040FB).withValues(alpha: 0.12),
              blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      color: Color(0xFFE040FB), size: 24),
                  SizedBox(width: 8),
                  Text(
                    'VIP VAULT MEMBERSHIP',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFFE040FB),
                    borderRadius: BorderRadius.circular(6)),
                child: const Text('MONTHLY',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            vip.description,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
          ),
          const SizedBox(height: 16),

          // VIP Benefits checklist
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildVipBenefitItem(
                  Icons.monetization_on_outlined, '+2,000/day'),
              _buildVipBenefitItem(Icons.diamond_outlined, '+50/day'),
              _buildVipBenefitItem(Icons.star_outline_rounded, 'VIP Badges'),
            ],
          ),

          const SizedBox(height: 18),

          // Buy button
          TactilePressEffect(
            onPressed: () => controller.buyProduct(vip),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFE040FB), Color(0xFF6A1B9A)]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFFE040FB).withValues(alpha: 0.3),
                      blurRadius: 8),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'UNLOX VIP PASS - \$${vip.price} / Month',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVipBenefitItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE040FB), size: 14),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
