import 'package:flutter/material.dart';

import '../../events/models/event_model.dart';
import '../domain/models/community_hub_models.dart';
import '../domain/repositories/community_hub_repository.dart';

class CommunityHubController extends ChangeNotifier {
  CommunityHubController({CommunityHubRepository? repository})
    : _repository = repository ?? CommunityHubRepository();

  final CommunityHubRepository _repository;

  final List<CommunityPublication> _communityFeed = <CommunityPublication>[];
  final List<CommunityPublication> _communityVideos = <CommunityPublication>[];
  final List<CommunityPublication> _pollFeed = <CommunityPublication>[];
  final List<CommunityPublication> _communityQuestions =
      <CommunityPublication>[];
  final List<CommunityPublication> _homeAnnouncements =
      <CommunityPublication>[];
  final List<CommunityPublication> _discussionFeed = <CommunityPublication>[];
  final List<EventModel> _createdEvents = <EventModel>[];

  List<CommunityPublication> get communityFeed =>
      List<CommunityPublication>.unmodifiable(_communityFeed);
  List<CommunityPublication> get communityVideos =>
      List<CommunityPublication>.unmodifiable(_communityVideos);
  List<CommunityPublication> get pollFeed =>
      List<CommunityPublication>.unmodifiable(_pollFeed);
  List<CommunityPublication> get communityQuestions =>
      List<CommunityPublication>.unmodifiable(_communityQuestions);
  List<CommunityPublication> get homeAnnouncements =>
      List<CommunityPublication>.unmodifiable(_homeAnnouncements);
  List<CommunityPublication> get discussionFeed =>
      List<CommunityPublication>.unmodifiable(_discussionFeed);
  List<EventModel> get createdEvents =>
      List<EventModel>.unmodifiable(_createdEvents);

  CommunityDraft? getDraft(String actionKey) => _repository.loadDraft(actionKey);

  void saveDraft(String actionKey, Map<String, dynamic> values) {
    _repository.saveDraft(CommunityDraft(actionKey: actionKey, values: values));
    notifyListeners();
  }

  void clearDraft(String actionKey) {
    _repository.clearDraft(actionKey);
    notifyListeners();
  }

  void publish(CommunityPublication publication) {
    _repository.publish(publication);

    if (publication.targets.contains(CommunityTargetModule.communityFeed)) {
      _communityFeed.insert(0, publication);
    }
    if (publication.targets.contains(CommunityTargetModule.communityVideos)) {
      _communityVideos.insert(0, publication);
    }
    if (publication.targets.contains(CommunityTargetModule.pollFeed)) {
      _pollFeed.insert(0, publication);
    }
    if (publication.targets.contains(CommunityTargetModule.communityQuestions)) {
      _communityQuestions.insert(0, publication);
    }
    if (publication.targets.contains(CommunityTargetModule.homeFeed)) {
      _homeAnnouncements.insert(0, publication);
    }
    if (publication.targets.contains(CommunityTargetModule.discussionFeed)) {
      _discussionFeed.insert(0, publication);
    }

    notifyListeners();
  }

  EventModel publishEvent(CommunityEventDraft eventDraft) {
    final EventModel model = EventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: eventDraft.title,
      description: eventDraft.description,
      imageUrl:
          'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=1400&q=80',
      category: eventDraft.category,
      date: eventDraft.date,
      time: eventDraft.time,
      location: eventDraft.location,
      organizer: eventDraft.organizer,
      interestedCount: 0,
      status: EventStatus.upcoming,
      isFree: true,
      isOnline: eventDraft.isOnline,
      tags: <EventFilterTag>{
        EventFilterTag.leadership,
        eventDraft.isOnline ? EventFilterTag.online : EventFilterTag.offline,
        EventFilterTag.free,
      },
    );

    _createdEvents.insert(0, model);

    publish(
      CommunityPublication(
        id: 'pub_${model.id}',
        title: model.title,
        description: model.description,
        type: CommunityContentType.event,
        targets: <CommunityTargetModule>{
          CommunityTargetModule.events,
          CommunityTargetModule.communityFeed,
        },
        createdAt: DateTime.now(),
        authorName: model.organizer,
        location: model.location,
        metadata: <String, dynamic>{'category': model.category.label},
      ),
    );

    return model;
  }
}
