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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color navBg = isDark
        ? const Color(0xff0d1117)
        : const Color(0xffffffff);
    final Color borderColor = isDark
        ? const Color(0x2bf5a623)
        : const Color(0xFFE9EEF4);

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.home_rounded,
                    label: _localizedLabel(0),
                    selected: currentIndex == 0,
                    onTap: () => onItemSelected(0),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.track_changes_rounded,
                    label: _localizedLabel(1),
                    selected: currentIndex == 1,
                    onTap: () => onItemSelected(1),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.groups_2_rounded,
                    label: _localizedLabel(2),
                    selected: currentIndex == 2,
                    onTap: () => onItemSelected(2),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.event_note_rounded,
                    label: _localizedLabel(3),
                    selected: currentIndex == 3,
                    onTap: () => onItemSelected(3),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.person_rounded,
                    label: _localizedLabel(4),
                    selected: currentIndex == 4,
                    onTap: () => onItemSelected(4),
                  ),
                ),
              ],
            ),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = const Color(0xfff5a623);
    final Color inactiveColor = isDark
        ? const Color(0xff8b949e)
        : const Color(0xff64748b);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: activeColor.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: selected
                    ? activeColor.withValues(alpha: isDark ? 0.13 : 0.1)
                    : Colors.transparent,
              ),
              child: Icon(
                icon,
                color: selected ? activeColor : inactiveColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? activeColor : inactiveColor,
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                letterSpacing: selected ? 0.2 : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
