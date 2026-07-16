import 'package:flutter/material.dart';

import '../theme/app_theme_manager.dart';

/// Design tokens for the app.
///
/// Previously this class exposed a single hardcoded palette, which meant
/// [AppThemeManager]'s dark/light toggle changed the icon in the UI but had
/// no visible effect anywhere that referenced these constants. Every field
/// below is now a getter that resolves against the live theme, so flipping
/// the toggle actually repaints the app. Call sites are unchanged
/// (`AppColors.background` still works exactly as before).
class AppColors {
  const AppColors._();

  static bool get _isDark => AppThemeManager.instance.isDarkMode;

  // ── Surfaces ─────────────────────────────────────────────────────────
  static Color get background =>
      _isDark ? _darkBackground : _lightBackground;
  static Color get surface => _isDark ? _darkSurface : _lightSurface;
  static Color get surfaceElevated =>
      _isDark ? _darkSurfaceElevated : _lightSurfaceElevated;

  // ── Brand gold ───────────────────────────────────────────────────────
  // Same hue family in both modes; value shifts so it stays legible against
  // near-black in dark mode and against warm ivory in light mode.
  static Color get primaryGold => _isDark ? _darkGold : _lightGold;
  static Color get goldLight => _isDark ? _darkGoldLight : _lightGoldLight;
  static Color get goldDeep => _isDark ? _darkGoldDeep : _lightGoldDeep;

  // ── Text ─────────────────────────────────────────────────────────────
  static Color get textPrimary => _isDark ? _darkText : _lightText;
  static Color get textMuted => _isDark ? _darkTextMuted : _lightTextMuted;
  static Color get divider => _isDark ? _darkDivider : _lightDivider;

  /// Fixed ink color for text/icons drawn on top of a gold-filled surface
  /// (e.g. the primary button, a selected role card's arrow). Gold never
  /// gets light enough in either mode to need a white foreground here —
  /// using `background` for this (as the original code did) broke in
  /// light mode, since `background` became a light color.
  static const Color onGold = Color(0xFF15120A);

  static const Color white = Color(0xFFFFFFFF);

  // ── Dark palette ─────────────────────────────────────────────────────
  static const Color _darkBackground = Color(0xFF060607);
  static const Color _darkSurface = Color(0xFF111214);
  static const Color _darkSurfaceElevated = Color(0xFF17191D);
  static const Color _darkGold = Color(0xFFF5A623);
  static const Color _darkGoldLight = Color(0xFFFFD700);
  static const Color _darkGoldDeep = Color(0xFFD4871A);
  static const Color _darkText = Color(0xFFFFFFFF);
  static const Color _darkTextMuted = Color(0xFF9A9DA6);
  static const Color _darkDivider = Color(0xFF23252A);

  // ── Light palette ────────────────────────────────────────────────────
  // Pure white light theme as the global baseline for all main surfaces.
  static const Color _lightBackground = Color(0xFFFFFFFF);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color _lightGold = Color(0xFFB9790E);
  static const Color _lightGoldLight = Color(0xFFD89B2E);
  static const Color _lightGoldDeep = Color(0xFF8F5D0A);
  static const Color _lightText = Color(0xFF15171B);
  static const Color _lightTextMuted = Color(0xFF6B6F76);
  static const Color _lightDivider = Color(0xFFE9EEF4);
}