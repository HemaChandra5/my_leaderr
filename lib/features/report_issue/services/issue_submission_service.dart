import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/authority_profile.dart';
import '../models/issue_category.dart';
import '../models/submitted_issue.dart';
import 'issue_id_service.dart';
import 'issue_notification_service.dart';
import 'media_picker_service.dart';

class IssueSubmissionFailure implements Exception {
  const IssueSubmissionFailure(this.message);

  final String message;
}

class IssueSubmissionRequest {
  const IssueSubmissionRequest({
    required this.userId,
    required this.category,
    required this.description,
    required this.locationText,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.locationComponents,
    required this.locationPlaceId,
    required this.locationTimestamp,
    required this.mediaItems,
    required this.taggedAuthorities,
  });

  final String userId;
  final IssueCategory category;
  final String description;
  final String locationText;
  final double? latitude;
  final double? longitude;
  final String formattedAddress;
  final Map<String, String> locationComponents;
  final String? locationPlaceId;
  final DateTime? locationTimestamp;
  final List<PickedMedia> mediaItems;
  final List<AuthorityProfile> taggedAuthorities;
}

class IssueSubmissionService {
  IssueSubmissionService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    IssueIdService? issueIdService,
    IssueNotificationService? notificationService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _issueIdService = issueIdService ?? const IssueIdService(),
       _notificationService =
           notificationService ??
           IssueNotificationService(firestore: firestore);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final IssueIdService _issueIdService;
  final IssueNotificationService _notificationService;

  Future<SubmittedIssue> submit(IssueSubmissionRequest request) async {
    final String trimmedDescription = request.description.trim();
    final String trimmedLocation = request.locationText.trim();

    final bool duplicate = await _isDuplicate(
      userId: request.userId,
      categoryId: request.category.id,
      description: trimmedDescription,
      location: trimmedLocation,
    );

    final DateTime now = DateTime.now().toUtc();
    final String issueId = await _generateUniqueIssueId();
    final _Coordinate coordinate = _Coordinate.tryParse(trimmedLocation);
    final double? latitude = request.latitude ?? coordinate.latitude;
    final double? longitude = request.longitude ?? coordinate.longitude;
    final String formattedAddress = request.formattedAddress.trim().isEmpty
      ? trimmedLocation
      : request.formattedAddress.trim();

    final List<Reference> uploadedRefs = <Reference>[];
    try {
      final _UploadedMedia uploaded = await _uploadMedia(
        issueId: issueId,
        items: request.mediaItems,
        uploadedRefs: uploadedRefs,
      );

      final List<IssueTimelineEntry> timeline = <IssueTimelineEntry>[
        IssueTimelineEntry(
          status: 'Submitted',
          message: 'Issue submitted by citizen.',
          timestamp: now,
          actor: request.userId,
        ),
        IssueTimelineEntry(
          status: 'Under Review',
          message: 'Issue queued for review.',
          timestamp: now,
          actor: 'System',
        ),
        IssueTimelineEntry(
          status: 'Assigned',
          message: 'Issue will be assigned to an officer.',
          timestamp: now,
          actor: 'System',
        ),
        IssueTimelineEntry(
          status: 'In Progress',
          message: 'Work in progress once officer accepts.',
          timestamp: now,
          actor: 'System',
        ),
        IssueTimelineEntry(
          status: 'Resolved',
          message: 'Issue marked resolved after completion.',
          timestamp: now,
          actor: 'System',
        ),
        IssueTimelineEntry(
          status: 'Closed',
          message: 'Issue closed after citizen confirmation.',
          timestamp: now,
          actor: 'System',
        ),
      ];

      final AuthorityProfile? primaryAuthority =
          request.taggedAuthorities.isEmpty ? null : request.taggedAuthorities.first;
      final List<AuthorityProfile> secondaryAuthorities =
          request.taggedAuthorities.length > 1
          ? request.taggedAuthorities.sublist(1)
          : const <AuthorityProfile>[];

      final SubmittedIssue issue = SubmittedIssue(
        issueId: issueId,
        userId: request.userId,
        categoryId: request.category.id,
        categoryTitle: request.category.title,
        description: trimmedDescription,
        latitude: latitude,
        longitude: longitude,
        address: formattedAddress,
        locationComponents: Map<String, String>.from(request.locationComponents),
        locationPlaceId: request.locationPlaceId,
        locationTimestamp: request.locationTimestamp ?? now,
        imageUrls: uploaded.images,
        videoUrls: uploaded.videos,
        createdAt: now,
        updatedAt: now,
        priority: 'Medium',
        currentStatus: 'Submitted',
        timeline: timeline,
        assignedOfficer: primaryAuthority?.name ?? 'Unassigned',
        primaryAuthority: primaryAuthority?.toMap(),
        secondaryAuthorities: secondaryAuthorities
            .map((AuthorityProfile authority) => authority.toMap())
            .toList(growable: false),
        taggedAuthorities: request.taggedAuthorities
            .map((AuthorityProfile authority) => authority.toMap())
            .toList(growable: false),
        auditLogs: <String>[
          '$now: created by ${request.userId}',
          if (request.taggedAuthorities.isNotEmpty)
            '$now: tagged ${request.taggedAuthorities.length} concerned authorities',
          if (duplicate) '$now: flagged as potential duplicate submission',
        ],
      );

      await _retry(
        action: () async {
          await _firestore
              .collection('issues')
              .doc(issueId)
              .set(<String, dynamic>{
                ...issue.toMap(),
                'notificationTargets': request.taggedAuthorities
                    .map((AuthorityProfile authority) => <String, dynamic>{
                          'authorityId': authority.id,
                          'name': authority.name,
                          'department': authority.department,
                          'designation': authority.designation,
                        })
                    .toList(growable: false),
                'transferHistory': <Map<String, dynamic>>[],
                'location': <String, dynamic>{
                  'latitude': latitude,
                  'longitude': longitude,
                  'placeId': request.locationPlaceId,
                  'timestamp': request.locationTimestamp == null
                      ? Timestamp.fromDate(now)
                      : Timestamp.fromDate(request.locationTimestamp!.toUtc()),
                  'formattedAddress': formattedAddress,
                  'components': request.locationComponents,
                },
                'fingerprint': _fingerprint(
                  request.userId,
                  request.category.id,
                  trimmedDescription,
                  trimmedLocation,
                ),
                'isPotentialDuplicate': duplicate,
              });
        },
      );

      await _notificationService.notifyIssueSubmitted(
        issueId: issue.issueId,
        userId: issue.userId,
        category: issue.categoryTitle,
        createdAt: now,
      );

      return issue;
    } catch (error) {
      for (final Reference ref in uploadedRefs) {
        try {
          await ref.delete();
        } catch (_) {
          // Ignore cleanup errors.
        }
      }

      if (error is FirebaseException) {
        throw IssueSubmissionFailure(_mapFirebaseException(error));
      }

      rethrow;
    }
  }

  Future<_UploadedMedia> _uploadMedia({
    required String issueId,
    required List<PickedMedia> items,
    required List<Reference> uploadedRefs,
  }) async {
    final List<String> imageUrls = <String>[];
    final List<String> videoUrls = <String>[];

    for (final PickedMedia item in items) {
      final File mediaFile = File(item.file.path);
      final String fileName = mediaFile.uri.pathSegments.isEmpty
          ? '${DateTime.now().microsecondsSinceEpoch}'
          : mediaFile.uri.pathSegments.last;
      final String path = item.type == PickedMediaType.image
          ? 'issues/$issueId/images/$fileName'
          : 'issues/$issueId/videos/$fileName';

      final Reference ref = _storage.ref().child(path);
      uploadedRefs.add(ref);

      await _retry(
        action: () async {
          await ref.putFile(mediaFile);
        },
      );

      final String url = await _retry(action: () => ref.getDownloadURL());
      if (item.type == PickedMediaType.image) {
        imageUrls.add(url);
      } else {
        videoUrls.add(url);
      }
    }

    return _UploadedMedia(images: imageUrls, videos: videoUrls);
  }

  Future<bool> _isDuplicate({
    required String userId,
    required String categoryId,
    required String description,
    required String location,
  }) async {
    final String key = _fingerprint(userId, categoryId, description, location);
    final DateTime threshold = DateTime.now().toUtc().subtract(
      const Duration(minutes: 30),
    );

    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _firestore
          .collection('issues')
          .where('fingerprint', isEqualTo: key)
          .limit(5)
          .get();
    } on FirebaseException catch (error) {
      throw IssueSubmissionFailure(_mapFirebaseException(error));
    }

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data();
      final Timestamp? createdAt = data['createdAt'] as Timestamp?;
      if (createdAt == null) {
        return true;
      }
      if (createdAt.toDate().toUtc().isAfter(threshold)) {
        return true;
      }
    }

    return false;
  }

  String _fingerprint(
    String userId,
    String categoryId,
    String description,
    String location,
  ) {
    return '${userId.trim()}|${categoryId.trim()}|${description.trim().toLowerCase()}|${location.trim().toLowerCase()}';
  }

  Future<String> _generateUniqueIssueId() async {
    for (int i = 0; i < 6; i++) {
      final String id = _issueIdService.generate();
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('issues')
          .doc(id)
          .get();
      if (!doc.exists) {
        return id;
      }
    }
    throw const IssueSubmissionFailure('Unable to generate unique issue id.');
  }

  Future<T> _retry<T>({
    required Future<T> Function() action,
    int maxAttempts = 3,
  }) async {
    Object? lastError;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await action();
      } catch (error) {
        lastError = error;
        if (attempt == maxAttempts - 1) {
          break;
        }
      }
    }
    if (lastError is FirebaseException) {
      throw IssueSubmissionFailure(_mapFirebaseException(lastError));
    }
    throw const IssueSubmissionFailure(
      'Operation failed. Please try again in a few moments.',
    );
  }

  String _mapFirebaseException(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'You do not have permission to submit this issue.';
      case 'unauthenticated':
        return 'Please log in again and retry submission.';
      case 'unavailable':
      case 'network-request-failed':
        return 'Network is unavailable. Please check internet and try again.';
      case 'deadline-exceeded':
        return 'Request timed out. Please retry.';
      case 'failed-precondition':
        return 'Backend configuration is incomplete. Please contact support.';
      case 'object-not-found':
        return 'A media file could not be uploaded. Please re-attach and retry.';
      case 'cancelled':
        return 'Submission was cancelled. Please try again.';
      default:
        return 'Unable to submit issue right now. Please try again.';
    }
  }
}

class _UploadedMedia {
  const _UploadedMedia({required this.images, required this.videos});

  final List<String> images;
  final List<String> videos;
}

class _Coordinate {
  const _Coordinate({required this.latitude, required this.longitude});

  final double? latitude;
  final double? longitude;

  static _Coordinate tryParse(String input) {
    final List<String> parts = input.split(',');
    if (parts.length != 2) {
      return const _Coordinate(latitude: null, longitude: null);
    }

    final double? lat = double.tryParse(parts[0].trim());
    final double? lng = double.tryParse(parts[1].trim());
    return _Coordinate(latitude: lat, longitude: lng);
  }
}
