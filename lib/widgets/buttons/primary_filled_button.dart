import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/app_colors.dart';
import 'package:fortune_fiesta/app/theme/styles.dart';

class PrimaryFilledButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const PrimaryFilledButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      color: AppColors.purpleRoyal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          text,
          style: Styles.tsWhiteRegular18,
        ),
      ),
    );
  }
}
