import 'package:flutter/material.dart';

import '../../utils/report_issue_constants.dart';

class ReportProgressStepper extends StatelessWidget {
  const ReportProgressStepper({super.key, required this.currentStep});

  final int currentStep;

  static const List<String> _labels = <String>[
    ReportIssueText.stepCategory,
    ReportIssueText.stepDetails,
    ReportIssueText.stepLocation,
    ReportIssueText.stepReview,
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: ReportIssueSemantics.progressStepper,
      child: Row(
        children: List<Widget>.generate(_labels.length * 2 - 1, (int index) {
          if (index.isOdd) {
            final int connectorIndex = index ~/ 2;
            final bool active = connectorIndex < currentStep;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                height: 2,
                margin: const EdgeInsets.symmetric(
                  horizontal: ReportIssueSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? ReportIssuePalette.primaryGold
                      : ReportIssuePalette.border,
                  borderRadius: BorderRadius.circular(ReportIssueRadius.pill),
                ),
              ),
            );
          }

          final int stepIndex = index ~/ 2;
          final _StepState state = _resolveState(stepIndex);
          return _StepperNode(
            state: state,
            index: stepIndex + 1,
            label: _labels[stepIndex],
          );
        }),
      ),
    );
  }

  _StepState _resolveState(int stepIndex) {
    if (stepIndex < currentStep) {
      return _StepState.completed;
    }
    if (stepIndex == currentStep) {
      return _StepState.current;
    }
    return _StepState.upcoming;
  }
}

enum _StepState { completed, current, upcoming }

class _StepperNode extends StatelessWidget {
  const _StepperNode({
    required this.state,
    required this.index,
    required this.label,
  });

  final _StepState state;
  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    final bool isGold = state != _StepState.upcoming;
    final bool isCurrent = state == _StepState.current;

    return Semantics(
      button: false,
      label: 'Step $index $label',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isGold
                  ? ReportIssuePalette.primaryGold
                  : ReportIssuePalette.inactiveStep,
              border: Border.all(
                color: isGold
                    ? ReportIssuePalette.primaryGold
                    : ReportIssuePalette.inactiveStepBorder,
                width: 1.3,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: TextStyle(
                color: isGold ? Colors.black : ReportIssuePalette.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: ReportIssueSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: isCurrent
                  ? ReportIssuePalette.primaryGold
                  : ReportIssuePalette.secondaryText,
              fontSize: 13,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
