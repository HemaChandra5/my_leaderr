enum IssueStatus { started, inProgress, completed }

class IssueUpdate {
  const IssueUpdate({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.description,
    required this.imageAsset,
    required this.status,
  });

  final String id;
  final String userId;
  final String timestamp;
  final String description;
  final String imageAsset;
  final IssueStatus status;
}
