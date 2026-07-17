import '../entities/track_issue_models.dart';

abstract class TrackIssueRepository {
  Stream<TrackedIssue?> watchIssue(String issueId);

  Stream<bool> watchNotificationSubscription({
    required String issueId,
    required String userId,
  });

  Future<TrackedIssue?> fetchIssue(String issueId);

  Future<TrackedIssue?> fetchLatestIssueForUser(String userId);

  Future<void> setNotificationSubscription({
    required String issueId,
    required String userId,
    required bool enabled,
  });

  Future<void> submitCitizenVerification({
    required String issueId,
    required String verifiedBy,
    String? remarks,
    int? rating,
  });
}
