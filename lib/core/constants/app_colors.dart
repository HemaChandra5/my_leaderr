import 'package:flutter/material.dart';

/// Design tokens for the app.
class AppColors {
  const AppColors._();

  static const Color background = Color(0xFF060607);
  static const Color surface = Color(0xFF111214);
  static const Color surfaceElevated = Color(0xFF17191D);

  static const Color primaryGold = Color(0xFFF5A623);
  static const Color goldLight = Color(0xFFFFD700);
  static const Color goldDeep = Color(0xFFD4871A);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9A9DA6);
  static const Color divider = Color(0xFF23252A);

  /// Fixed ink color for text/icons drawn on top of a gold-filled surface
  /// (e.g. the primary button, a selected role card's arrow). Gold never
  /// gets light enough in either mode to need a white foreground here —
  /// using `background` for this (as the original code did) broke in
  /// light mode, since `background` became a light color.
  static const Color onGold = Color(0xFF15120A);

  static const Color white = Color(0xFFFFFFFF);
}
