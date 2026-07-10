import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class WelcomeHeading extends StatelessWidget {
  const WelcomeHeading({
    super.key,
    required this.fontSize,
    required this.line1,
    required this.line2,
    required this.line3,
  });

  final double fontSize;
  final String line1;
  final String line2;
  final String line3;

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
          line1,
          textAlign: TextAlign.center,
          style: style.copyWith(color: AppColors.white),
        ),
        Text(
          line2,
          textAlign: TextAlign.center,
          style: style.copyWith(color: AppColors.primaryGold),
        ),
        Text(
          line3,
          textAlign: TextAlign.center,
          style: style.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}
