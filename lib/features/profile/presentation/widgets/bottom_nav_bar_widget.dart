import 'package:flutter/material.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key, required this.onTabTap});

  final ValueChanged<int> onTabTap;

  @override
  Widget build(BuildContext context) {
    final language = AppLanguage.instance.language;
    return Container(
      height: 78,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        border: Border(top: BorderSide(color: Color(0xFF1F242C))),
      ),
      child: Row(
        children: [
          Expanded(
            child: _item(
              0,
              Icons.home_rounded,
              AppLocalizations.translate('home', language: language),
              false,
            ),
          ),
          Expanded(
            child: _item(
              1,
              Icons.track_changes_rounded,
              AppLocalizations.translate('issues', language: language),
              false,
            ),
          ),
          Expanded(
            child: _item(
              2,
              Icons.groups_2_outlined,
              AppLocalizations.translate('community', language: language),
              false,
            ),
          ),
          Expanded(
            child: _item(
              3,
              Icons.event_note_rounded,
              AppLocalizations.translate('events', language: language),
              false,
            ),
          ),
          Expanded(
            child: _item(
              4,
              Icons.person_rounded,
              AppLocalizations.translate('profile', language: language),
              true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(int index, IconData icon, String label, bool active) {
    final color = active ? const Color(0xFFF5A623) : const Color(0xFF8B949E);
    return InkWell(
      onTap: () => onTabTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
