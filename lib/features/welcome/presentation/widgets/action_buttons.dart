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
    this.minHeight = 56,
    this.fontSize = 18,
    this.borderRadius = 12,
    this.gap = 14,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;
  final String language;
  final double minHeight;
  final double fontSize;
  final double borderRadius;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _PremiumButton(
            label: AppLocalizations.translate(
              'get_started',
              language: language,
            ),
            onPressed: onGetStarted,
            filled: true,
            minHeight: minHeight,
            fontSize: fontSize,
            borderRadius: borderRadius,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _PremiumButton(
            label: AppLocalizations.translate('login', language: language),
            onPressed: onLogin,
            filled: false,
            minHeight: minHeight,
            fontSize: fontSize,
            borderRadius: borderRadius,
          ),
        ),
      ],
    );
  }
}

class _PremiumButton extends StatefulWidget {
  const _PremiumButton({
    required this.label,
    required this.onPressed,
    required this.filled,
    required this.minHeight,
    required this.fontSize,
    required this.borderRadius,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final double minHeight;
  final double fontSize;
  final double borderRadius;

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = GoogleFonts.inter(
      fontSize: widget.fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
      },
      onTap: widget.onPressed,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: BoxConstraints(minHeight: widget.minHeight),
          decoration: BoxDecoration(
            color: widget.filled ? AppColors.primaryGold : Colors.transparent,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.filled
                ? null
                : Border.all(color: AppColors.primaryGold, width: 1),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: textStyle.copyWith(
                color: widget.filled ? AppColors.onGold : AppColors.primaryGold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
