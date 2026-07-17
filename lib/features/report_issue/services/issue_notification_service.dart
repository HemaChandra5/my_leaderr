import 'package:cloud_firestore/cloud_firestore.dart';

class IssueNotificationService {
  IssueNotificationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> notifyIssueSubmitted({
    required String issueId,
    required String userId,
    required String category,
    required DateTime createdAt,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'issueId': issueId,
      'userId': userId,
      'category': category,
      'type': 'issue_submitted',
      'createdAt': Timestamp.fromDate(createdAt),
      'message': 'Issue $issueId submitted in $category.',
      'read': false,
    };

    final WriteBatch batch = _firestore.batch();

    final DocumentReference<Map<String, dynamic>> citizenDoc = _firestore
        .collection('notifications')
        .doc();
    batch.set(citizenDoc, <String, dynamic>{...payload, 'audience': 'citizen'});

    final DocumentReference<Map<String, dynamic>> adminDoc = _firestore
        .collection('notifications')
        .doc();
    batch.set(adminDoc, <String, dynamic>{...payload, 'audience': 'admin'});

    final DocumentReference<Map<String, dynamic>> departmentDoc = _firestore
        .collection('notifications')
        .doc();
    batch.set(departmentDoc, <String, dynamic>{
      ...payload,
      'audience': 'department',
    });

    await batch.commit();
  }
}
