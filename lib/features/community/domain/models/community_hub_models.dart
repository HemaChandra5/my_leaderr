import 'package:flutter/foundation.dart';

import '../../../events/models/event_model.dart';

enum CommunityTargetModule {
  communityFeed,
  communityVideos,
  pollFeed,
  communityQuestions,
  events,
  homeFeed,
  discussionFeed,
}

enum CommunityContentType {
  post,
  video,
  photos,
  poll,
  question,
  event,
  announcement,
  location,
  discussion,
}

@immutable
class CommunityDraft {
  const CommunityDraft({required this.actionKey, required this.values});

  final String actionKey;
  final Map<String, dynamic> values;
}

@immutable
class CommunityPublication {
  const CommunityPublication({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targets,
    required this.createdAt,
    required this.authorName,
    this.location,
    this.tags = const <String>[],
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final String description;
  final CommunityContentType type;
  final Set<CommunityTargetModule> targets;
  final DateTime createdAt;
  final String authorName;
  final String? location;
  final List<String> tags;
  final Map<String, dynamic> metadata;
}

@immutable
class CommunityEventDraft {
  const CommunityEventDraft({
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.organizer,
    this.isOnline = false,
    this.registrationDeadline,
  });

  final String title;
  final String description;
  final EventCategory category;
  final DateTime date;
  final String time;
  final String location;
  final String organizer;
  final bool isOnline;
  final DateTime? registrationDeadline;
}
