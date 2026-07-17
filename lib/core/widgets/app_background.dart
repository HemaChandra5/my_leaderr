import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_theme_manager.dart';

/// Ambient radial-glow background shared by the onboarding screens.
///
/// This was previously copy-pasted identically into splash_screen.dart and
/// role_screen.dart. Centralizing it means a future spacing/color change
/// only happens once, and it's the one place that needs to know how the
/// glow should differ between light and dark mode.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppThemeManager.instance.isDarkMode;

    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.35),
            radius: 1.3,
            colors: isDark
                ? <Color>[
                    const Color(0xFF0D1B2A).withValues(alpha: 0.5),
                    AppColors.background,
                  ]
                : <Color>[
                    const Color(0xFFF3E3C3).withValues(alpha: 0.55),
                    AppColors.background,
                  ],
          ),
        ),
      ),
    );
  }
}