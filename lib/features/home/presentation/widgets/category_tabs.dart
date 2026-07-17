import 'package:flutter/material.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  static const List<String> tabs = ['Local', 'State', 'National'];

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  String _localizedTabTitle(int index) {
    final language = AppLanguage.instance.language;
    switch (index) {
      case 0:
        return AppLocalizations.translate('local', language: language);
      case 1:
        return AppLocalizations.translate('state', language: language);
      default:
        return AppLocalizations.translate('national', language: language);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == tabs.length - 1 ? 0 : 8,
              ),
              child: _CategoryTabPill(
                title: _localizedTabTitle(index),
                selected: index == selectedIndex,
                onTap: () => onTabSelected(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTabPill extends StatelessWidget {
  const _CategoryTabPill({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color inactiveBg = isDark
      ? const Color(0xff13161c)
      : const Color(0xffeef2f7);
    final Color inactiveBorder = isDark
      ? const Color(0xff2a2f36)
      : const Color(0xffd5dde8);
    final Color activeText = isDark
        ? const Color(0xff000000)
        : const Color(0xffffffff);
    final Color inactiveText = isDark
        ? const Color(0xff8b949e)
        : const Color(0xff64748b);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xffF8BE56)
                  : const Color(0x66F5A623),
            ),
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xfff5a623), Color(0xffd4831a)],
                  )
                : null,
            color: selected ? null : inactiveBg,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(
                        0xfff5a623,
                      ).withValues(alpha: isDark ? 0.3 : 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? activeText : inactiveText,
                fontSize: 13.5,
                fontFamily: 'Inter',
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: selected ? 0.3 : 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
