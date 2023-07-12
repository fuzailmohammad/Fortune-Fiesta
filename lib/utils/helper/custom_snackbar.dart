import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/app_colors.dart';
import 'package:fortune_fiesta/app/theme/styles.dart';
import 'package:get/get.dart';

void showCustomSnackbar(String title, String message, Color color) {
  Get.snackbar(
    title,
    message,
    snackPosition: kIsWeb ? SnackPosition.TOP : SnackPosition.BOTTOM,
    backgroundColor: color,
    colorText: AppColors.white,
    borderRadius: 12,
    margin: const EdgeInsets.all(10),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 300),
    isDismissible: true,
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeInBack,
    overlayColor: Colors.black87.withOpacity(0.7),
    overlayBlur: 3,
    icon: const Icon(
      Icons.error,
      color: Colors.white,
    ),
    shouldIconPulse: true,
    maxWidth: 500,
    snackStyle: SnackStyle.FLOATING,
    titleText: Text(
      title,
      style: Styles.tsWhiteRegular18,
    ),
    messageText: Text(
      message,
      style: Styles.tsWhiteRegular16,
    ),
  );
}
