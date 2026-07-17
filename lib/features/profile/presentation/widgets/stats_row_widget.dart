import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/models/citizen_profile.dart';

class StatsRowWidget extends StatelessWidget {
  const StatsRowWidget({super.key, required this.profile});

  final CitizenProfile profile;

  @override
  Widget build(BuildContext context) {
    final language = AppLanguage.instance.language;
    return Row(
      children: [
        _StatItem(
          value: profile.posts,
          label: AppLocalizations.translate('posts', language: language),
        ),
        const SizedBox(width: 6),
        _StatItem(
          value: profile.issuesReported,
          label: AppLocalizations.translate(
            'issues_reported',
            language: language,
          ),
        ),
        const SizedBox(width: 6),
        _StatItem(
          value: profile.issuesResolved,
          label: AppLocalizations.translate(
            'issues_resolved',
            language: language,
          ),
        ),
        const SizedBox(width: 6),
        _StatItem(
          value: profile.eventsAttended,
          label: AppLocalizations.translate(
            'events_attended',
            language: language,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x66F5A623)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value.toDouble()),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) {
                return Text(
                  animatedValue.round().toString(),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
