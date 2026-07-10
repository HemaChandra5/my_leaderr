import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class WelcomeHeading extends StatelessWidget {
  const WelcomeHeading({super.key, required this.fontSize, this.language = 'English'});

  final double fontSize;
  final String language;

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
          AppLocalizations.translate('our_leader', language: language),
          textAlign: TextAlign.center,
          style: style.copyWith(color: AppColors.white),
        ),
        Text(
          AppLocalizations.translate('our_community', language: language),
          textAlign: TextAlign.center,
          style: style.copyWith(color: AppColors.primaryGold),
        ),
        Text(
          AppLocalizations.translate('our_future', language: language),
          textAlign: TextAlign.center,
          style: style.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}
