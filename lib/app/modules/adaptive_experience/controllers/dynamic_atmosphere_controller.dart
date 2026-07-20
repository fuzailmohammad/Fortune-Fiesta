import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/data/models/adaptive_experience_model.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

class DynamicAtmosphereController extends GetxService {
  static DynamicAtmosphereController get to => Get.find();

  final currentAtmosphere = AtmosphereMode.day.obs;
  final atmosphereTitle = '☀️ CELEBRATION DAY'.obs;
  final backgroundGradientColors = <Color>[
    const Color(0xFF1B073A),
    const Color(0xFF100326),
    const Color(0xFF070014),
  ].obs;

  final showConfettiDecorations = false.obs;
  final isFestivalOverride = false.obs;
  final festivalName = 'FIESTA ANNIVERSARY'.obs;

  Timer? _clockTimer;

  @override
  void onInit() {
    super.onInit();
    _evaluateTimeAndCalendar();
    // Check clock every minute
    _clockTimer = Timer.periodic(
        const Duration(minutes: 1), (_) => _evaluateTimeAndCalendar());
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    super.onClose();
  }

  void _evaluateTimeAndCalendar() {
    if (isFestivalOverride.value) {
      _applyFestivalMode();
      return;
    }

    final now = DateTime.now();
    final int hour = now.hour;
    final int weekday = now.weekday;

    // Check Weekend Celebration Decor
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      showConfettiDecorations.value = true;
      currentAtmosphere.value = AtmosphereMode.weekend;
      atmosphereTitle.value = '🎉 WEEKEND CELEBRATION!';
      backgroundGradientColors.value = [
        const Color(0xFF2D0A4E),
        const Color(0xFF1A0536),
        const Color(0xFF0F0220),
      ];
      return;
    } else {
      showConfettiDecorations.value = false;
    }

    // Time-of-Day Lighting
    if (hour >= 6 && hour < 11) {
      currentAtmosphere.value = AtmosphereMode.morning;
      atmosphereTitle.value = '🌅 WARM SUNRISE FIESTA';
      backgroundGradientColors.value = [
        const Color(0xFF3E1F00),
        const Color(0xFF280B14),
        const Color(0xFF19041E),
      ];
    } else if (hour >= 18 || hour < 6) {
      currentAtmosphere.value = AtmosphereMode.night;
      atmosphereTitle.value = '🌌 MIDNIGHT CYBER VAULT';
      backgroundGradientColors.value = [
        const Color(0xFF050B1E),
        const Color(0xFF030614),
        const Color(0xFF01020A),
      ];
    } else {
      currentAtmosphere.value = AtmosphereMode.day;
      atmosphereTitle.value = '☀️ CELEBRATION DAY';
      backgroundGradientColors.value = [
        const Color(0xFF1B073A),
        const Color(0xFF100326),
        const Color(0xFF070014),
      ];
    }
  }

  void _applyFestivalMode() {
    currentAtmosphere.value = AtmosphereMode.festival;
    atmosphereTitle.value = '🎪 ${festivalName.value.toUpperCase()}';
    showConfettiDecorations.value = true;
    backgroundGradientColors.value = [
      PremiumColors.royalPurple,
      const Color(0xFF2B0A42),
      const Color(0xFF120320),
    ];
  }

  void setFestivalOverride(bool enable, [String name = 'FIESTA ANNIVERSARY']) {
    isFestivalOverride.value = enable;
    festivalName.value = name;
    _evaluateTimeAndCalendar();
  }

  void simulateAtmosphere(AtmosphereMode mode) {
    isFestivalOverride.value = false;
    currentAtmosphere.value = mode;
    switch (mode) {
      case AtmosphereMode.morning:
        atmosphereTitle.value = '🌅 WARM SUNRISE FIESTA';
        backgroundGradientColors.value = [
          const Color(0xFF3E1F00),
          const Color(0xFF280B14),
          const Color(0xFF19041E),
        ];
        showConfettiDecorations.value = false;
        break;
      case AtmosphereMode.day:
        atmosphereTitle.value = '☀️ CELEBRATION DAY';
        backgroundGradientColors.value = [
          const Color(0xFF1B073A),
          const Color(0xFF100326),
          const Color(0xFF070014),
        ];
        showConfettiDecorations.value = false;
        break;
      case AtmosphereMode.night:
        atmosphereTitle.value = '🌌 MIDNIGHT CYBER VAULT';
        backgroundGradientColors.value = [
          const Color(0xFF050B1E),
          const Color(0xFF030614),
          const Color(0xFF01020A),
        ];
        showConfettiDecorations.value = false;
        break;
      case AtmosphereMode.weekend:
        atmosphereTitle.value = '🎉 WEEKEND CELEBRATION!';
        backgroundGradientColors.value = [
          const Color(0xFF2D0A4E),
          const Color(0xFF1A0536),
          const Color(0xFF0F0220),
        ];
        showConfettiDecorations.value = true;
        break;
      case AtmosphereMode.festival:
        setFestivalOverride(true, 'ANNIVERSARY CARNIVAL');
        break;
    }
  }
}
