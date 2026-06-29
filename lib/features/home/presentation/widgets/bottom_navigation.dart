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
      height: 88,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xff0F1012),
        border: const Border(top: BorderSide(color: Color(0xff25272B))),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, -4),
          ),
        ],
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: selected ? const Color(0x1FF5A623) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkResponse(
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
                letterSpacing: 0.2,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(top: 4),
              width: selected ? 16 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xffF5A623),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
