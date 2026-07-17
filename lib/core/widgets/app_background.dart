import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Ambient radial-glow background shared by the onboarding screens.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.35),
            radius: 1.3,
            colors: <Color>[
              const Color(0xFF0D1B2A).withValues(alpha: 0.5),
              AppColors.background,
            ],
          ),
        ),
      ),
    );
  }
}
