import 'package:flutter/material.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    this.currentIndex = 0,
    required this.onItemSelected,
  });

  static const List<String> items = [
    'Home',
    'Issues',
    'Community',
    'Events',
    'Profile',
  ];

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  String _localizedLabel(int index) {
    final language = AppLanguage.instance.language;
    switch (index) {
      case 0:
        return AppLocalizations.translate('home', language: language);
      case 1:
        return AppLocalizations.translate('issues', language: language);
      case 2:
        return AppLocalizations.translate('community', language: language);
      case 3:
        return AppLocalizations.translate('events', language: language);
      default:
        return AppLocalizations.translate('profile', language: language);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0D1117)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: _localizedLabel(0),
                selected: currentIndex == 0,
                onTap: () => onItemSelected(0),
              ),
              _NavItem(
                icon: Icons.track_changes_rounded,
                label: _localizedLabel(1),
                selected: currentIndex == 1,
                onTap: () => onItemSelected(1),
              ),
              _NavItem(
                icon: Icons.groups_2_outlined,
                label: _localizedLabel(2),
                selected: currentIndex == 2,
                onTap: () => onItemSelected(2),
              ),
              _NavItem(
                icon: Icons.event_outlined,
                label: _localizedLabel(3),
                selected: currentIndex == 3,
                onTap: () => onItemSelected(3),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: _localizedLabel(4),
                selected: currentIndex == 4,
                onTap: () => onItemSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFF5A623) : const Color(0xFF8B949E);
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
