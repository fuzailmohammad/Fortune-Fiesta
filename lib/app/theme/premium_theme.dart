import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'premium_design_system.dart';

class PremiumTheme {
  PremiumTheme._();

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark(useMaterial3: true);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: PremiumColors.richBlack,
      primaryColor: PremiumColors.royalPurple,
      colorScheme: const ColorScheme.dark(
        primary: PremiumColors.royalPurple,
        secondary: PremiumColors.premiumGold,
        tertiary: PremiumColors.electricBlue,
        surface: PremiumColors.purpleGlass,
        error: PremiumColors.dangerRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: PremiumColors.textWhite,
          shadows: [
            const Shadow(
              blurRadius: 10.0,
              color: PremiumColors.electricBlue,
              offset: Offset(0, 0),
            ),
          ],
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: PremiumColors.premiumGold,
          letterSpacing: 1.2,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 14,
          color: PremiumColors.textWhite,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 12,
          color: PremiumColors.textLightGrey,
        ),
      ),
      cardTheme: CardThemeData(
        color: PremiumColors.purpleGlass,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: PremiumColors.royalPurple, width: 1.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: PremiumColors.premiumGold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
