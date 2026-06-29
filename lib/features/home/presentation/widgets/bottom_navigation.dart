import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    this.currentIndex = 0,
    required this.onItemSelected,
  });

  static const List<String> items = [
    'Home',
    'Track',
    'Create',
    'Events',
    'Profile',
  ];

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 10),
      decoration: const BoxDecoration(
        color: Color(0xff111111),
        border: Border(top: BorderSide(color: Color(0xff2A2A2A))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              selected: currentIndex == 0,
              onTap: () => onItemSelected(0),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.show_chart_rounded,
              label: 'Track',
              selected: currentIndex == 1,
              onTap: () => onItemSelected(1),
            ),
          ),
          const SizedBox(width: 56),
          Expanded(
            child: _NavItem(
              icon: Icons.event_note_rounded,
              label: 'Events',
              selected: currentIndex == 3,
              onTap: () => onItemSelected(3),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              selected: currentIndex == 4,
              onTap: () => onItemSelected(4),
            ),
          ),
        ],
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
    final color = selected ? const Color(0xffF5A623) : const Color(0xff9E9E9E);
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
