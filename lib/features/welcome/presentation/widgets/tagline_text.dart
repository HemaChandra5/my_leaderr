import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class TaglineText extends StatelessWidget {
  const TaglineText({
    super.key,
    required this.text,
    required this.fontSize,
    this.color = AppColors.white,
    this.fontWeight = FontWeight.w500,
  });

  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: 1.2,
      ),
    );
  }
}
