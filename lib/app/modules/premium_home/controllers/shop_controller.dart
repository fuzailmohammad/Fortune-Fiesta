import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/premium_home_controller.dart';
import 'package:fortune_fiesta/app/modules/premium_home/services/storage_service.dart';
import 'package:get/get.dart';

import '../../../../app/theme/animations/vfx_engine.dart';
import '../../../data/models/shop_model.dart';
import 'progression_controller.dart';

class ShopController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  static const String _purchasesKey = 'player_purchase_history';

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<PurchaseHistoryModel> purchaseHistory =
      <PurchaseHistoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _loadDefaultProducts();
  }

  void _loadData() {
    final savedPurchases = _storage.read<List<dynamic>>(_purchasesKey);
    if (savedPurchases != null) {
      purchaseHistory.value =
          savedPurchases.map((e) => PurchaseHistoryModel.fromJson(e)).toList();
    }
  }

  Future<void> _saveHistory() async {
    await _storage.write(
        _purchasesKey, purchaseHistory.map((e) => e.toJson()).toList());
  }

  void _loadDefaultProducts() {
    products.value = [
      // Starter Bundle
      ProductModel(
        id: 'bundle_starter',
        name: 'STARTER BUNDLE',
        description:
            'Includes 10,000 Coins, 500 Diamonds & exclusive Golden Frame!',
        type: ProductType.bundle,
        coinAmount: 10000,
        diamondAmount: 500,
        price: 1.99,
        discountLabel: '85% OFF',
        badge: 'limited',
      ),

      // Coin Packs
      ProductModel(
        id: 'coins_small',
        name: 'POUCH OF GOLD',
        description: 'A modest start for casual play.',
        type: ProductType.coins,
        coinAmount: 2000,
        diamondAmount: 0,
        price: 0.99,
      ),
      ProductModel(
        id: 'coins_medium',
        name: 'TREASURE BAG',
        description: 'Double the gold, double the fun.',
        type: ProductType.coins,
        coinAmount: 6000,
        diamondAmount: 0,
        price: 2.99,
        badge: 'most_popular',
      ),
      ProductModel(
        id: 'coins_large',
        name: 'VAULT OF COINS',
        description: 'Maximize your spin mileage.',
        type: ProductType.coins,
        coinAmount: 20000,
        diamondAmount: 0,
        price: 8.99,
        badge: 'best_value',
        isBestOffer: true,
      ),

      // Diamond Packs
      ProductModel(
        id: 'diamonds_small',
        name: 'CRYSTAL CLUSTER',
        description: 'Premium gems to boost missions.',
        type: ProductType.diamonds,
        coinAmount: 0,
        diamondAmount: 100,
        price: 1.99,
      ),
      ProductModel(
        id: 'diamonds_medium',
        name: 'DIAMOND VAULT',
        description: 'Highly valued treasure pack.',
        type: ProductType.diamonds,
        coinAmount: 0,
        diamondAmount: 450,
        price: 7.99,
        badge: 'most_popular',
      ),
      ProductModel(
        id: 'diamonds_large',
        name: 'GEM TYCOON',
        description: 'Uncapped diamond power.',
        type: ProductType.diamonds,
        coinAmount: 0,
        diamondAmount: 1500,
        price: 24.99,
        badge: 'best_value',
        isBestOffer: true,
      ),

      // VIP Pass
      ProductModel(
        id: 'vip_pass_monthly',
        name: 'VIP VAULT PASS',
        description:
            'Unlocks VIP badges, Golden names, and daily +2,000 Coins!',
        type: ProductType.vip,
        coinAmount: 5000,
        // Instant coin reward
        diamondAmount: 200,
        // Instant diamond reward
        price: 4.99,
        badge: 'hot',
      ),
    ];
  }

  // Simulated purchase verification order
  void buyProduct(ProductModel product) {
    final transactionId = 'TX_${DateTime.now().millisecondsSinceEpoch}';
    final purchase = PurchaseHistoryModel(
      id: transactionId,
      productId: product.id,
      pricePaid: product.price,
      timestamp: DateTime.now().toIso8601String(),
    );

    purchaseHistory.add(purchase);
    _saveHistory();

    // Delivery payloads
    _deliverPayload(product);

    // Trigger visual celebratory effects
    _triggerPurchaseVfx();

    // Show premium beveled success snackbar
    Get.snackbar(
      'PURCHASE SUCCESSFUL!',
      'Thank you! ${product.name} delivered to your wallet.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF00C853),
      // Success Green
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: const Color(0xFF00C853).withValues(alpha: 0.35),
          blurRadius: 12,
        ),
      ],
    );
  }

  void _deliverPayload(ProductModel product) {
    // 1. Deliver Coins safely
    if (product.coinAmount > 0) {
      try {
        final homeController = Get.find<PremiumHomeController>();
        homeController.coins.value += product.coinAmount;
      } catch (_) {}
    }

    // 2. Deliver Diamonds safely
    if (product.diamondAmount > 0) {
      try {
        final progController = Get.find<ProgressionController>();
        progController.profile.value = progController.profile.value.copyWith(
          diamonds:
              progController.profile.value.diamonds + product.diamondAmount,
        );
      } catch (_) {}
    }

    // 3. Deliver VIP cosmetic details
    if (product.type == ProductType.vip || product.id == 'bundle_starter') {
      try {
        final progController = Get.find<ProgressionController>();
        progController.profile.value = progController.profile.value.copyWith(
          avatarFrame: product.type == ProductType.vip ? 'vip' : 'gold',
        );
      } catch (_) {}
    }
  }

  void _triggerPurchaseVfx() {
    // Trigger screen-wide coin fountain bursts using our global VFX Engine
    final Offset center = Offset(
      Get.width / 2,
      Get.height * 0.45,
    );
    final Offset coinHudTarget = Offset(Get.width - 90, 42);

    VfxController.instance.playEffect(
      EffectPreset.coinBurst,
      center,
      endPoint: coinHudTarget,
    );

    VfxController.instance.playEffect(
      EffectPreset.sparkleSplash,
      center,
    );
  }
}
