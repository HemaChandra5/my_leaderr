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
      fontWeight: FontWeight.w700,
      height: 1.18,
      letterSpacing: -0.35,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Our Leader.',
          textAlign: TextAlign.center,
          style: style.copyWith(color: AppColors.white),
        ),
        Text(
          'Our Community.',
          textAlign: TextAlign.center,
          style: style.copyWith(color: AppColors.primaryGold),
        ),
        Text(
          'Our Future.',
          textAlign: TextAlign.center,
          style: style.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}
