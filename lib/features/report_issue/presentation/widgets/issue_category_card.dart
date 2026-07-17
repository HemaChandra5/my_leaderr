import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/issue_category.dart';
import '../../utils/report_issue_constants.dart';

class IssueCategoryCard extends StatefulWidget {
  const IssueCategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final IssueCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<IssueCategoryCard> createState() => _IssueCategoryCardState();
}

class _IssueCategoryCardState extends State<IssueCategoryCard> {
  bool _isHovered = false;
  bool _isFocused = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = widget.isSelected || _isHovered || _isFocused;

    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.category.semanticLabel,
      child: FocusableActionDetector(
        onShowHoverHighlight: (bool value) =>
            setState(() => _isHovered = value),
        onShowFocusHighlight: (bool value) =>
            setState(() => _isFocused = value),
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (ActivateIntent intent) {
              widget.onTap();
              return null;
            },
          ),
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 170),
          scale: _isPressed ? 0.985 : (highlighted ? 1.005 : 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: ReportIssuePalette.cardBackground,
              borderRadius: BorderRadius.circular(ReportIssueRadius.card),
              border: Border.all(
                color: widget.isSelected
                    ? ReportIssuePalette.primaryGold
                    : ReportIssuePalette.border,
                width: widget.isSelected ? 1.2 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(ReportIssueRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(ReportIssueRadius.card),
                splashColor: const Color(0x33F5B62D),
                highlightColor: const Color(0x22F5B62D),
                onHighlightChanged: (bool value) {
                  if (_isPressed != value) {
                    setState(() => _isPressed = value);
                  }
                },
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onTap();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ReportIssueSpacing.sm,
                    vertical: ReportIssueSpacing.sm,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                        widget.category.iconAssetPath,
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          widget.isSelected
                              ? ReportIssuePalette.primaryGold
                              : ReportIssuePalette.whiteText,
                          BlendMode.srcIn,
                        ),
                        placeholderBuilder: (BuildContext context) =>
                            const SizedBox(width: 22, height: 22),
                      ),
                      const SizedBox(height: ReportIssueSpacing.sm),
                      Text(
                        widget.category.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.2,
                          color: ReportIssuePalette.whiteText,
                          fontWeight: widget.isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
