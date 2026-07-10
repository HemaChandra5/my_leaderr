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
      height: 54,
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 44,
          decoration: BoxDecoration(
            color: selected ? const Color(0xffF5A623) : const Color(0xff171717),
            borderRadius: BorderRadius.circular(12.5),
            border: Border.all(
              color: selected
                  ? const Color(0xffF8BE56)
                  : const Color(0x66F5A623),
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x2BF5A623),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontSize: 13.5,
                fontFamily: 'Inter',
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: selected ? 0.2 : 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
