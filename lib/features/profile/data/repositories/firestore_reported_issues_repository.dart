import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../report_issue/models/submitted_issue.dart';
import '../../domain/models/reported_issue_case.dart';
import '../../domain/repositories/reported_issues_repository.dart';

class FirestoreReportedIssuesRepository implements ReportedIssuesRepository {
  FirestoreReportedIssuesRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<ReportedIssueCase>> watchByUser(String userId) {
    if (userId.trim().isEmpty) {
      return Stream<List<ReportedIssueCase>>.value(const <ReportedIssueCase>[]);
    }

    return _firestore
        .collection('issues')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          final List<ReportedIssueCase> items = <ReportedIssueCase>[];

          for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
              in snapshot.docs) {
            try {
              final Map<String, dynamic> data = doc.data();
              data.putIfAbsent('issueId', () => doc.id);
              final SubmittedIssue issue = SubmittedIssue.fromMap(data);
              items.add(_toCase(issue));
            } catch (_) {
              // Skip malformed documents instead of breaking the list stream.
            }
          }

          items.sort((ReportedIssueCase a, ReportedIssueCase b) {
            return b.submittedAt.compareTo(a.submittedAt);
          });
          return items;
        });
  }

  ReportedIssueCase _toCase(SubmittedIssue issue) {
    final String category = issue.categoryTitle.trim().isEmpty
        ? 'General'
        : issue.categoryTitle.trim();
    final String location = issue.address.trim().isEmpty
        ? 'Hyderabad, Telangana'
        : issue.address.trim();
    final String department = _departmentFromIssue(issue);
    final String officer = issue.assignedOfficer.trim().isEmpty ||
            issue.assignedOfficer.trim().toLowerCase() == 'unassigned'
        ? 'Akash'
        : issue.assignedOfficer.trim();

    final DateTime expected = issue.timeline.isEmpty
        ? issue.updatedAt.add(const Duration(days: 3))
        : issue.updatedAt.add(const Duration(days: 2));

    final String latestUpdate = issue.timeline.isEmpty
        ? 'Request created and waiting for department action.'
        : issue.timeline.last.message.trim().isEmpty
        ? 'Department update will appear shortly.'
        : issue.timeline.last.message.trim();

    final String status = _normalizeStatus(issue.currentStatus);

    return ReportedIssueCase(
      issueId: issue.issueId,
      userId: issue.userId,
      category: category,
      title: _titleFromIssue(issue),
      status: status,
      priority: issue.priority.trim().isEmpty ? 'Medium' : issue.priority.trim(),
      submittedAt: issue.createdAt.toLocal(),
      location: location,
      department: department,
      officer: officer,
      expectedResolution: expected.toLocal(),
      latestUpdate: latestUpdate,
      progress: _progressForStatus(status),
    );
  }

  String _departmentFromIssue(SubmittedIssue issue) {
    final dynamic primary = issue.primaryAuthority;
    if (primary is Map<String, dynamic>) {
      final String value = (primary['department'] ?? '').toString().trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    if (issue.taggedAuthorities.isNotEmpty) {
      final String value =
          (issue.taggedAuthorities.first['department'] ?? '').toString().trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return 'GHMC Civic Operations';
  }

  String _titleFromIssue(SubmittedIssue issue) {
    final String description = issue.description.trim();
    if (description.isEmpty) {
      return '${issue.categoryTitle.trim().isEmpty ? 'Public Service' : issue.categoryTitle} Service Request';
    }
    if (description.length <= 60) {
      return description;
    }
    return '${description.substring(0, 57).trim()}...';
  }

  String _normalizeStatus(String raw) {
    final String value = raw.trim().toLowerCase();
    if (value.contains('verified') || value.contains('closed')) {
      return 'Citizen Verified';
    }
    if (value.contains('resolved') || value.contains('completed')) {
      return 'Completed';
    }
    if (value.contains('in progress')) {
      return 'Work In Progress';
    }
    if (value.contains('work started')) {
      return 'Work Started';
    }
    if (value.contains('inspection')) {
      return 'Inspection';
    }
    if (value.contains('assigned')) {
      return 'Assigned';
    }
    return 'Issue Created';
  }

  int _progressForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'issue created':
        return 10;
      case 'assigned':
        return 25;
      case 'inspection':
        return 40;
      case 'work started':
        return 55;
      case 'work in progress':
        return 68;
      case 'completed':
        return 92;
      case 'citizen verified':
        return 100;
      default:
        return 20;
    }
  }
}
