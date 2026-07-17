import 'package:cloud_firestore/cloud_firestore.dart';

class IssueTimelineEntry {
  const IssueTimelineEntry({
    required this.status,
    required this.message,
    required this.timestamp,
    required this.actor,
  });

  final String status;
  final String message;
  final DateTime timestamp;
  final String actor;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'actor': actor,
    };
  }

  factory IssueTimelineEntry.fromMap(Map<String, dynamic> map) {
    final Timestamp ts = (map['timestamp'] as Timestamp?) ?? Timestamp.now();
    return IssueTimelineEntry(
      status: (map['status'] ?? '') as String,
      message: (map['message'] ?? '') as String,
      timestamp: ts.toDate(),
      actor: (map['actor'] ?? '') as String,
    );
  }
}

class SubmittedIssue {
  const SubmittedIssue({
    required this.issueId,
    required this.userId,
    required this.categoryId,
    required this.categoryTitle,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.locationComponents,
    required this.locationPlaceId,
    required this.locationTimestamp,
    required this.imageUrls,
    required this.videoUrls,
    required this.createdAt,
    required this.updatedAt,
    required this.priority,
    required this.currentStatus,
    required this.timeline,
    required this.assignedOfficer,
    required this.primaryAuthority,
    required this.secondaryAuthorities,
    required this.taggedAuthorities,
    required this.auditLogs,
  });

  final String issueId;
  final String userId;
  final String categoryId;
  final String categoryTitle;
  final String description;
  final double? latitude;
  final double? longitude;
  final String address;
  final Map<String, String> locationComponents;
  final String? locationPlaceId;
  final DateTime? locationTimestamp;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String priority;
  final String currentStatus;
  final List<IssueTimelineEntry> timeline;
  final String assignedOfficer;
  final Map<String, dynamic>? primaryAuthority;
  final List<Map<String, dynamic>> secondaryAuthorities;
  final List<Map<String, dynamic>> taggedAuthorities;
  final List<String> auditLogs;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'issueId': issueId,
      'userId': userId,
      'categoryId': categoryId,
      'categoryTitle': categoryTitle,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'locationComponents': locationComponents,
        'locationPlaceId': locationPlaceId,
        'locationTimestamp':
          locationTimestamp == null ? null : Timestamp.fromDate(locationTimestamp!),
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'priority': priority,
      'currentStatus': currentStatus,
      'timeline': timeline
          .map((IssueTimelineEntry entry) => entry.toMap())
          .toList(),
      'assignedOfficer': assignedOfficer,
      'primaryAuthority': primaryAuthority,
      'secondaryAuthorities': secondaryAuthorities,
      'taggedAuthorities': taggedAuthorities,
      'auditLogs': auditLogs,
    };
  }

  factory SubmittedIssue.fromMap(Map<String, dynamic> map) {
    final Timestamp created =
        (map['createdAt'] as Timestamp?) ?? Timestamp.now();
    final Timestamp updated =
        (map['updatedAt'] as Timestamp?) ?? Timestamp.now();

    final List<dynamic> rawTimeline =
        (map['timeline'] as List<dynamic>? ?? <dynamic>[]);
    final List<IssueTimelineEntry> timeline = rawTimeline
        .whereType<Map<String, dynamic>>()
        .map(IssueTimelineEntry.fromMap)
        .toList(growable: false);

    final Map<String, dynamic>? parsedPrimaryAuthority =
      map['primaryAuthority'] is Map<String, dynamic>
      ? Map<String, dynamic>.from(map['primaryAuthority'] as Map<String, dynamic>)
      : null;

    final List<Map<String, dynamic>> parsedSecondaryAuthorities =
      (map['secondaryAuthorities'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => Map<String, dynamic>.from(item))
        .toList(growable: false);

    final List<Map<String, dynamic>> parsedTaggedAuthorities =
      (map['taggedAuthorities'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => Map<String, dynamic>.from(item))
        .toList(growable: false);

    final Map<String, String> parsedLocationComponents =
        (map['locationComponents'] as Map<String, dynamic>? ??
                (map['location'] as Map<String, dynamic>? ??
                        <String, dynamic>{})['components']
                    as Map<String, dynamic>? ??
                <String, dynamic>{})
            .map(
              (String key, dynamic value) => MapEntry(key, '${value ?? ''}'),
            );

    return SubmittedIssue(
      issueId: (map['issueId'] ?? '') as String,
      userId: (map['userId'] ?? '') as String,
      categoryId: (map['categoryId'] ?? '') as String,
      categoryTitle: (map['categoryTitle'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      address: (map['address'] ?? '') as String,
      locationComponents: parsedLocationComponents,
      locationPlaceId: (map['locationPlaceId'] ??
              (map['location'] as Map<String, dynamic>? ??
                  <String, dynamic>{})['placeId'])
          as String?,
      locationTimestamp: (() {
        final dynamic raw = map['locationTimestamp'] ??
            (map['location'] as Map<String, dynamic>? ??
                <String, dynamic>{})['timestamp'];
        if (raw is Timestamp) {
          return raw.toDate();
        }
        return null;
      })(),
      imageUrls: List<String>.from(
        map['imageUrls'] as List<dynamic>? ?? <String>[],
      ),
      videoUrls: List<String>.from(
        map['videoUrls'] as List<dynamic>? ?? <String>[],
      ),
      createdAt: created.toDate(),
      updatedAt: updated.toDate(),
      priority: (map['priority'] ?? 'Medium') as String,
      currentStatus: (map['currentStatus'] ?? 'Submitted') as String,
      timeline: timeline,
      assignedOfficer: (map['assignedOfficer'] ?? 'Unassigned') as String,
      primaryAuthority: parsedPrimaryAuthority,
      secondaryAuthorities: parsedSecondaryAuthorities,
      taggedAuthorities: parsedTaggedAuthorities,
      auditLogs: List<String>.from(
        map['auditLogs'] as List<dynamic>? ?? <String>[],
      ),
    );
  }
}
