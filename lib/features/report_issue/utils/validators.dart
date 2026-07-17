import 'report_issue_constants.dart';

class ReportIssueValidators {
  static const int maxDescriptionLength = 500;

  static String? validateCategory(String? categoryId) {
    if (categoryId == null || categoryId.trim().isEmpty) {
      return ReportIssueText.categoryRequired;
    }
    return null;
  }

  static String? validateDescription(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return ReportIssueText.descriptionRequired;
    }
    if (trimmed.length > maxDescriptionLength) {
      return ReportIssueText.descriptionTooLong;
    }
    return null;
  }

  static String? validateLocation(String value) {
    if (value.trim().isEmpty) {
      return ReportIssueText.locationRequired;
    }
    return null;
  }
}
