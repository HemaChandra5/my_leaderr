import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class WelcomeHeading extends StatelessWidget {
  const WelcomeHeading({super.key, required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 1.2,
      letterSpacing: -0.2,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Our Voice.',
          textAlign: TextAlign.center,
          style: style.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 3),
        Text(
          'Our Leader.',
          textAlign: TextAlign.center,
          style: style.copyWith(color: AppColors.primaryGold),
        ),
        const SizedBox(height: 3),
        Text(
          'Our Community.',
          textAlign: TextAlign.center,
          style: style.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}