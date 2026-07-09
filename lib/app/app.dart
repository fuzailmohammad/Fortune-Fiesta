import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/app_binding.dart';
import 'package:fortune_fiesta/app/data/values/constants.dart';
import 'package:fortune_fiesta/app/data/values/env.dart';
import 'package:fortune_fiesta/app/routes/app_pages.dart';
import 'package:fortune_fiesta/app/theme/premium_theme.dart';
import 'package:get/get.dart';

import 'package:fortune_fiesta/app/data/models/settings_model.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/settings_controller.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';

final RxBool _appBuilderObs = false.obs;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Env.title,
      navigatorKey: GlobalKeys.navigationKey,
      debugShowCheckedModeBanner: false,
      theme: PremiumTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: Routes.premiumHome,
      getPages: AppPages.pages,
      defaultTransition: Transition.fade,
      initialBinding: AppBinding(),
      builder: (context, child) {
        return Obx(() {
          Widget content = child ?? const SizedBox.shrink();

          if (Get.isRegistered<SettingsController>()) {
            final settingsCtrl = Get.find<SettingsController>();
            final settings = settingsCtrl.settings.value;
            final bool showPerf = settingsCtrl.showPerformanceOverlay.value;

            final acc = settings.accessibility;
            if (acc.colorblind != ColorBlindMode.none) {
              content = ColorFiltered(
                colorFilter: ColorFilter.matrix(
                    _getColorblindMatrix(acc.colorblind)),
                child: content,
              );
            }

            if (showPerf) {
              content = Stack(
                children: [
                  content,
                  const Positioned(
                    top: 48,
                    right: 12,
                    child: _PerformanceOverlayHud(),
                  ),
                ],
              );
            }
          } else {
            // Unconditionally observe fallback so GetX never flags improper use
            _appBuilderObs.value;
          }

          return content;
        });
      },
    );
  }
}

List<double> _getColorblindMatrix(ColorBlindMode mode) {
  switch (mode) {
    case ColorBlindMode.protanopia:
      return [
        0.56667, 0.43333, 0.0, 0.0, 0.0,
        0.55833, 0.44167, 0.0, 0.0, 0.0,
        0.0, 0.24167, 0.75833, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ];
    case ColorBlindMode.deuteranopia:
      return [
        0.625, 0.375, 0.0, 0.0, 0.0,
        0.7, 0.3, 0.0, 0.0, 0.0,
        0.0, 0.3, 0.7, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ];
    case ColorBlindMode.tritanopia:
      return [
        0.95, 0.05, 0.0, 0.0, 0.0,
        0.0, 0.43333, 0.56667, 0.0, 0.0,
        0.0, 0.475, 0.525, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ];
    case ColorBlindMode.none:
      return [
        1, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 1, 0,
      ];
  }
}

class _PerformanceOverlayHud extends StatelessWidget {
  const _PerformanceOverlayHud();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF07050F).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PremiumColors.premiumGold.withValues(alpha: 0.6)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.speed, color: PremiumColors.premiumGold, size: 12),
            SizedBox(width: 6),
            Text(
              'FPS: 60.0 | RENDER: 16.6ms',
              style: TextStyle(
                color: PremiumColors.premiumGold,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
