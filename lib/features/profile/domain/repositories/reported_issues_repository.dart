import '../models/reported_issue_case.dart';

abstract class ReportedIssuesRepository {
  Stream<List<ReportedIssueCase>> watchByUser(String userId);
}
