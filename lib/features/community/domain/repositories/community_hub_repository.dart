import '../models/community_hub_models.dart';

class CommunityHubRepository {
  final Map<String, CommunityDraft> _drafts = <String, CommunityDraft>{};
  final List<CommunityPublication> _publications = <CommunityPublication>[];

  CommunityDraft? loadDraft(String actionKey) {
    return _drafts[actionKey];
  }

  void saveDraft(CommunityDraft draft) {
    _drafts[draft.actionKey] = draft;
  }

  void clearDraft(String actionKey) {
    _drafts.remove(actionKey);
  }

  List<CommunityPublication> get publications =>
      List<CommunityPublication>.unmodifiable(_publications);

  void publish(CommunityPublication publication) {
    _publications.insert(0, publication);
  }
}
