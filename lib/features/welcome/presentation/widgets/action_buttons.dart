import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.onGetStarted,
    required this.onLogin,
    this.language = 'English',
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;
  final String language;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle primaryStyle = ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryGold,
      foregroundColor: AppColors.background,
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
    );

    final ButtonStyle secondaryStyle = OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryGold,
      side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton(
            onPressed: onGetStarted,
            style: primaryStyle,
            child: Text(AppLocalizations.translate('get_started', language: language)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: OutlinedButton(
            onPressed: onLogin,
            style: secondaryStyle,
            child: Text(AppLocalizations.translate('login', language: language)),
          ),
        ),
      ],
    );
  }
}
