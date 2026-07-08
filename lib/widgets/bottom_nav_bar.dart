import 'package:flutter/material.dart';

import '../theme.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

  static const _items = <_NavItemData>[
    _NavItemData(label: 'Home', icon: Icons.home_rounded),
    _NavItemData(label: 'Track', icon: Icons.timeline_rounded),
    _NavItemData(label: 'Events', icon: Icons.event_note_rounded),
    _NavItemData(label: 'Profile', icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Expanded(child: _item(0, 0)),
              Expanded(child: _item(1, 1)),
              const SizedBox(width: 72),
              Expanded(child: _item(2, 2)),
              Expanded(child: _item(3, 3)),
            ],
          ),
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onAddPressed,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.gold,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 34),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(int visualSlot, int index) {
    final data = _items[index];
    final selected = currentIndex == index;
    final color = selected ? AppTheme.gold : AppTheme.textSecondary;
    return InkWell(
      onTap: () => onTabSelected(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
