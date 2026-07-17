import 'package:cloud_firestore/cloud_firestore.dart';

const List<IssueWorkflowStatus> workflowOrder = <IssueWorkflowStatus>[
  IssueWorkflowStatus.issueCreated,
  IssueWorkflowStatus.departmentAssigned,
  IssueWorkflowStatus.officerAccepted,
  IssueWorkflowStatus.inspectionScheduled,
  IssueWorkflowStatus.workStarted,
  IssueWorkflowStatus.workInProgress,
  IssueWorkflowStatus.workCompleted,
  IssueWorkflowStatus.citizenVerification,
  IssueWorkflowStatus.issueClosed,
];

enum IssueWorkflowStatus {
  issueCreated,
  departmentAssigned,
  officerAccepted,
  inspectionScheduled,
  workStarted,
  workInProgress,
  workCompleted,
  citizenVerification,
  issueClosed,
  unknown,
}

enum StageCompletionState { completed, current, pending }

extension IssueWorkflowStatusX on IssueWorkflowStatus {
  String get title {
    switch (this) {
      case IssueWorkflowStatus.issueCreated:
        return 'Issue Created';
      case IssueWorkflowStatus.departmentAssigned:
        return 'Department Assigned';
      case IssueWorkflowStatus.officerAccepted:
        return 'Officer Accepted';
      case IssueWorkflowStatus.inspectionScheduled:
        return 'Inspection Scheduled';
      case IssueWorkflowStatus.workStarted:
        return 'Work Started';
      case IssueWorkflowStatus.workInProgress:
        return 'Work In Progress';
      case IssueWorkflowStatus.workCompleted:
        return 'Work Completed';
      case IssueWorkflowStatus.citizenVerification:
        return 'Citizen Verification';
      case IssueWorkflowStatus.issueClosed:
        return 'Issue Closed';
      case IssueWorkflowStatus.unknown:
        return 'Unknown';
    }
  }
}

IssueWorkflowStatus parseWorkflowStatus(String raw) {
  final String normalized = raw.toLowerCase().trim();

  if (normalized.contains('issue created') || normalized == 'submitted') {
    return IssueWorkflowStatus.issueCreated;
  }
  if (normalized.contains('department assigned') || normalized == 'assigned') {
    return IssueWorkflowStatus.departmentAssigned;
  }
  if (normalized.contains('officer accepted') || normalized == 'accepted') {
    return IssueWorkflowStatus.officerAccepted;
  }
  if (normalized.contains('inspection scheduled') ||
      normalized == 'inspection') {
    return IssueWorkflowStatus.inspectionScheduled;
  }
  if (normalized.contains('work started') || normalized == 'started') {
    return IssueWorkflowStatus.workStarted;
  }
  if (normalized.contains('work in progress') ||
      normalized == 'in progress' ||
      normalized == 'under review') {
    return IssueWorkflowStatus.workInProgress;
  }
  if (normalized.contains('work completed') || normalized == 'resolved') {
    return IssueWorkflowStatus.workCompleted;
  }
  if (normalized.contains('citizen verification') ||
      normalized == 'verification') {
    return IssueWorkflowStatus.citizenVerification;
  }
  if (normalized.contains('issue closed') || normalized == 'closed') {
    return IssueWorkflowStatus.issueClosed;
  }

  return IssueWorkflowStatus.unknown;
}

DateTime parseDateTime(dynamic raw, {required DateTime fallback}) {
  if (raw is Timestamp) {
    return raw.toDate();
  }
  if (raw is DateTime) {
    return raw;
  }
  if (raw is int) {
    return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true).toLocal();
  }
  if (raw is String) {
    final DateTime? parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return parsed;
    }
  }
  return fallback;
}

String normalizeStatusKey(String raw) {
  return raw.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '_');
}

class WorkflowStageConfig {
  const WorkflowStageConfig({
    required this.statusKey,
    required this.title,
    required this.description,
    required this.currentAction,
    required this.nextAction,
    required this.statusColor,
    required this.statusIcon,
  });

  final String statusKey;
  final String title;
  final String description;
  final String currentAction;
  final String nextAction;
  final String statusColor;
  final String statusIcon;

  factory WorkflowStageConfig.fromMap(Map<String, dynamic> map) {
    final String rawKey =
        (map['statusKey'] ?? map['status'] ?? map['key'] ?? '') as String;
    final String normalized = normalizeStatusKey(rawKey);
    return WorkflowStageConfig(
      statusKey: normalized,
      title: (map['title'] ?? map['name'] ?? rawKey) as String,
      description: (map['description'] ?? '') as String,
      currentAction: (map['currentAction'] ?? '') as String,
      nextAction: (map['nextAction'] ?? '') as String,
      statusColor: (map['statusColor'] ?? '') as String,
      statusIcon: (map['statusIcon'] ?? '') as String,
    );
  }
}

class TrackedIssueStage {
  const TrackedIssueStage({
    required this.statusKey,
    required this.status,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.department,
    required this.assignedOfficer,
    required this.currentAction,
    required this.nextAction,
    required this.statusColor,
    required this.statusIcon,
    required this.completionState,
    required this.remarks,
    required this.images,
    required this.videos,
    required this.documents,
  });

  final String statusKey;
  final IssueWorkflowStatus status;
  final String title;
  final String description;
  final DateTime? timestamp;
  final String department;
  final String assignedOfficer;
  final String currentAction;
  final String nextAction;
  final String statusColor;
  final String statusIcon;
  final StageCompletionState completionState;
  final String remarks;
  final List<String> images;
  final List<String> videos;
  final List<String> documents;
}

class IssueTimelineEvent {
  const IssueTimelineEvent({
    required this.status,
    required this.title,
    required this.timestamp,
    required this.updatedBy,
    required this.department,
    required this.officerName,
    required this.remarks,
    required this.latitude,
    required this.longitude,
    required this.photoAttachments,
    required this.videoAttachments,
    required this.auditLogs,
  });

  final IssueWorkflowStatus status;
  final String title;
  final DateTime timestamp;
  final String updatedBy;
  final String? department;
  final String? officerName;
  final String? remarks;
  final double? latitude;
  final double? longitude;
  final List<String> photoAttachments;
  final List<String> videoAttachments;
  final List<String> auditLogs;

  factory IssueTimelineEvent.fromMap(
    Map<String, dynamic> map, {
    required DateTime fallbackTime,
    String? inheritedDepartment,
    String? inheritedOfficer,
    List<String> inheritedAuditLogs = const <String>[],
  }) {
    final String rawStatus =
        (map['status'] ?? map['currentStatus'] ?? '') as String;
    final IssueWorkflowStatus status = parseWorkflowStatus(rawStatus);
    return IssueTimelineEvent(
      status: status,
      title: status == IssueWorkflowStatus.unknown
          ? (rawStatus.isEmpty ? 'Update' : rawStatus)
          : status.title,
      timestamp: parseDateTime(map['timestamp'], fallback: fallbackTime),
      updatedBy: (map['updatedBy'] ?? map['actor'] ?? 'System') as String,
      department: (map['department'] ?? inheritedDepartment) as String?,
      officerName:
          (map['officer'] ?? map['officerName'] ?? inheritedOfficer) as String?,
      remarks: (map['remarks'] ?? map['message']) as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      photoAttachments: List<String>.from(
        map['photoAttachments'] as List<dynamic>? ??
            map['imageUrls'] as List<dynamic>? ??
            <String>[],
      ),
      videoAttachments: List<String>.from(
        map['videoAttachments'] as List<dynamic>? ??
            map['videoUrls'] as List<dynamic>? ??
            <String>[],
      ),
      auditLogs: List<String>.from(
        map['auditLog'] as List<dynamic>? ??
            map['auditLogs'] as List<dynamic>? ??
            inheritedAuditLogs,
      ),
    );
  }
}

class TrackedIssue {
  const TrackedIssue({
    required this.issueId,
    required this.userId,
    required this.referenceNumber,
    required this.submissionChannel,
    required this.createdBy,
    required this.complaintType,
    required this.visibility,
    required this.queuePosition,
    required this.currentSla,
    required this.verificationStatus,
    required this.resolutionCategory,
    required this.escalationLevel,
    required this.issueTitle,
    required this.category,
    required this.priority,
    required this.currentStatus,
    required this.department,
    required this.assignedOfficer,
    required this.assignedOfficerDesignation,
    required this.assignedOfficerEmployeeId,
    required this.assignedOfficerPhone,
    required this.assignedOfficerEmail,
    required this.assignedOfficerExtension,
    required this.assignedOfficerAvailability,
    required this.assignedOfficerOfficeLocation,
    required this.taggedAuthorityName,
    required this.taggedAuthorityDesignation,
    required this.taggedAuthorityDepartment,
    required this.taggedAuthorityArea,
    required this.taggedAuthorityVerified,
    required this.taggedAuthorityMobile,
    required this.taggedAuthorityOfficePhone,
    required this.taggedAuthorityEmail,
    required this.taggedAuthorityProfileUrl,
    required this.taggedAuthorityProfiles,
    required this.assignedAuthorities,
    required this.transferredAuthorities,
    required this.officerAvatarUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.expectedResolutionAt,
    required this.resolvedAt,
    required this.address,
    required this.locationComponents,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.videoUrls,
    required this.auditLogs,
    required this.timeline,
    required this.progressStages,
  });

  final String issueId;
  final String userId;
  final String? referenceNumber;
  final String? submissionChannel;
  final String? createdBy;
  final String? complaintType;
  final String? visibility;
  final int? queuePosition;
  final String? currentSla;
  final String? verificationStatus;
  final String? resolutionCategory;
  final String? escalationLevel;
  final String? issueTitle;
  final String category;
  final String priority;
  final IssueWorkflowStatus currentStatus;
  final String department;
  final String assignedOfficer;
  final String? assignedOfficerDesignation;
  final String? assignedOfficerEmployeeId;
  final String? assignedOfficerPhone;
  final String? assignedOfficerEmail;
  final String? assignedOfficerExtension;
  final String? assignedOfficerAvailability;
  final String? assignedOfficerOfficeLocation;
  final String? taggedAuthorityName;
  final String? taggedAuthorityDesignation;
  final String? taggedAuthorityDepartment;
  final String? taggedAuthorityArea;
  final bool taggedAuthorityVerified;
  final String? taggedAuthorityMobile;
  final String? taggedAuthorityOfficePhone;
  final String? taggedAuthorityEmail;
  final String? taggedAuthorityProfileUrl;
  final List<TrackedAuthorityProfile> taggedAuthorityProfiles;
  final List<String> assignedAuthorities;
  final List<String> transferredAuthorities;
  final String? officerAvatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime expectedResolutionAt;
  final DateTime? resolvedAt;
  final String address;
  final Map<String, String> locationComponents;
  final double? latitude;
  final double? longitude;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final List<String> auditLogs;
  final List<IssueTimelineEvent> timeline;
  final List<TrackedIssueStage> progressStages;

  TrackedIssueStage? get currentStage {
    for (final TrackedIssueStage stage in progressStages) {
      if (stage.completionState == StageCompletionState.current) {
        return stage;
      }
    }
    if (progressStages.isEmpty) {
      return null;
    }
    return progressStages.last;
  }

  int get currentStatusIndex {
    final int idx = workflowOrder.indexOf(currentStatus);
    if (idx < 0) {
      return 0;
    }
    return idx;
  }

  double get progress {
    if (progressStages.isNotEmpty) {
      final int current = progressStages.indexWhere(
        (TrackedIssueStage stage) =>
            stage.completionState == StageCompletionState.current,
      );
      if (current >= 0) {
        return (current + 1) / progressStages.length;
      }
      final int completed = progressStages
          .where(
            (TrackedIssueStage stage) =>
                stage.completionState == StageCompletionState.completed,
          )
          .length;
      return completed / progressStages.length;
    }
    if (workflowOrder.isEmpty) {
      return 0;
    }
    return (currentStatusIndex + 1) / workflowOrder.length;
  }

  bool get isClosed => currentStatus == IssueWorkflowStatus.issueClosed;

  bool get isDelayed =>
      !isClosed && DateTime.now().isAfter(expectedResolutionAt);

  int get delayDays {
    if (!isDelayed) {
      return 0;
    }
    return DateTime.now().difference(expectedResolutionAt).inDays + 1;
  }

  factory TrackedIssue.fromFirestore(Map<String, dynamic> map) {
    final DateTime createdAt = parseDateTime(
      map['createdAt'],
      fallback: DateTime.now(),
    );
    final DateTime updatedAt = parseDateTime(
      map['updatedAt'],
      fallback: createdAt,
    );

    final String priority = (map['priority'] ?? 'Medium') as String;
    final DateTime expectedResolutionAt = parseDateTime(
      map['expectedResolutionAt'],
      fallback: _calculateExpectedResolution(createdAt, priority),
    );

    final List<String> auditLogs = List<String>.from(
      map['auditLogs'] as List<dynamic>? ?? <String>[],
    );

    final List<Map<String, dynamic>> rawTimeline =
        (map['timeline'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);

    final List<IssueTimelineEvent> timeline =
        rawTimeline
            .map(
              (Map<String, dynamic> event) => IssueTimelineEvent.fromMap(
                event,
                fallbackTime: updatedAt,
                inheritedDepartment: map['department'] as String?,
                inheritedOfficer: map['assignedOfficer'] as String?,
                inheritedAuditLogs: auditLogs,
              ),
            )
            .toList(growable: false)
          ..sort((IssueTimelineEvent a, IssueTimelineEvent b) {
            return a.timestamp.compareTo(b.timestamp);
          });

    final String statusRaw = (map['currentStatus'] ?? 'Submitted') as String;
    IssueWorkflowStatus currentStatus = parseWorkflowStatus(statusRaw);
    if (currentStatus == IssueWorkflowStatus.unknown && timeline.isNotEmpty) {
      final IssueWorkflowStatus inferred = timeline.last.status;
      if (inferred != IssueWorkflowStatus.unknown) {
        currentStatus = inferred;
      }
    }

    final List<WorkflowStageConfig> stageConfigs = _parseStageConfigs(map);
    final List<TrackedIssueStage> progressStages = _buildProgressStages(
      map: map,
      currentStatusRaw: statusRaw,
      currentStatus: currentStatus,
      timeline: timeline,
      stageConfigs: stageConfigs,
    );

    return TrackedIssue(
      issueId: (map['issueId'] ?? '') as String,
      userId: (map['userId'] ?? '') as String,
      referenceNumber: _stringOrNull(
        map['referenceNumber'] ?? map['complaintReferenceNumber'] ?? map['referenceNo'],
      ),
      submissionChannel: _stringOrNull(map['submissionChannel'] ?? map['source']),
      createdBy: _stringOrNull(map['createdBy'] ?? map['createdByName'] ?? map['userName']),
      complaintType: _stringOrNull(map['complaintType'] ?? map['issueType']),
      visibility: _stringOrNull(map['visibility'] ?? map['citizenVisibility']),
      queuePosition: (map['queuePosition'] as num?)?.toInt(),
      currentSla: _stringOrNull(map['currentSla'] ?? map['slaStatus']),
      verificationStatus: _stringOrNull(map['verificationStatus']),
      resolutionCategory: _stringOrNull(map['resolutionCategory']),
      escalationLevel: _stringOrNull(map['escalationLevel']),
      issueTitle: _stringOrNull(map['title'] ?? map['issueTitle'] ?? map['complaintTitle']),
      category: (map['categoryTitle'] ?? 'Issue') as String,
      priority: priority,
      currentStatus: currentStatus,
      department: (map['department'] ?? 'Unassigned') as String,
      assignedOfficer: (map['assignedOfficer'] ?? 'Unassigned') as String,
      assignedOfficerDesignation: _stringOrNull(
        map['assignedOfficerDesignation'] ?? map['officerDesignation'],
      ),
      assignedOfficerEmployeeId: _stringOrNull(
        map['assignedOfficerEmployeeId'] ?? map['employeeId'],
      ),
      assignedOfficerPhone: _stringOrNull(
        map['assignedOfficerPhone'] ?? map['officerPhone'] ?? map['authorityPhone'],
      ),
      assignedOfficerEmail: _stringOrNull(
        map['assignedOfficerEmail'] ?? map['officerEmail'] ?? map['authorityEmail'],
      ),
      assignedOfficerExtension: _stringOrNull(
        map['assignedOfficerExtension'] ?? map['officeExtension'],
      ),
      assignedOfficerAvailability: _stringOrNull(
        map['assignedOfficerAvailability'] ?? map['officerAvailability'],
      ),
      assignedOfficerOfficeLocation: _stringOrNull(
        map['assignedOfficerOfficeLocation'] ?? map['officerOfficeLocation'],
      ),
      taggedAuthorityName: _stringOrNull(
        (map['primaryAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['name'] ??
            (map['taggedAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['name'],
      ),
      taggedAuthorityDesignation: _stringOrNull(
        (map['primaryAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['designation'] ??
            (map['taggedAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['designation'],
      ),
      taggedAuthorityDepartment: _stringOrNull(
        (map['primaryAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['department'] ??
            (map['taggedAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['department'],
      ),
      taggedAuthorityArea: _stringOrNull(
        (map['primaryAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['constituency'] ??
            (map['taggedAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['ward'] ??
            (map['taggedAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['area'],
      ),
      taggedAuthorityVerified:
          ((map['primaryAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['isVerified']
              as bool?) ??
          ((map['taggedAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['isVerified']
              as bool?) ??
          true,
      taggedAuthorityMobile: _stringOrNull(
        (map['primaryAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['mobile'] ??
            (map['taggedAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['mobile'] ??
            (map['taggedAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['publicContact'],
      ),
      taggedAuthorityOfficePhone: _stringOrNull(
        (map['primaryAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['officePhone'] ??
            (map['taggedAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['officePhone'],
      ),
      taggedAuthorityEmail: _stringOrNull(
        (map['primaryAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['email'] ??
            (map['taggedAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['email'],
      ),
      taggedAuthorityProfileUrl: _stringOrNull(
        (map['primaryAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['profilePhotoUrl'] ??
            (map['taggedAuthority'] as Map<String, dynamic>? ?? <String, dynamic>{})['profilePhotoUrl'],
      ),
      taggedAuthorityProfiles: _parseTaggedAuthorityProfiles(map),
      assignedAuthorities: _parseTaggedAuthorities(map),
      transferredAuthorities: _parseTransferredAuthorities(map),
      officerAvatarUrl: map['officerAvatarUrl'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
      expectedResolutionAt: expectedResolutionAt,
      resolvedAt: map['resolvedAt'] == null
          ? null
          : parseDateTime(map['resolvedAt'], fallback: updatedAt),
        address: ((map['address'] ??
              (map['location'] as Map<String, dynamic>? ??
                <String, dynamic>{})['formattedAddress']) ??
            '')
          as String,
        locationComponents: _parseLocationComponents(map),
        latitude: ((map['latitude'] as num?) ??
            ((map['location'] as Map<String, dynamic>? ??
              <String, dynamic>{})['latitude'] as num?))
          ?.toDouble(),
        longitude: ((map['longitude'] as num?) ??
            ((map['location'] as Map<String, dynamic>? ??
              <String, dynamic>{})['longitude'] as num?))
          ?.toDouble(),
      imageUrls: List<String>.from(
        map['imageUrls'] as List<dynamic>? ?? <String>[],
      ),
      videoUrls: List<String>.from(
        map['videoUrls'] as List<dynamic>? ?? <String>[],
      ),
      auditLogs: auditLogs,
      timeline: timeline,
      progressStages: progressStages,
    );
  }

  static List<String> _parseTaggedAuthorities(Map<String, dynamic> map) {
    final List<dynamic> raw =
        (map['taggedAuthorities'] as List<dynamic>? ?? <dynamic>[]);
    final List<String> names = raw
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => (item['name'] ?? '') as String)
        .where((String name) => name.trim().isNotEmpty)
        .toList(growable: false);

    if (names.isNotEmpty) {
      return names;
    }

    final Map<String, dynamic>? primary =
        map['primaryAuthority'] as Map<String, dynamic>?;
    final List<dynamic> secondary =
        (map['secondaryAuthorities'] as List<dynamic>? ?? <dynamic>[]);

    final List<String> fallback = <String>[];
    final String primaryName = (primary?['name'] ?? '') as String;
    if (primaryName.trim().isNotEmpty) {
      fallback.add(primaryName);
    }
    for (final dynamic item in secondary) {
      if (item is Map<String, dynamic>) {
        final String name = (item['name'] ?? '') as String;
        if (name.trim().isNotEmpty) {
          fallback.add(name);
        }
      }
    }
    return fallback;
  }

  static List<TrackedAuthorityProfile> _parseTaggedAuthorityProfiles(
    Map<String, dynamic> map,
  ) {
    final List<dynamic> tagged =
        (map['taggedAuthorities'] as List<dynamic>? ?? <dynamic>[]);
    final List<TrackedAuthorityProfile> parsed = tagged
        .whereType<Map<String, dynamic>>()
        .map(TrackedAuthorityProfile.fromMap)
        .where((TrackedAuthorityProfile item) => item.name.trim().isNotEmpty)
        .toList(growable: false);
    if (parsed.isNotEmpty) {
      return parsed;
    }

    final List<TrackedAuthorityProfile> fallback = <TrackedAuthorityProfile>[];
    final Map<String, dynamic>? primary =
        map['primaryAuthority'] as Map<String, dynamic>?;
    if (primary != null) {
      final TrackedAuthorityProfile p = TrackedAuthorityProfile.fromMap(primary);
      if (p.name.trim().isNotEmpty) {
        fallback.add(p);
      }
    }

    final List<dynamic> secondary =
        (map['secondaryAuthorities'] as List<dynamic>? ?? <dynamic>[]);
    for (final dynamic item in secondary) {
      if (item is Map<String, dynamic>) {
        final TrackedAuthorityProfile authority =
            TrackedAuthorityProfile.fromMap(item);
        if (authority.name.trim().isNotEmpty) {
          fallback.add(authority);
        }
      }
    }
    return fallback;
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    final String text = '$value'.trim();
    return text.isEmpty ? null : text;
  }

  static List<String> _parseTransferredAuthorities(Map<String, dynamic> map) {
    final List<dynamic> raw =
        (map['transferHistory'] as List<dynamic>? ?? <dynamic>[]);
    return raw
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => (item['toAuthority'] ?? '') as String)
        .where((String value) => value.trim().isNotEmpty)
        .toList(growable: false);
  }

  static Map<String, String> _parseLocationComponents(Map<String, dynamic> map) {
    final Map<String, dynamic> root =
        map['locationComponents'] as Map<String, dynamic>? ??
        (map['location'] as Map<String, dynamic>? ?? <String, dynamic>{})['components']
            as Map<String, dynamic>? ??
        <String, dynamic>{};

    return root.map(
      (String key, dynamic value) => MapEntry(key, '${value ?? ''}'),
    )..removeWhere((String _, String value) => value.trim().isEmpty);
  }

  static List<WorkflowStageConfig> _parseStageConfigs(
    Map<String, dynamic> map,
  ) {
    final List<WorkflowStageConfig> output = <WorkflowStageConfig>[];

    final List<dynamic> topLevel =
        (map['workflowStages'] as List<dynamic>? ?? <dynamic>[]).toList();
    for (final dynamic raw in topLevel) {
      if (raw is Map<String, dynamic>) {
        output.add(WorkflowStageConfig.fromMap(raw));
      }
    }

    final Map<String, dynamic> workflowConfig = Map<String, dynamic>.from(
      map['workflowConfig'] as Map<String, dynamic>? ??
          map['workflowConfigResolved'] as Map<String, dynamic>? ??
          <String, dynamic>{},
    );
    final List<dynamic> configStages =
        (workflowConfig['stages'] as List<dynamic>? ?? <dynamic>[]).toList();
    for (final dynamic raw in configStages) {
      if (raw is Map<String, dynamic>) {
        output.add(WorkflowStageConfig.fromMap(raw));
      }
    }

    final Map<String, WorkflowStageConfig> dedup =
        <String, WorkflowStageConfig>{};
    for (final WorkflowStageConfig cfg in output) {
      if (cfg.statusKey.isNotEmpty) {
        dedup[cfg.statusKey] = cfg;
      }
    }
    return dedup.values.toList(growable: false);
  }

  static List<TrackedIssueStage> _buildProgressStages({
    required Map<String, dynamic> map,
    required String currentStatusRaw,
    required IssueWorkflowStatus currentStatus,
    required List<IssueTimelineEvent> timeline,
    required List<WorkflowStageConfig> stageConfigs,
  }) {
    final Map<String, WorkflowStageConfig> configByKey =
        <String, WorkflowStageConfig>{
          for (final WorkflowStageConfig cfg in stageConfigs) cfg.statusKey: cfg,
        };

    final Map<String, IssueTimelineEvent> latestEventByKey =
        <String, IssueTimelineEvent>{};
    for (final IssueTimelineEvent event in timeline) {
      latestEventByKey[normalizeStatusKey(event.title)] = event;
      latestEventByKey[event.status.name] = event;
    }

    final List<String> stageKeys = <String>[];
    stageKeys.addAll(configByKey.keys);
    for (final IssueTimelineEvent event in timeline) {
      final String key = event.status == IssueWorkflowStatus.unknown
          ? normalizeStatusKey(event.title)
          : event.status.name;
      if (!stageKeys.contains(key) && key.isNotEmpty) {
        stageKeys.add(key);
      }
    }

    final String currentKeyRaw =
        (map['currentStatusKey'] as String? ?? currentStatusRaw);
    final String currentKey = normalizeStatusKey(currentKeyRaw);
    if (currentKey.isNotEmpty && !stageKeys.contains(currentKey)) {
      stageKeys.add(currentKey);
    }

    if (stageKeys.isEmpty) {
      stageKeys.addAll(workflowOrder.map((IssueWorkflowStatus s) => s.name));
    }

    int currentIndex = stageKeys.indexOf(currentKey);
    if (currentIndex < 0) {
      currentIndex = stageKeys.indexWhere((String key) {
        return parseWorkflowStatus(key) == currentStatus;
      });
    }
    if (currentIndex < 0) {
      currentIndex = 0;
    }

    final String fallbackDepartment = (map['department'] ?? 'Unassigned') as String;
    final String fallbackOfficer =
        (map['assignedOfficer'] ?? 'Unassigned') as String;

    final List<TrackedIssueStage> stages = <TrackedIssueStage>[];
    for (int i = 0; i < stageKeys.length; i++) {
      final String key = stageKeys[i];
      final WorkflowStageConfig? config = configByKey[key];
      final IssueTimelineEvent? event = latestEventByKey[key];
      final StageCompletionState completionState = i < currentIndex
          ? StageCompletionState.completed
          : (i == currentIndex
                ? StageCompletionState.current
                : StageCompletionState.pending);

      final String rawTitle =
          config?.title ?? event?.title ?? key.replaceAll('_', ' ');
      final String title = rawTitle
          .split(' ')
          .where((String part) => part.isNotEmpty)
          .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
          .join(' ');

      final List<String> docs = List<String>.from(
        map['documents'] as List<dynamic>? ?? <String>[],
      );

      stages.add(
        TrackedIssueStage(
          statusKey: key,
          status: event?.status ?? parseWorkflowStatus(key),
          title: title,
          description: (config?.description ?? event?.remarks ?? '').trim(),
          timestamp: event?.timestamp,
          department: event?.department ?? fallbackDepartment,
          assignedOfficer: event?.officerName ?? fallbackOfficer,
          currentAction: (config?.currentAction ?? event?.remarks ?? '').trim(),
          nextAction: (config?.nextAction ?? '').trim(),
          statusColor: (config?.statusColor ?? '').trim(),
          statusIcon: (config?.statusIcon ?? '').trim(),
          completionState: completionState,
          remarks: (event?.remarks ?? '').trim(),
          images: event?.photoAttachments ?? <String>[],
          videos: event?.videoAttachments ?? <String>[],
          documents: docs,
        ),
      );
    }

    return stages;
  }

  static DateTime _calculateExpectedResolution(
    DateTime createdAt,
    String priority,
  ) {
    final String p = priority.toLowerCase().trim();
    if (p == 'critical') {
      return createdAt.add(const Duration(days: 1));
    }
    if (p == 'high') {
      return createdAt.add(const Duration(days: 2));
    }
    if (p == 'low') {
      return createdAt.add(const Duration(days: 5));
    }
    return createdAt.add(const Duration(days: 3));
  }
}

class TrackedAuthorityProfile {
  const TrackedAuthorityProfile({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.constituency,
    required this.ward,
    required this.isVerified,
    required this.profilePhotoUrl,
    required this.phoneNumber,
  });

  final String id;
  final String name;
  final String designation;
  final String department;
  final String constituency;
  final String ward;
  final bool isVerified;
  final String? profilePhotoUrl;
  final String? phoneNumber;

  String get areaLabel {
    final String c = constituency.trim();
    if (c.isNotEmpty && c.toLowerCase() != 'n/a') {
      return c;
    }
    final String w = ward.trim();
    if (w.isNotEmpty && w.toLowerCase() != 'n/a') {
      return w;
    }
    return 'Not Available';
  }

  factory TrackedAuthorityProfile.fromMap(Map<String, dynamic> map) {
    return TrackedAuthorityProfile(
      id: (map['id'] ?? '') as String,
      name: (map['name'] ?? 'Not Available') as String,
      designation: (map['designation'] ?? 'Official') as String,
      department: (map['department'] ?? 'Government') as String,
      constituency: (map['constituency'] ?? '') as String,
      ward: (map['ward'] ?? '') as String,
      isVerified: (map['isVerified'] as bool?) ?? true,
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      phoneNumber: (map['publicContact'] ?? map['mobile']) as String?,
    );
  }
}
