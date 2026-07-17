import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/track_issue_models.dart';
import '../../domain/repositories/track_issue_repository.dart';

class FirebaseTrackIssueRepository implements TrackIssueRepository {
  FirebaseTrackIssueRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<TrackedIssue?> watchIssue(String issueId) {
    return _firestore
        .collection('issues')
        .doc(issueId)
        .snapshots(includeMetadataChanges: true)
        .map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return null;
          }
          final Map<String, dynamic> data = Map<String, dynamic>.from(
            snapshot.data()!,
          );
          data.putIfAbsent('issueId', () => snapshot.id);
          return TrackedIssue.fromFirestore(data);
        });
  }

  @override
  Stream<bool> watchNotificationSubscription({
    required String issueId,
    required String userId,
  }) {
    if (issueId.trim().isEmpty || userId.trim().isEmpty) {
      return Stream<bool>.value(false);
    }

    return _firestore
        .collection('issues')
        .doc(issueId)
        .collection('notification_subscriptions')
        .doc(userId)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return false;
          }
          return (snapshot.data()!['enabled'] as bool?) ?? false;
        });
  }

  @override
  Future<TrackedIssue?> fetchIssue(String issueId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('issues')
        .doc(issueId)
        .get(const GetOptions(source: Source.serverAndCache));
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    final Map<String, dynamic> data = Map<String, dynamic>.from(
      snapshot.data()!,
    );
    data.putIfAbsent('issueId', () => snapshot.id);
    return TrackedIssue.fromFirestore(data);
  }

  @override
  Future<TrackedIssue?> fetchLatestIssueForUser(String userId) async {
    final String normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      return null;
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('issues')
        .where('userId', isEqualTo: normalizedUserId)
        .limit(25)
        .get(const GetOptions(source: Source.serverAndCache));

    if (snapshot.docs.isEmpty) {
      return null;
    }

    QueryDocumentSnapshot<Map<String, dynamic>>? latestDoc;
    DateTime? latestCreatedAt;

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      final Map<String, dynamic> data = doc.data();
      if (data.isEmpty) {
        continue;
      }

      final DateTime createdAt =
          _coerceDateTime(data['createdAt']) ??
          _coerceDateTime(data['updatedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0);

      if (latestDoc == null || createdAt.isAfter(latestCreatedAt!)) {
        latestDoc = doc;
        latestCreatedAt = createdAt;
      }
    }

    if (latestDoc == null) {
      return null;
    }

    final QueryDocumentSnapshot<Map<String, dynamic>> selected = latestDoc;
    final Map<String, dynamic> data = Map<String, dynamic>.from(
      selected.data(),
    );
    data.putIfAbsent('issueId', () => selected.id);
    return TrackedIssue.fromFirestore(data);
  }

  DateTime? _coerceDateTime(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  Future<void> setNotificationSubscription({
    required String issueId,
    required String userId,
    required bool enabled,
  }) async {
    final DocumentReference<Map<String, dynamic>> issueRef = _firestore
        .collection('issues')
        .doc(issueId);
    final DocumentReference<Map<String, dynamic>> subRef = issueRef
        .collection('notification_subscriptions')
        .doc(userId);
    final Timestamp now = Timestamp.now();

    if (enabled) {
      await _firestore.runTransaction((Transaction tx) async {
        final DocumentSnapshot<Map<String, dynamic>> subSnap = await tx.get(
          subRef,
        );
        final bool alreadyEnabled =
            (subSnap.data()?['enabled'] as bool?) == true;
        if (!alreadyEnabled) {
          tx.set(subRef, <String, dynamic>{
            'issueId': issueId,
            'userId': userId,
            'enabled': true,
            'channel': 'push',
            'createdAt': subSnap.exists
                ? (subSnap.data()?['createdAt'] ?? now)
                : now,
            'updatedAt': now,
          }, SetOptions(merge: true));
        }

        tx.set(issueRef, <String, dynamic>{
          'notificationSubscribers': FieldValue.arrayUnion(<String>[userId]),
          'updatedAt': now,
        }, SetOptions(merge: true));
      });
      return;
    }

    await _firestore.runTransaction((Transaction tx) async {
      tx.set(subRef, <String, dynamic>{
        'issueId': issueId,
        'userId': userId,
        'enabled': false,
        'channel': 'push',
        'updatedAt': now,
      }, SetOptions(merge: true));

      tx.set(issueRef, <String, dynamic>{
        'notificationSubscribers': FieldValue.arrayRemove(<String>[userId]),
        'updatedAt': now,
      }, SetOptions(merge: true));
    });
  }

  @override
  Future<void> submitCitizenVerification({
    required String issueId,
    required String verifiedBy,
    String? remarks,
    int? rating,
  }) async {
    final DocumentReference<Map<String, dynamic>> ref = _firestore
        .collection('issues')
        .doc(issueId);

    await _firestore.runTransaction((Transaction tx) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await tx.get(ref);
      if (!snapshot.exists || snapshot.data() == null) {
        throw StateError('Issue not found for $issueId.');
      }

      final Map<String, dynamic> current = Map<String, dynamic>.from(
        snapshot.data()!,
      );
      final Map<String, dynamic> existingFeedback = Map<String, dynamic>.from(
        current['citizenFeedback'] as Map<String, dynamic>? ??
            <String, dynamic>{},
      );
      final bool alreadyVerified =
          existingFeedback['verified'] == true ||
          (current['currentStatus'] as String? ?? '').toLowerCase() ==
              'issue closed';
      if (alreadyVerified) {
        return;
      }

      final DateTime now = DateTime.now().toUtc();
      final Timestamp nowTs = Timestamp.fromDate(now);

      final List<dynamic> rawTimeline =
          (current['timeline'] as List<dynamic>? ?? <dynamic>[]).toList();
      rawTimeline.add(<String, dynamic>{
        'status': 'Issue Closed',
        'updatedBy': verifiedBy,
        'actor': verifiedBy,
        'department': (current['department'] ?? 'Citizen Services') as String,
        'officer': (current['assignedOfficer'] ?? 'Unassigned') as String,
        'timestamp': nowTs,
        'message': 'Citizen verified the resolution and closed the issue.',
        'remarks': (remarks ?? '').trim(),
        'latitude': (current['latitude'] as num?)?.toDouble(),
        'longitude': (current['longitude'] as num?)?.toDouble(),
        'photoAttachments': List<String>.from(
          current['imageUrls'] as List<dynamic>? ?? <String>[],
        ),
        'videoAttachments': List<String>.from(
          current['videoUrls'] as List<dynamic>? ?? <String>[],
        ),
        'auditLog': List<String>.from(
          current['auditLogs'] as List<dynamic>? ?? <String>[],
        ),
      });

      final List<String> audit =
          List<String>.from(
            current['auditLogs'] as List<dynamic>? ?? <String>[],
          )..add(
            '$now: citizen verification submitted by $verifiedBy${remarks == null || remarks.trim().isEmpty ? '' : ' | remarks: ${remarks.trim()}'}',
          );

      tx.update(ref, <String, dynamic>{
        'currentStatus': 'Issue Closed',
        'resolvedAt': nowTs,
        'updatedAt': nowTs,
        'timeline': rawTimeline,
        'auditLogs': audit,
        'citizenFeedback': <String, dynamic>{
          'verified': true,
          'verifiedBy': verifiedBy,
          'verifiedAt': nowTs,
          'rating': rating,
          'remarks': (remarks ?? '').trim(),
        },
      });
    });
  }
}
