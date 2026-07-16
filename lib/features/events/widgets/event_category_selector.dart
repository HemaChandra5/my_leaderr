import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/event_model.dart';

class EventCategorySelector extends StatelessWidget {
  const EventCategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final EventCategory selected;
  final ValueChanged<EventCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color inactiveBg = isDark
        ? const Color(0xFF13161C)
        : const Color(0xFFF1F5F9);
    final List<EventCategory> categories = EventCategory.values;

    return SizedBox(
      height: 52,
      child: Row(
        children: List<Widget>.generate(categories.length, (int index) {
          final EventCategory category = categories[index];
          final bool isSelected = category == selected;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == categories.length - 1 ? 0 : 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onChanged(category),
                child: TweenAnimationBuilder<double>(
                  key: ValueKey<String>('category_${category.name}_$isSelected'),
                  tween: Tween<double>(begin: isSelected ? 0.92 : 1.0, end: 1.0),
                  curve: Curves.elasticOut,
                  duration: const Duration(milliseconds: 320),
                  builder: (BuildContext context, double scale, Widget? child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isSelected ? AppColors.primaryGold : inactiveBg,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryGold : AppColors.divider,
                        width: isSelected ? 1.2 : 1,
                      ),
                      boxShadow: isSelected
                          ? <BoxShadow>[
                              BoxShadow(
                                color: AppColors.primaryGold.withValues(alpha: 0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        category.label,
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
