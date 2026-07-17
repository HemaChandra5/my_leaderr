import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../report_issue/models/submitted_issue.dart';
import '../domain/entities/track_issue_models.dart';
import '../domain/repositories/track_issue_repository.dart';

class TrackIssueProvider extends ChangeNotifier {
  TrackIssueProvider({required this.repository});

  final TrackIssueRepository repository;

  StreamSubscription<TrackedIssue?>? _subscription;
  Timer? _etaTicker;

  TrackedIssue? _issue;
  String? _issueId;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isSubmittingVerification = false;
  bool _isPreviewMode = false;
  int _timelineVersion = 0;
  String _timelineSignature = '';
  DateTime _now = DateTime.now();

  TrackedIssue? get issue => _issue;
  String? get issueId => _issueId;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isSubmittingVerification => _isSubmittingVerification;
  bool get isPreviewMode => _isPreviewMode;
  int get timelineVersion => _timelineVersion;

  bool get hasIssue => _issue != null;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  bool get canSubmitCitizenVerification {
    final TrackedIssue? current = _issue;
    if (current == null || _isSubmittingVerification || _isPreviewMode) {
      return false;
    }
    return current.currentStatus == IssueWorkflowStatus.citizenVerification ||
        current.currentStatus == IssueWorkflowStatus.workCompleted;
  }

  DateTime get now => _now;

  Duration? get remainingEta {
    final TrackedIssue? current = _issue;
    if (current == null) {
      return null;
    }
    if (current.isClosed) {
      return Duration.zero;
    }
    return current.expectedResolutionAt.difference(_now);
  }

  List<TrackedIssueStage> get progressStages {
    final TrackedIssue? current = _issue;
    if (current == null) {
      return const <TrackedIssueStage>[];
    }
    return current.progressStages;
  }

  TrackedIssueStage? get currentProgressStage {
    final TrackedIssue? current = _issue;
    return current?.currentStage;
  }

  String get progressPercentText {
    final TrackedIssue? current = _issue;
    if (current == null) {
      return '0%';
    }
    return '${(current.progress * 100).round()}%';
  }

  void initialize({
    SubmittedIssue? seedSubmission,
    String? routeIssueId,
    String? currentUserId,
  }) {
    final String? resolvedIssueId = (routeIssueId ?? seedSubmission?.issueId)
        ?.trim();

    if (resolvedIssueId == null || resolvedIssueId.isEmpty) {
      final String userId = (currentUserId ?? '').trim();
      if (userId.isNotEmpty) {
        _loadLatestIssueForUser(userId);
        return;
      }
      loadCategoryWorkflowPreview(category: 'Roads');
      return;
    }

    if (_issueId == resolvedIssueId && _subscription != null) {
      return;
    }

    _issueId = resolvedIssueId;
    _isPreviewMode = false;

    if (seedSubmission != null && _issue == null) {
      _issue = _fallbackFromSubmission(seedSubmission);
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = repository
        .watchIssue(resolvedIssueId)
        .listen(
          (TrackedIssue? remoteIssue) {
            _isLoading = false;
            if (remoteIssue == null) {
              loadCategoryWorkflowPreview(
                category: 'Roads',
                userId: currentUserId,
              );
              return;
            }

            _isPreviewMode = false;
            _errorMessage = null;
            _issue = remoteIssue;

            final String newSignature = _buildTimelineSignature(remoteIssue);
            if (newSignature != _timelineSignature) {
              _timelineSignature = newSignature;
              _timelineVersion++;
            }

            _startEtaTicker();
            notifyListeners();
          },
          onError: (Object error) {
            loadCategoryWorkflowPreview(
              category: 'Roads',
              userId: currentUserId,
            );
          },
        );
  }

  Future<void> _loadLatestIssueForUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final TrackedIssue? latest = await repository.fetchLatestIssueForUser(
        userId,
      );
      if (latest == null || latest.issueId.trim().isEmpty) {
        loadCategoryWorkflowPreview(category: 'Roads', userId: userId);
        return;
      }

      initialize(routeIssueId: latest.issueId, currentUserId: userId);
    } catch (error) {
      loadCategoryWorkflowPreview(category: 'Roads', userId: userId);
    }
  }

  void loadCategoryWorkflowPreview({required String category, String? userId}) {
    _subscription?.cancel();

    final DateTime now = DateTime.now();
    final List<IssueWorkflowStatus> previewFlow = <IssueWorkflowStatus>[
      IssueWorkflowStatus.issueCreated,
      IssueWorkflowStatus.departmentAssigned,
      IssueWorkflowStatus.officerAccepted,
      IssueWorkflowStatus.inspectionScheduled,
      IssueWorkflowStatus.workStarted,
      IssueWorkflowStatus.workInProgress,
    ];

    final List<IssueTimelineEvent> timeline = <IssueTimelineEvent>[];
    final DateTime start = now.subtract(const Duration(days: 2));
    for (int i = 0; i < previewFlow.length; i++) {
      final IssueWorkflowStatus status = previewFlow[i];
      timeline.add(
        IssueTimelineEvent(
          status: status,
          title: status.title,
          timestamp: start.add(Duration(hours: i * 8)),
          updatedBy: i == 0 ? 'Citizen' : 'System',
          department: _departmentForCategory(category),
          officerName: 'Assigned Team',
          remarks: _remarksForStatus(status, category),
          latitude: null,
          longitude: null,
          photoAttachments: const <String>[],
          videoAttachments: const <String>[],
          auditLogs: const <String>[],
        ),
      );
    }

    _issueId = null;
    _isPreviewMode = true;
    _isLoading = false;
    _errorMessage = null;
    _issue = TrackedIssue(
      issueId: 'PREVIEW-${category.toUpperCase().replaceAll(' ', '-')}',
      userId: (userId ?? '').trim(),
      referenceNumber: 'Preview workflow',
      submissionChannel: 'App',
      createdBy: (userId ?? '').trim(),
      complaintType: null,
      visibility: null,
      queuePosition: null,
      currentSla: 'In progress',
      verificationStatus: null,
      resolutionCategory: null,
      escalationLevel: null,
      issueTitle: '$category workflow preview',
      category: category,
      priority: 'Medium',
      currentStatus: IssueWorkflowStatus.workInProgress,
      department: _departmentForCategory(category),
      assignedOfficer: 'Assigned Team',
      assignedOfficerDesignation: 'Field Officer',
      assignedOfficerEmployeeId: null,
      assignedOfficerPhone: null,
      assignedOfficerEmail: null,
      assignedOfficerExtension: null,
      assignedOfficerAvailability: 'Working Hours',
      assignedOfficerOfficeLocation: null,
      taggedAuthorityName: _departmentForCategory(category),
      taggedAuthorityDesignation: 'Department',
      taggedAuthorityDepartment: _departmentForCategory(category),
      taggedAuthorityArea: null,
      taggedAuthorityVerified: true,
      taggedAuthorityMobile: null,
      taggedAuthorityOfficePhone: null,
      taggedAuthorityEmail: null,
      taggedAuthorityProfileUrl: null,
      taggedAuthorityProfiles: const <TrackedAuthorityProfile>[],
      assignedAuthorities: <String>[_departmentForCategory(category)],
      transferredAuthorities: const <String>[],
      officerAvatarUrl: null,
      createdAt: start,
      updatedAt: now,
      expectedResolutionAt: now.add(const Duration(days: 1)),
      resolvedAt: null,
      address: 'Workflow preview mode',
      locationComponents: const <String, String>{},
      latitude: null,
      longitude: null,
      imageUrls: const <String>[],
      videoUrls: const <String>[],
      auditLogs: const <String>[
        'Preview shown because no issue ID was available.',
      ],
      timeline: timeline,
      progressStages: const <TrackedIssueStage>[],
    );
    notifyListeners();
  }

  String _departmentForCategory(String category) {
    final String c = category.toLowerCase();
    if (c.contains('water')) {
      return 'Water Works Department';
    }
    if (c.contains('road')) {
      return 'Roads and Infrastructure Department';
    }
    if (c.contains('electric')) {
      return 'Electrical Maintenance Department';
    }
    if (c.contains('drain')) {
      return 'Drainage Department';
    }
    if (c.contains('garbage') || c.contains('sanitation')) {
      return 'Sanitation Department';
    }
    return 'Public Services Department';
  }

  String _remarksForStatus(IssueWorkflowStatus status, String category) {
    switch (status) {
      case IssueWorkflowStatus.issueCreated:
        return '$category issue registered successfully.';
      case IssueWorkflowStatus.departmentAssigned:
        return 'Issue assigned to ${_departmentForCategory(category)}.';
      case IssueWorkflowStatus.officerAccepted:
        return 'Officer acknowledged the task and started planning.';
      case IssueWorkflowStatus.inspectionScheduled:
        return 'Site inspection slot scheduled by field team.';
      case IssueWorkflowStatus.workStarted:
        return 'Ground work has started for this issue.';
      case IssueWorkflowStatus.workInProgress:
        return 'Work is currently in progress.';
      case IssueWorkflowStatus.workCompleted:
      case IssueWorkflowStatus.citizenVerification:
      case IssueWorkflowStatus.issueClosed:
      case IssueWorkflowStatus.unknown:
        return 'Pending next workflow update.';
    }
  }

  Future<void> refresh() async {
    final String? id = _issueId;
    if (id == null || id.isEmpty || _isRefreshing || _isPreviewMode) {
      return;
    }

    _isRefreshing = true;
    notifyListeners();

    try {
      final TrackedIssue? latest = await repository.fetchIssue(id);
      if (latest == null) {
        _errorMessage = 'Issue not found for ID $id.';
      } else {
        _errorMessage = null;
        _issue = latest;
        final String newSignature = _buildTimelineSignature(latest);
        if (newSignature != _timelineSignature) {
          _timelineSignature = newSignature;
          _timelineVersion++;
        }
      }
    } catch (error) {
      _errorMessage = 'Failed to refresh status: $error';
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<bool> submitCitizenVerification({String? remarks, int? rating}) async {
    final TrackedIssue? current = _issue;
    if (current == null || _isSubmittingVerification) {
      return false;
    }

    _isSubmittingVerification = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String verifiedBy = current.userId.isEmpty
          ? 'Citizen'
          : current.userId;

      await repository.submitCitizenVerification(
        issueId: current.issueId,
        verifiedBy: verifiedBy,
        remarks: remarks,
        rating: rating,
      );

      await refresh();
      return true;
    } catch (error) {
      _errorMessage = 'Unable to submit verification: $error';
      notifyListeners();
      return false;
    } finally {
      _isSubmittingVerification = false;
      notifyListeners();
    }
  }

  void _startEtaTicker() {
    _etaTicker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
  }

  TrackedIssue _fallbackFromSubmission(SubmittedIssue submission) {
    final List<IssueTimelineEvent> events = submission.timeline
        .map((IssueTimelineEntry entry) {
          final IssueWorkflowStatus status = parseWorkflowStatus(entry.status);
          return IssueTimelineEvent(
            status: status,
            title: status == IssueWorkflowStatus.unknown
                ? entry.status
                : status.title,
            timestamp: entry.timestamp,
            updatedBy: entry.actor,
            department: null,
            officerName: submission.assignedOfficer,
            remarks: entry.message,
            latitude: submission.latitude,
            longitude: submission.longitude,
            photoAttachments: submission.imageUrls,
            videoAttachments: submission.videoUrls,
            auditLogs: submission.auditLogs,
          );
        })
        .toList(growable: false);

    return TrackedIssue(
      issueId: submission.issueId,
      userId: submission.userId,
      referenceNumber: submission.issueId,
      submissionChannel: 'App',
      createdBy: submission.userId,
      complaintType: null,
      visibility: null,
      queuePosition: null,
      currentSla: null,
      verificationStatus: null,
      resolutionCategory: null,
      escalationLevel: null,
      issueTitle: null,
      category: submission.categoryTitle,
      priority: submission.priority,
      currentStatus: parseWorkflowStatus(submission.currentStatus),
      department: 'Unassigned',
      assignedOfficer: submission.assignedOfficer,
      assignedOfficerDesignation: null,
      assignedOfficerEmployeeId: null,
      assignedOfficerPhone: null,
      assignedOfficerEmail: null,
      assignedOfficerExtension: null,
      assignedOfficerAvailability: null,
      assignedOfficerOfficeLocation: null,
      taggedAuthorityName: submission.taggedAuthorities.isEmpty
          ? null
          : (submission.taggedAuthorities.first['name'] as String?),
      taggedAuthorityDesignation: submission.taggedAuthorities.isEmpty
          ? null
          : (submission.taggedAuthorities.first['designation'] as String?),
      taggedAuthorityDepartment: submission.taggedAuthorities.isEmpty
          ? null
          : (submission.taggedAuthorities.first['department'] as String?),
      taggedAuthorityArea: null,
      taggedAuthorityVerified: true,
      taggedAuthorityMobile: null,
      taggedAuthorityOfficePhone: null,
      taggedAuthorityEmail: null,
      taggedAuthorityProfileUrl: submission.taggedAuthorities.isEmpty
          ? null
          : (submission.taggedAuthorities.first['profilePhotoUrl'] as String?),
      taggedAuthorityProfiles: submission.taggedAuthorities
          .whereType<Map<String, dynamic>>()
          .map(TrackedAuthorityProfile.fromMap)
          .where((TrackedAuthorityProfile item) => item.name.trim().isNotEmpty)
          .toList(growable: false),
      assignedAuthorities: submission.taggedAuthorities
          .map((Map<String, dynamic> item) => (item['name'] ?? '') as String)
          .where((String name) => name.trim().isNotEmpty)
          .toList(growable: false),
      transferredAuthorities: const <String>[],
      officerAvatarUrl: null,
      createdAt: submission.createdAt,
      updatedAt: submission.updatedAt,
      expectedResolutionAt: submission.createdAt.add(const Duration(days: 3)),
      resolvedAt: null,
      address: submission.address,
      locationComponents: submission.locationComponents,
      latitude: submission.latitude,
      longitude: submission.longitude,
      imageUrls: submission.imageUrls,
      videoUrls: submission.videoUrls,
      auditLogs: submission.auditLogs,
      timeline: events,
      progressStages: const <TrackedIssueStage>[],
    );
  }

  String _buildTimelineSignature(TrackedIssue issue) {
    final String timeline = issue.timeline
        .map(
          (IssueTimelineEvent event) =>
              '${event.status.name}|${event.timestamp.millisecondsSinceEpoch}|${event.remarks ?? ''}',
        )
        .join('~');
    return '${issue.currentStatus.name}|$timeline';
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _etaTicker?.cancel();
    super.dispose();
  }
}
