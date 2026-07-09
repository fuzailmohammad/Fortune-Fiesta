import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

import '../../controllers/premium_home_controller.dart';

class BetControlBar extends StatefulWidget {
  const BetControlBar({super.key});

  @override
  State<BetControlBar> createState() => _BetControlBarState();
}

class _BetControlBarState extends State<BetControlBar> {
  Timer? _holdTimer;
  Timer? _periodicTimer;
  DateTime? _holdStartTime;

  void _startHoldIncrement() {
    final controller = Get.find<PremiumHomeController>();
    if (controller.isSpinning.value) return;

    // Single step first
    controller.increaseBet(100);

    _holdStartTime = DateTime.now();
    _holdTimer?.cancel();
    _periodicTimer?.cancel();

    _holdTimer = Timer(const Duration(milliseconds: 320), () {
      _periodicTimer = Timer.periodic(const Duration(milliseconds: 55), (_) {
        if (!mounted || controller.isSpinning.value) {
          _stopHold();
          return;
        }

        final heldDuration = DateTime.now().difference(_holdStartTime!);
        int step = 100;
        if (heldDuration.inSeconds >= 3) {
          step = 2500;
        } else if (heldDuration.inSeconds >= 2) {
          step = 1000;
        } else if (heldDuration.inSeconds >= 1) {
          step = 500;
        }

        controller.increaseBet(step);
      });
    });
  }

  void _startHoldDecrement() {
    final controller = Get.find<PremiumHomeController>();
    if (controller.isSpinning.value) return;

    // Single step first
    controller.decreaseBet(100);

    _holdStartTime = DateTime.now();
    _holdTimer?.cancel();
    _periodicTimer?.cancel();

    _holdTimer = Timer(const Duration(milliseconds: 320), () {
      _periodicTimer = Timer.periodic(const Duration(milliseconds: 55), (_) {
        if (!mounted || controller.isSpinning.value) {
          _stopHold();
          return;
        }

        final heldDuration = DateTime.now().difference(_holdStartTime!);
        int step = 100;
        if (heldDuration.inSeconds >= 3) {
          step = 2500;
        } else if (heldDuration.inSeconds >= 2) {
          step = 1000;
        } else if (heldDuration.inSeconds >= 1) {
          step = 500;
        }

        controller.decreaseBet(step);
      });
    });
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _periodicTimer?.cancel();
    _holdTimer = null;
    _periodicTimer = null;
  }

  @override
  void dispose() {
    _stopHold();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PremiumHomeController>();

    return Obx(() {
      final int bet = controller.currentBet.value;
      final int maxCoins = controller.coins.value;
      final bool isSpinning = controller.isSpinning.value;
      final bool isMax = bet >= maxCoins && maxCoins > 0;

      return Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF140E26).withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isMax
                ? PremiumColors.premiumGold
                : Colors.white.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            if (isMax)
              BoxShadow(
                color: PremiumColors.premiumGold.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // MINUS BUTTON (HOLD TO CONTINUOUSLY DECREASE)
            GestureDetector(
              onTapDown: (_) => _startHoldDecrement(),
              onTapUp: (_) => _stopHold(),
              onTapCancel: () => _stopHold(),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: isSpinning || bet <= 100 ? 0.4 : 1.0,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2), width: 1),
                  ),
                  child: const Icon(
                    Icons.remove_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // BET AMOUNT DISPLAY
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isMax ? 'ALL IN BET' : 'SPIN BET',
                      style: TextStyle(
                        color: isMax
                            ? PremiumColors.premiumGold
                            : Colors.white60,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.monetization_on_rounded,
                          color: PremiumColors.premiumGold,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$bet',
                          style: TextStyle(
                            color: isMax
                                ? PremiumColors.premiumGold
                                : Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // PLUS BUTTON (HOLD TO CONTINUOUSLY INCREASE UP TO ALL)
            GestureDetector(
              onTapDown: (_) => _startHoldIncrement(),
              onTapUp: (_) => _stopHold(),
              onTapCancel: () => _stopHold(),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: isSpinning || bet >= maxCoins ? 0.4 : 1.0,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        PremiumColors.premiumGold.withValues(alpha: 0.35),
                        PremiumColors.premiumGold.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: PremiumColors.premiumGold.withValues(alpha: 0.7),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: PremiumColors.premiumGold,
                    size: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // MAX BUTTON (ALL IN)
            GestureDetector(
              onTap: isSpinning ? null : controller.setMaxBet,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: isSpinning ? 0.4 : 1.0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: isMax
                        ? const LinearGradient(
                            colors: [
                              PremiumColors.premiumGold,
                              Color(0xFFFFA000)
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.12),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                          ),
                    border: Border.all(
                      color: isMax
                          ? PremiumColors.premiumGold
                          : Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    'MAX',
                    style: TextStyle(
                      color: isMax ? Colors.black : Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
