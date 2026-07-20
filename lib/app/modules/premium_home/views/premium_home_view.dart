import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/data/models/audio_model.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/player_mood_controller.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/timeline_controller.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/views/adaptive_hud_overlay.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/views/memorable_moment_overlay.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/views/welcome_back_dialog.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/audio_controller.dart';
import 'package:fortune_fiesta/app/theme/animations/vfx_engine.dart';
import 'package:get/get.dart';

import '../controllers/premium_home_controller.dart';
import 'widgets/ambient_juice_canvas.dart';
import 'widgets/animated_background.dart';
import 'widgets/bottom_action_dock.dart';
import 'widgets/contextual_action_chip.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/double_reward_dialog.dart';
import 'widgets/slot_machine.dart';
import 'widgets/spin_button.dart';
import 'widgets/bet_control_bar.dart';
import 'widgets/win_celebration_overlay.dart';

class PremiumHomeView extends StatefulWidget {
  const PremiumHomeView({super.key});

  @override
  State<PremiumHomeView> createState() => _PremiumHomeViewState();
}

class _PremiumHomeViewState extends State<PremiumHomeView> {
  final PremiumHomeController controller = Get.find<PremiumHomeController>();

  int _coinsBeforeSpin = 0;
  int _activeCelebrationAmount = 0;
  bool _showCelebration = false;
  bool _wasSpinning = false;
  Timer? _stopTimer;
  Worker? _spinWorker;

  @override
  void initState() {
    super.initState();
    _coinsBeforeSpin = controller.coins.value;

    // React to spin state changes outside the build cycle
    _spinWorker = ever<bool>(controller.isSpinning, _onSpinStateChanged);
  }

  void _onSpinStateChanged(bool isSpinning) {
    if (isSpinning && !_wasSpinning) {
      _wasSpinning = true;
      _coinsBeforeSpin = controller.coins.value;
    } else if (!isSpinning && _wasSpinning) {
      _wasSpinning = false;
      _stopTimer?.cancel();
      _stopTimer = Timer(const Duration(milliseconds: 550), () {
        if (!mounted) return;
        final int currentCoins = controller.coins.value;
        final int win = currentCoins > _coinsBeforeSpin
            ? currentCoins - _coinsBeforeSpin
            : 0;
        if (Get.isRegistered<PlayerMoodController>()) {
          PlayerMoodController.to.recordSpin(isWin: win > 0, winAmount: win);
        }
        if (Get.isRegistered<TimelineController>()) {
          if (controller.totalSpins.value >= 100) {
            TimelineController.to.checkAndUnlockMilestone('ms_100_spins');
          }
          if (controller.totalSpins.value >= 1000) {
            TimelineController.to.checkAndUnlockMilestone('ms_1000_spins');
          }
        }

        if (win > 0) {
          if (Get.isRegistered<AudioController>()) {
            final audio = Get.find<AudioController>();
            if (win >= 500) {
              audio.triggerHaptic(HapticProfile.celebration);
              audio.playEvent(AudioEvent.jackpot);
            } else {
              audio.triggerHaptic(HapticProfile.success);
              audio.playEvent(AudioEvent.coinBurst);
            }
          }

          Get.closeAllSnackbars();
          showDialog(
            context: context,
            barrierColor: Colors.black87.withValues(alpha: 0.85),
            barrierDismissible: false,
            builder: (dialogCtx) => DoubleRewardDialog(
              baseAmount: win,
              rewardType: 'coins',
              onDouble: () {
                if (mounted) {
                  Navigator.of(dialogCtx).pop();
                  controller.coins.value += win;
                  setState(() {
                    _activeCelebrationAmount = win * 2;
                    _showCelebration = true;
                  });
                }
              },
              onCollectNormally: () {
                if (mounted) {
                  Navigator.of(dialogCtx).pop();
                  setState(() {
                    _activeCelebrationAmount = win;
                    _showCelebration = true;
                  });
                }
              },
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _spinWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VfxOverlay(
      child: Stack(
        children: [
          // 1. Base Game UI Layout
          Obx(() {
            final bool isSpinning = controller.isSpinning.value;

            return AnimatedBackground(
              isSpinning: isSpinning,
              child: SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: const PreferredSize(
                    preferredSize: Size.fromHeight(72),
                    child: CustomAppBar(),
                  ),
                  body: _buildUnifiedHeroLayout(),
                  bottomNavigationBar: const SafeArea(
                    child: BottomActionDock(),
                  ),
                ),
              ),
            );
          }),

          // 2. Cinematic Celebration Overlay
          if (_showCelebration)
            WinCelebrationOverlay(
              winAmount: _activeCelebrationAmount,
              onFinished: () {
                if (mounted) {
                  setState(() {
                    _showCelebration = false;
                  });
                }
              },
            ),

          // 3. Adaptive Experience HUD
          const Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: AdaptiveHudOverlay(),
          ),

          // 4. Modal Overlays (above everything except ambient)
          const WelcomeBackDialog(),
          const MemorableMomentOverlay(),

          // 5. Ambient Juice Canvas (topmost, non-interactive)
          const AmbientJuiceCanvas(),
        ],
      ),
    );
  }

  // Unified Minimal AAA Layout (Hero Slot Machine)
  Widget _buildUnifiedHeroLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  const SlotMachine(),
                  const SizedBox(height: 18),
                  const BetControlBar(),
                  const SizedBox(height: 14),
                  const SpinSection(),
                  const SizedBox(height: 16),
                  const ContextualActionChip(),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
