import 'package:flutter/material.dart';

import '../../domain/models/citizen_profile.dart';

class StatsRowWidget extends StatelessWidget {
  const StatsRowWidget({super.key, required this.profile});

  final CitizenProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, thickness: 1, color: Color(0xFF1F242C)),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatItem(value: profile.posts, label: 'Posts'),
            _StatItem(value: profile.issuesReported, label: 'Issues Reported'),
            _StatItem(value: profile.issuesResolved, label: 'Issues Resolved'),
            _StatItem(value: profile.eventsAttended, label: 'Events Attended'),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 1, color: Color(0xFF1F242C)),
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
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              return Text(
                animatedValue.round().toString(),
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
