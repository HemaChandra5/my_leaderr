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
      height: 88,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.gold.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, -2),
          ),
        ],
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
          // ── FAB ─────────────────────────────────────────────────────────
          Positioned(
            top: -16,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onAddPressed,
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF5A623), Color(0xFFD4831A)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withValues(alpha: 0.45),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: AppTheme.gold.withValues(alpha: 0.15),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.black,
                    size: 32,
                  ),
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
      splashColor: AppTheme.gold.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: selected
                  ? AppTheme.gold.withValues(alpha: 0.12)
                  : Colors.transparent,
            ),
            child: Icon(data.icon, color: color, size: 22),
          ),
          const SizedBox(height: 3),
          Text(
            data.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: selected ? 0.2 : 0.0,
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
