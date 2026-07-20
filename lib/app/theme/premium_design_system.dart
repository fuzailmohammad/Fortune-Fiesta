import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Color System Design Tokens
class PremiumColors {
  PremiumColors._();

  static const Color royalPurple = Color(0xFF6A1B9A);
  static const Color deepViolet = Color(0xFF4A148C);
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color goldMetallic = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFF69A);

  static const Color electricBlue = Color(0xFF00E5FF);
  static const Color neonCyan = Color(0xFF00FFF0);
  static const Color successGreen = Color(0xFF00C853);
  static const Color dangerRed = Color(0xFFFF1744);

  static const Color richBlack = Color(0xFF07050F);
  static const Color purpleGlass = Color(0xFF140F27);

  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textLightGrey = Color(0xFFD1CFE2);
  static const Color textMutedGrey = Color(0xFF8E8B9F);
}

// 2. Gradients System
class PremiumGradients {
  PremiumGradients._();

  static const LinearGradient gold = LinearGradient(
    colors: [
      PremiumColors.goldLight,
      PremiumColors.premiumGold,
      PremiumColors.goldMetallic
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient purple = LinearGradient(
    colors: [PremiumColors.royalPurple, Color(0xFF2C0B53)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient neonBlue = LinearGradient(
    colors: [PremiumColors.electricBlue, Color(0xFF00B0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient glass = LinearGradient(
    colors: [
      PremiumColors.purpleGlass.withValues(alpha: 0.85),
      PremiumColors.richBlack.withValues(alpha: 0.85),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient glassHighlight = LinearGradient(
    colors: [
      Colors.white.withValues(alpha: 0.12),
      Colors.white.withValues(alpha: 0.0),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// 3. Typography System
class PremiumTypography {
  PremiumTypography._();

  static TextStyle get displayLarge => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: PremiumColors.textWhite,
        letterSpacing: 1.0,
      );

  static TextStyle get headlineMedium => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: PremiumColors.premiumGold,
        letterSpacing: 1.2,
      );

  static TextStyle get titleLarge => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: PremiumColors.textWhite,
      );

  static TextStyle get bodyLarge => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: PremiumColors.textLightGrey,
      );

  static TextStyle get captionSmall => GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: PremiumColors.textMutedGrey,
      );

  static TextStyle get numbersStyle => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      );

  // Aliases for layout convenience
  static TextStyle get headingStyle => displayLarge;
  static TextStyle get subHeadingStyle => titleLarge;
  static TextStyle get bodyStyle => bodyLarge;
}

// 4. Reusable Card
class PremiumCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color borderColor;
  final double borderWidth;

  const PremiumCard({
    super.key,
    required this.child,
    this.radius = 20,
    this.borderColor = const Color(0xFF6A1B9A),
    this.borderWidth = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: PremiumGradients.glass,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.35),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - borderWidth),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: child,
        ),
      ),
    );
  }
}

// 5. Reusable Button
class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Gradient gradient;
  final Color textColor;
  final IconData? icon;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient = PremiumGradients.gold,
    this.textColor = PremiumColors.richBlack,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: gradient,
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 6. Reusable Badges
enum BadgeType { newBadge, free, vip, hot, limited, claim, sale }

class PremiumBadge extends StatelessWidget {
  final BadgeType type;

  const PremiumBadge({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getBadgeConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: config.gradient,
        borderRadius: BorderRadius.circular(6),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.4), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: config.color.withValues(alpha: 0.3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        type.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  _BadgeConfig _getBadgeConfig() {
    switch (type) {
      case BadgeType.newBadge:
        return _BadgeConfig(
          color: PremiumColors.electricBlue,
          gradient: PremiumGradients.neonBlue,
        );
      case BadgeType.free:
        return _BadgeConfig(
          color: PremiumColors.electricBlue,
          gradient: PremiumGradients.neonBlue,
        );
      case BadgeType.vip:
        return _BadgeConfig(
          color: PremiumColors.premiumGold,
          gradient: PremiumGradients.gold,
        );
      case BadgeType.hot:
      case BadgeType.sale:
      case BadgeType.limited:
      case BadgeType.claim:
        return _BadgeConfig(
          color: PremiumColors.dangerRed,
          gradient: const LinearGradient(
            colors: [PremiumColors.dangerRed, Color(0xFFC62828)],
          ),
        );
    }
  }
}

class _BadgeConfig {
  final Color color;
  final Gradient gradient;

  _BadgeConfig({required this.color, required this.gradient});
}

// 7. Reusable Chips
enum ChipSize { small, medium, large }

class PremiumChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final ChipSize size;

  const PremiumChip({
    super.key,
    required this.label,
    required this.icon,
    this.color = PremiumColors.premiumGold,
    this.size = ChipSize.medium,
  });


  @override
  Widget build(BuildContext context) {
    final double height =
        size == ChipSize.small ? 22 : (size == ChipSize.medium ? 28 : 34);
    final double fontSize =
        size == ChipSize.small ? 9 : (size == ChipSize.medium ? 11 : 13);
    final double iconSize =
        size == ChipSize.small ? 10 : (size == ChipSize.medium ? 12 : 14);

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: PremiumColors.richBlack.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: iconSize),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// 8. Reusable Dividers
enum DividerType { goldLine, glowLine, gem }

class PremiumDivider extends StatelessWidget {
  final DividerType type;

  const PremiumDivider({
    super.key,
    this.type = DividerType.glowLine,
  });

  @override
  Widget build(BuildContext context) {
    if (type == DividerType.gem) {
      return Row(
        children: [
          const Expanded(child: PremiumDivider(type: DividerType.goldLine)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Transform.rotate(
              angle: 3.14159 / 4,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  gradient: PremiumGradients.gold,
                ),
              ),
            ),
          ),
          const Expanded(child: PremiumDivider(type: DividerType.goldLine)),
        ],
      );
    }

    final isGold = type == DividerType.goldLine;
    return Container(
      height: 1.5,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isGold
            ? PremiumGradients.gold
            : const LinearGradient(colors: [
                Colors.transparent,
                PremiumColors.electricBlue,
                Colors.transparent
              ]),
        boxShadow: [
          if (!isGold)
            BoxShadow(
              color: PremiumColors.electricBlue.withValues(alpha: 0.5),
              blurRadius: 4,
              spreadRadius: 0.5,
            ),
        ],
      ),
    );
  }
}

// 9. Reusable Loading Spinners
class PremiumLoader extends StatelessWidget {
  const PremiumLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PremiumColors.purpleGlass,
        shape: BoxShape.circle,
        border: Border.all(
            color: PremiumColors.royalPurple.withValues(alpha: 0.3),
            width: 1.5),
      ),
      child: const CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(PremiumColors.premiumGold),
      ),
    );
  }
}

// 10. Reusable Empty State Widget
class PremiumEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String ctaText;
  final VoidCallback onCtaPressed;

  const PremiumEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.ctaText,
    required this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PremiumColors.purpleGlass.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_empty_rounded,
                color: PremiumColors.textMutedGrey,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: PremiumTypography.titleLarge
                  .copyWith(color: PremiumColors.premiumGold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: PremiumTypography.bodyLarge
                  .copyWith(color: PremiumColors.textMutedGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PremiumButton(
              text: ctaText,
              onPressed: onCtaPressed,
            ),
          ],
        ),
      ),
    );
  }
}

// 11. Reusable Error State Widget
class PremiumErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PremiumErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PremiumColors.dangerRed.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: PremiumColors.dangerRed,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'OOF! CONNECTION LOSS',
              style: TextStyle(
                color: PremiumColors.dangerRed,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: PremiumTypography.bodyLarge
                  .copyWith(color: PremiumColors.textMutedGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PremiumButton(
              text: 'RETRY',
              onPressed: onRetry,
              gradient: const LinearGradient(
                colors: [PremiumColors.dangerRed, Color(0xFFC62828)],
              ),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
