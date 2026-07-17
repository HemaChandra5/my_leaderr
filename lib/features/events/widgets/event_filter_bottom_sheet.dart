import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/event_model.dart';

Future<Set<EventFilterTag>?> showEventFilterBottomSheet(
  BuildContext context, {
  required Set<EventFilterTag> initialSelection,
}) {
  return showModalBottomSheet<Set<EventFilterTag>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      final Set<EventFilterTag> tempSelection = <EventFilterTag>{...initialSelection};

      return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setModalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: AppColors.divider),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Filter Events',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose one or more filters',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: EventFilterTag.values.map((EventFilterTag tag) {
                      final bool selected = tempSelection.contains(tag);
                      return FilterChip(
                        selected: selected,
                        label: Text(tag.label),
                        onSelected: (bool value) {
                          setModalState(() {
                            if (value) {
                              tempSelection.add(tag);
                            } else {
                              tempSelection.remove(tag);
                            }
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: selected ? AppColors.primaryGold : AppColors.divider,
                          ),
                        ),
                        selectedColor: AppColors.primaryGold.withValues(alpha: 0.18),
                        backgroundColor: AppColors.surfaceElevated,
                        checkmarkColor: AppColors.primaryGold,
                        labelStyle: TextStyle(
                          color: selected ? AppColors.primaryGold : AppColors.textPrimary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                        ),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(growable: false),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setModalState(tempSelection.clear),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(tempSelection),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
