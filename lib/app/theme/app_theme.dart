import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/app_colors.dart';

class AppTheme {
  static final theme = ThemeData(
    fontFamily: 'lobster',
    appBarTheme: const AppBarTheme(
      color: AppColors.purpleRoyal
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: AppColors.purpleRoyal,
      secondary: AppColors.orangeExuberantCoral,
    ),
  );
}
