class ReportedIssueCase {
  const ReportedIssueCase({
    required this.issueId,
    required this.userId,
    required this.category,
    required this.title,
    required this.status,
    required this.priority,
    required this.submittedAt,
    required this.location,
    required this.department,
    required this.officer,
    required this.expectedResolution,
    required this.latestUpdate,
    required this.progress,
  });

  final String issueId;
  final String userId;
  final String category;
  final String title;
  final String status;
  final String priority;
  final DateTime submittedAt;
  final String location;
  final String department;
  final String officer;
  final DateTime expectedResolution;
  final String latestUpdate;
  final int progress;
}
