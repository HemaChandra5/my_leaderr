import 'package:flutter/material.dart';

import '../../utils/report_issue_constants.dart';
import '../../utils/validators.dart';

class IssueDescriptionField extends StatelessWidget {
  const IssueDescriptionField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.errorText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final int count = controller.text.characters.length;

    return Semantics(
      label: ReportIssueSemantics.descriptionField,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            ReportIssueText.detailsTitle,
            style: TextStyle(
              color: ReportIssuePalette.whiteText,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: ReportIssueSpacing.md),
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            maxLength: ReportIssueValidators.maxDescriptionLength,
            style: const TextStyle(
              color: ReportIssuePalette.whiteText,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            cursorColor: ReportIssuePalette.primaryGold,
            onChanged: onChanged,
            decoration: InputDecoration(
              counterText: '',
              hintText: ReportIssueText.detailsHint,
              hintStyle: const TextStyle(
                color: ReportIssuePalette.hintText,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: ReportIssuePalette.cardBackground,
              errorText: errorText,
              errorStyle: const TextStyle(height: 1.1),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ReportIssueRadius.field),
                borderSide: const BorderSide(color: ReportIssuePalette.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ReportIssueRadius.field),
                borderSide: const BorderSide(
                  color: ReportIssuePalette.primaryGold,
                  width: 1.4,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ReportIssueRadius.field),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ReportIssueRadius.field),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              contentPadding: const EdgeInsets.all(ReportIssueSpacing.lg),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$count/${ReportIssueValidators.maxDescriptionLength}',
              style: const TextStyle(
                color: ReportIssuePalette.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
