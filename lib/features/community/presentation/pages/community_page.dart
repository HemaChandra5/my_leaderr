import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_language.dart';
import '../../navigation/community_action_routes.dart';
import '../../state/community_hub_controller.dart';
import '../../domain/models/community_hub_models.dart';
import '../../../messaging/models/chat_models.dart';
import '../../../messaging/models/public_user_profile.dart';
import '../../../home/presentation/widgets/bottom_navigation.dart';

const String _eventsRoute = '/events';
const String _trackRoute = '/track';
const String _homeRoute = '/home';
const String _profileRoute = '/profile';
const String _publicProfileRoute = '/public-profile';
const String _chatRoute = '/messages/chat';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final ScrollController _scrollController = ScrollController();

  final List<_CommunityPost> _allPosts = _demoPosts;
  final List<_CommunityPost> _visiblePosts = <_CommunityPost>[];
  final Set<String> _followedTopics = <String>{};
  final Set<String> _bookmarkedPosts = <String>{};
  final Set<String> _likedPosts = <String>{};
  final Set<String> _joinedCommunities = <String>{};
  final Set<String> _joinedOpportunities = <String>{};
  final Set<String> _followedUsers = <String>{};
  final Map<String, int> _selectedPollOption = <String, int>{};

  int _selectedFilter = 0;
  bool _isLoadingMore = false;

  static const int _pageSize = 5;

  @override
  void initState() {
    super.initState();
    _appendNextPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !_scrollController.hasClients) {
      return;
    }
    final double threshold = _scrollController.position.maxScrollExtent - 420;
    if (_scrollController.position.pixels >= threshold) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_visiblePosts.length >= _allPosts.length) {
      return;
    }
    setState(() => _isLoadingMore = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) {
      return;
    }
    setState(() {
      _appendNextPosts();
      _isLoadingMore = false;
    });
  }

  void _appendNextPosts() {
    final int start = _visiblePosts.length;
    final int end = (start + _pageSize).clamp(0, _allPosts.length);
    if (start >= end) {
      return;
    }
    _visiblePosts.addAll(_allPosts.sublist(start, end));
  }

  void _showComposerSheet() {
    Navigator.of(context).pushNamed(CommunityActionRoutes.quickActionsHub);
  }

  void _openQuickAction(_QuickActionItem action) {
    final Map<String, String> actionRouteMap = <String, String>{
      'Create Post': CommunityActionRoutes.createPost,
      'Upload Video': CommunityActionRoutes.uploadVideo,
      'Upload Photos': CommunityActionRoutes.uploadPhotos,
      'Create Poll': CommunityActionRoutes.createPoll,
      'Ask Question': CommunityActionRoutes.askQuestion,
      'Create Event': CommunityActionRoutes.createEvent,
      'Report Issue': _trackRoute,
      'Announcement (Leader)': CommunityActionRoutes.leaderAnnouncement,
      'Share Location': CommunityActionRoutes.shareLocation,
      'Start Discussion': CommunityActionRoutes.discussion,
    };

    final String route = actionRouteMap[action.label] ?? CommunityActionRoutes.quickActionsHub;
    Navigator.of(context).pushNamed(route);
  }

  void _openPublicProfile(String userId, String name) {
    Navigator.of(context).pushNamed(
      _publicProfileRoute,
      arguments: PublicProfileRouteArgs(userId: userId, displayName: name),
    );
  }

  void _openChat(String userId, String name) {
    final String initials = name
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .take(2)
        .map((String part) => part[0].toUpperCase())
        .join();

    Navigator.of(context).pushNamed(
      _chatRoute,
      arguments: ChatRouteArgs(
        conversationId: 'community_$userId',
        peerUserId: userId,
        peerName: name,
        peerInitials: initials.isEmpty ? 'ML' : initials,
        isVerified: true,
      ),
    );
  }

  void _handleBottomNavSelection(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(_homeRoute);
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(_trackRoute);
      return;
    }

    if (index == 2) {
      return;
    }

    if (index == 3) {
      Navigator.of(context).pushReplacementNamed(_eventsRoute);
      return;
    }

    Navigator.of(context).pushReplacementNamed(_profileRoute);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLanguage.instance,
      builder: (context, _) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final ColorScheme colors = Theme.of(context).colorScheme;
        final CommunityHubController hub = context.watch<CommunityHubController>();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 450));
                if (!mounted) {
                  return;
                }
                setState(() {
                  _visiblePosts
                    ..clear()
                    ..addAll(_allPosts.take(_pageSize));
                });
              },
              child: ListView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 110),
                children: <Widget>[
                  _HubWelcomeHeader(
                    onSearchTap: () {},
                    onViewNotifications: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications center coming soon'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _SearchCommunitiesField(
                    hintText: 'Search communities, posts, videos, leaders...',
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 14),
                  _SectionTitleRow(
                    title: 'Quick Actions',
                    subtitle: 'Create civic content quickly',
                    trailingLabel: 'View all',
                    onTrailingTap: _showComposerSheet,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickActions.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final _QuickActionItem action = _quickActions[index];
                        return _MiniQuickActionCard(
                          action: action,
                          onTap: () => _openQuickAction(action),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionTitleRow(
                    title: 'Trending Topics',
                    subtitle: 'Follow what matters to your area',
                    trailingLabel: 'Discover',
                    onTrailingTap: () {},
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 74,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _trendingTopics.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final _TopicItem topic = _trendingTopics[index];
                        final bool isFollowed = _followedTopics.contains(
                          topic.label,
                        );
                        return _TopicChipCard(
                          topic: topic,
                          isFollowed: isFollowed,
                          onTap: () {
                            setState(() {
                              if (isFollowed) {
                                _followedTopics.remove(topic.label);
                              } else {
                                _followedTopics.add(topic.label);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionTitleRow(
                    title: 'Filters',
                    subtitle: 'Latest, trending, official and media',
                    trailingLabel: 'Reset',
                    onTrailingTap: () => setState(() => _selectedFilter = 0),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List<Widget>.generate(_filters.length, (int i) {
                      final bool selected = i == _selectedFilter;
                      return ChoiceChip(
                        selected: selected,
                        label: Text(_filters[i]),
                        onSelected: (_) => setState(() => _selectedFilter = i),
                        selectedColor: AppColors.primaryGold.withValues(
                          alpha: 0.2,
                        ),
                        side: BorderSide(color: AppColors.divider),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.primaryGold
                              : AppColors.textPrimary,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitleRow(
                    title: 'Community Impact',
                    subtitle: 'Live civic progress from your local communities',
                    trailingLabel: 'Today',
                    onTrailingTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _CommunityImpactGrid(items: _impactStats),
                  const SizedBox(height: 16),
                  _PinnedAnnouncementCard(
                    title: 'Leader Announcements',
                    message:
                        'Ward meeting on Saturday at 10:00 AM. New road safety volunteers registration is open now.',
                    onProfileTap: () => _openPublicProfile(
                      'leader_ward_94',
                      'Councilor Priya Sharma',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitleRow(
                    title: 'Community Feed',
                    subtitle: 'Citizens, leaders, volunteers and officials',
                    trailingLabel: 'Live',
                    onTrailingTap: () {},
                  ),
                  const SizedBox(height: 10),
                  if (hub.communityFeed.isNotEmpty)
                    ...hub.communityFeed.map(
                      (CommunityPublication item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DynamicCommunityPublicationCard(item: item),
                      ),
                    ),
                  ..._visiblePosts.map(
                    (_CommunityPost post) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CommunityPostCard(
                        post: post,
                        isLiked: _likedPosts.contains(post.id),
                        isBookmarked: _bookmarkedPosts.contains(post.id),
                        selectedPollIndex: _selectedPollOption[post.id],
                        onProfileTap: () =>
                            _openPublicProfile(post.authorId, post.authorName),
                        onMessageTap: () =>
                            _openChat(post.authorId, post.authorName),
                        onLikeTap: () {
                          setState(() {
                            if (_likedPosts.contains(post.id)) {
                              _likedPosts.remove(post.id);
                            } else {
                              _likedPosts.add(post.id);
                            }
                          });
                        },
                        onBookmarkTap: () {
                          setState(() {
                            if (_bookmarkedPosts.contains(post.id)) {
                              _bookmarkedPosts.remove(post.id);
                            } else {
                              _bookmarkedPosts.add(post.id);
                            }
                          });
                        },
                        onFollowTap: () {
                          setState(() {
                            if (_followedUsers.contains(post.authorId)) {
                              _followedUsers.remove(post.authorId);
                            } else {
                              _followedUsers.add(post.authorId);
                            }
                          });
                        },
                        onSelectPoll: (int index) {
                          setState(() => _selectedPollOption[post.id] = index);
                        },
                      ),
                    ),
                  ),
                  if (_isLoadingMore)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: colors.primary,
                          strokeWidth: 2.2,
                        ),
                      ),
                    ),
                  if (hub.communityVideos.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 6),
                    _SectionTitleRow(
                      title: 'Community Videos',
                      subtitle: 'Latest uploaded videos from citizens and leaders',
                      trailingLabel: 'Open',
                      onTrailingTap: () {},
                    ),
                    const SizedBox(height: 8),
                    ...hub.communityVideos.take(4).map(
                      (CommunityPublication item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DynamicCommunityPublicationCard(item: item),
                      ),
                    ),
                  ],
                  if (hub.pollFeed.isNotEmpty) ...<Widget>[
                    _SectionTitleRow(
                      title: 'Poll Feed',
                      subtitle: 'Recently published polls',
                      trailingLabel: 'Vote',
                      onTrailingTap: () {},
                    ),
                    const SizedBox(height: 8),
                    ...hub.pollFeed.take(3).map(
                      (CommunityPublication item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DynamicCommunityPublicationCard(item: item),
                      ),
                    ),
                  ],
                  if (hub.communityQuestions.isNotEmpty) ...<Widget>[
                    _SectionTitleRow(
                      title: 'Community Questions',
                      subtitle: 'Questions that need answers',
                      trailingLabel: 'Answer',
                      onTrailingTap: () {},
                    ),
                    const SizedBox(height: 8),
                    ...hub.communityQuestions.take(3).map(
                      (CommunityPublication item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DynamicCommunityPublicationCard(item: item),
                      ),
                    ),
                  ],
                  if (hub.discussionFeed.isNotEmpty) ...<Widget>[
                    _SectionTitleRow(
                      title: 'Discussion Feed',
                      subtitle: 'Freshly started discussions',
                      trailingLabel: 'Join',
                      onTrailingTap: () {},
                    ),
                    const SizedBox(height: 8),
                    ...hub.discussionFeed.take(3).map(
                      (CommunityPublication item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DynamicCommunityPublicationCard(item: item),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _SectionTitleRow(
                    title: 'Trending Discussions',
                    subtitle: 'High engagement topics from your area',
                    trailingLabel: 'Join',
                    onTrailingTap: () {},
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 156,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _trendingDiscussions.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (BuildContext context, int index) {
                        return _DiscussionCard(
                          item: _trendingDiscussions[index],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionTitleRow(
                    title: 'Volunteer Opportunities',
                    subtitle: 'Nearby drives and social support initiatives',
                    trailingLabel: 'See all',
                    onTrailingTap: () {},
                  ),
                  const SizedBox(height: 10),
                  ..._volunteerOpportunities.map(
                    (_VolunteerOpportunity item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _VolunteerCard(
                        item: item,
                        joined: _joinedOpportunities.contains(item.id),
                        onJoinTap: () {
                          setState(() {
                            if (_joinedOpportunities.contains(item.id)) {
                              _joinedOpportunities.remove(item.id);
                            } else {
                              _joinedOpportunities.add(item.id);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SectionTitleRow(
                    title: 'Government Awareness',
                    subtitle: 'Verified welfare and empowerment schemes',
                    trailingLabel: 'Official',
                    onTrailingTap: () {},
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 170,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _govSchemes.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (BuildContext context, int index) {
                        return _GovSchemeCard(item: _govSchemes[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionTitleRow(
                    title: 'Success Stories',
                    subtitle: 'Completed civic improvements',
                    trailingLabel: 'Timeline',
                    onTrailingTap: () {},
                  ),
                  const SizedBox(height: 10),
                  ..._successStories.map(
                    (_SuccessStory story) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SuccessStoryCard(story: story),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _BloodDonationCard(),
                  const SizedBox(height: 14),
                  _SectionTitleRow(
                    title: 'Nearby Communities',
                    subtitle: 'Join local groups around your location',
                    trailingLabel: 'Map',
                    onTrailingTap: () {},
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 132,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _nearbyCommunities.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final _NearbyCommunity item = _nearbyCommunities[index];
                        final bool joined = _joinedCommunities.contains(
                          item.id,
                        );
                        return _NearbyCommunityCard(
                          item: item,
                          joined: joined,
                          onJoinTap: () {
                            setState(() {
                              if (joined) {
                                _joinedCommunities.remove(item.id);
                              } else {
                                _joinedCommunities.add(item.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionTitleRow(
                    title: 'Community Projects',
                    subtitle: 'Track progress, volunteers and milestones',
                    trailingLabel: 'Progress',
                    onTrailingTap: () {},
                  ),
                  const SizedBox(height: 10),
                  ..._projects.map(
                    (_CommunityProject item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ProjectCard(item: item),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionTitleRow(
                    title: 'Top Contributors',
                    subtitle: 'Citizens, leaders, volunteers and NGOs',
                    trailingLabel: 'Leaderboard',
                    onTrailingTap: () {},
                  ),
                  const SizedBox(height: 10),
                  ..._contributors.map(
                    (_Contributor item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ContributorCard(
                        item: item,
                        isFollowing: _followedUsers.contains(item.userId),
                        onFollowTap: () {
                          setState(() {
                            if (_followedUsers.contains(item.userId)) {
                              _followedUsers.remove(item.userId);
                            } else {
                              _followedUsers.add(item.userId);
                            }
                          });
                        },
                        onProfileTap: () =>
                            _openPublicProfile(item.userId, item.name),
                        onMessageTap: () => _openChat(item.userId, item.name),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionTitleRow(
                    title: 'Suggested People',
                    subtitle: 'Citizens and leaders you may know',
                    trailingLabel: 'Refresh',
                    onTrailingTap: () {},
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 164,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _suggestedPeople.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final _SuggestedPerson item = _suggestedPeople[index];
                        final bool following = _followedUsers.contains(
                          item.userId,
                        );
                        return _SuggestedPersonCard(
                          item: item,
                          isFollowing: following,
                          onFollowTap: () {
                            setState(() {
                              if (following) {
                                _followedUsers.remove(item.userId);
                              } else {
                                _followedUsers.add(item.userId);
                              }
                            });
                          },
                          onMessageTap: () => _openChat(item.userId, item.name),
                          onProfileTap: () =>
                              _openPublicProfile(item.userId, item.name),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionTitleRow(
                    title: 'Event Highlights',
                    subtitle: 'Upcoming events with live countdown',
                    trailingLabel: 'Register',
                    onTrailingTap: () {},
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 186,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _eventHighlights.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (BuildContext context, int index) {
                        return _EventHighlightCard(
                          item: _eventHighlights[index],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionTitleRow(
                    title: 'Live Events',
                    subtitle: 'Watch and chat in real time',
                    trailingLabel: 'Live',
                    onTrailingTap: () {},
                  ),
                  const SizedBox(height: 10),
                  ..._liveEvents.map(
                    (_LiveEvent item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _LiveEventCard(item: item),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: _showComposerSheet,
            backgroundColor: const Color(0xFFF5A623),
            foregroundColor: isDark ? Colors.black : const Color(0xFF111827),
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 30),
          ),
          bottomNavigationBar: BottomNavigation(
            currentIndex: 2,
            onItemSelected: _handleBottomNavSelection,
          ),
        );
      },
    );
  }
}

class _HubWelcomeHeader extends StatelessWidget {
  const _HubWelcomeHeader({
    required this.onSearchTap,
    required this.onViewNotifications,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onViewNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.primaryGold.withValues(alpha: 0.26),
            AppColors.surface,
          ],
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Together We Build Better Communities',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
              ),
              IconButton(
                onPressed: onViewNotifications,
                icon: const Icon(Icons.notifications_active_rounded),
                color: AppColors.primaryGold,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryGold.withValues(
                    alpha: 0.16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Citizens, leaders, volunteers, NGOs and officials in one civic network.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const <Widget>[
              _NotificationTag(label: 'New Replies'),
              _NotificationTag(label: 'Mentions'),
              _NotificationTag(label: 'Poll Results'),
              _NotificationTag(label: 'Gov Announcements'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchCommunitiesField extends StatelessWidget {
  const _SearchCommunitiesField({
    required this.hintText,
    required this.onChanged,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: const Icon(Icons.tune_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  const _SectionTitleRow({
    required this.title,
    required this.subtitle,
    required this.trailingLabel,
    required this.onTrailingTap,
  });

  final String title;
  final String subtitle;
  final String trailingLabel;
  final VoidCallback onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        TextButton(onPressed: onTrailingTap, child: Text(trailingLabel)),
      ],
    );
  }
}

class _CommunityImpactGrid extends StatelessWidget {
  const _CommunityImpactGrid({required this.items});

  final List<_ImpactStat> items;

  @override
  Widget build(BuildContext context) {
    final double textScale = MediaQuery.textScalerOf(
      context,
    ).scale(1.0).clamp(1.0, 1.4);
    final double tileHeight = 132 + ((textScale - 1.0) * 24);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: tileHeight,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _ImpactCard(item: items[index]);
      },
    );
  }
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({required this.item});

  final _ImpactStat item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryGold.withValues(alpha: 0.18),
              child: Icon(item.icon, size: 18, color: AppColors.primaryGold),
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: item.value.toDouble()),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 1),
            Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 1),
            Text(
              item.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniQuickActionCard extends StatelessWidget {
  const _MiniQuickActionCard({required this.action, required this.onTap});

  final _QuickActionItem action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'quick-action-${action.label}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            width: 152,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryGold.withValues(alpha: 0.18),
                  child: Icon(action.icon, color: AppColors.primaryGold, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    action.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DynamicCommunityPublicationCard extends StatelessWidget {
  const _DynamicCommunityPublicationCard({required this.item});

  final CommunityPublication item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryGold.withValues(alpha: 0.2),
                  child: Icon(_iconForType(item.type), size: 16, color: AppColors.primaryGold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  _timeAgo(item.createdAt),
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.description, style: const TextStyle(height: 1.35)),
            if ((item.location ?? '').trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.location_on_rounded, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.location!,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(CommunityContentType type) {
    switch (type) {
      case CommunityContentType.post:
        return Icons.edit_note_rounded;
      case CommunityContentType.video:
        return Icons.videocam_rounded;
      case CommunityContentType.photos:
        return Icons.photo_library_rounded;
      case CommunityContentType.poll:
        return Icons.poll_rounded;
      case CommunityContentType.question:
        return Icons.help_center_rounded;
      case CommunityContentType.event:
        return Icons.event_rounded;
      case CommunityContentType.announcement:
        return Icons.campaign_rounded;
      case CommunityContentType.location:
        return Icons.location_on_rounded;
      case CommunityContentType.discussion:
        return Icons.forum_rounded;
    }
  }

  String _timeAgo(DateTime createdAt) {
    final Duration diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) {
      return 'now';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes}m';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours}h';
    }
    return '${diff.inDays}d';
  }
}

class _TopicChipCard extends StatelessWidget {
  const _TopicChipCard({
    required this.topic,
    required this.isFollowed,
    required this.onTap,
  });

  final _TopicItem topic;
  final bool isFollowed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: isFollowed ? AppColors.primaryGold : AppColors.divider,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                topic.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Icon(
                isFollowed ? Icons.check_circle : Icons.add_circle_outline,
                size: 18,
                color: isFollowed ? AppColors.primaryGold : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinnedAnnouncementCard extends StatelessWidget {
  const _PinnedAnnouncementCard({
    required this.title,
    required this.message,
    required this.onProfileTap,
  });

  final String title;
  final String message;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryGold.withValues(
                    alpha: 0.18,
                  ),
                  child: const Text(
                    'PS',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Text(
                            'Councilor Priya Sharma',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: AppColors.primaryGold,
                          ),
                        ],
                      ),
                      Text(
                        'Verified Leader • Ward 94',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Pinned Official',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(
                color: AppColors.textMuted,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today_rounded,
                  size: 15,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  '16 Jul 2026',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onProfileTap,
                  child: const Text('Leader Profile'),
                ),
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Text('Read More'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    required this.post,
    required this.isLiked,
    required this.isBookmarked,
    required this.selectedPollIndex,
    required this.onProfileTap,
    required this.onMessageTap,
    required this.onLikeTap,
    required this.onBookmarkTap,
    required this.onSelectPoll,
    this.onFollowTap,
  });

  final _CommunityPost post;
  final bool isLiked;
  final bool isBookmarked;
  final int? selectedPollIndex;
  final VoidCallback onProfileTap;
  final VoidCallback onMessageTap;
  final VoidCallback onLikeTap;
  final VoidCallback onBookmarkTap;
  final ValueChanged<int> onSelectPoll;
  final VoidCallback? onFollowTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryGold.withValues(
                      alpha: 0.2,
                    ),
                    child: Text(
                      post.authorName
                          .split(' ')
                          .where((String part) => part.isNotEmpty)
                          .take(2)
                          .map((String part) => part[0].toUpperCase())
                          .join(),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                post.authorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (post.isVerified)
                              const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFFF5A623),
                                size: 16,
                              ),
                          ],
                        ),
                        Text(
                          '${post.authorRole} • ${post.location} • ${post.timeLabel}',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String value) {
                      if (value == 'message') {
                        onMessageTap();
                        return;
                      }
                      if (value == 'profile') {
                        onProfileTap();
                        return;
                      }
                      if (value == 'follow') {
                        onFollowTap?.call();
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        const <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'profile',
                            child: Text('Open Profile'),
                          ),
                          PopupMenuItem<String>(
                            value: 'follow',
                            child: Text('Follow User'),
                          ),
                          PopupMenuItem<String>(
                            value: 'message',
                            child: Text('Message User'),
                          ),
                          PopupMenuItem<String>(
                            value: 'report',
                            child: Text('Report'),
                          ),
                        ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (post.type == _PostType.photo ||
                post.type == _PostType.multiImage)
              _MediaPlaceholder(
                label: post.type == _PostType.multiImage
                    ? 'Multiple Images'
                    : 'Photo Post',
              ),
            if (post.type == _PostType.video)
              _VideoPostPanel(
                isLiked: isLiked,
                onLikeTap: onLikeTap,
                likeCount: post.likes + (isLiked ? 1 : 0),
                commentCount: post.comments,
                shareCount: post.shares,
              ),
            if (post.type == _PostType.poll)
              _PollPanel(
                options: post.pollOptions,
                selectedIndex: selectedPollIndex,
                onSelect: onSelectPoll,
              ),
            if (post.type == _PostType.question)
              _QuestionPanel(bestAnswer: post.bestAnswer),
            if (post.type == _PostType.event ||
                post.type == _PostType.governmentUpdate)
              _InfoStrip(
                icon: post.type == _PostType.event
                    ? Icons.event_available_rounded
                    : Icons.campaign_rounded,
                text: post.type == _PostType.event
                    ? 'Event post • Join and RSVP now'
                    : 'Verified government update',
              ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                _AnimatedLikeButton(
                  liked: isLiked,
                  count: post.likes + (isLiked ? 1 : 0),
                  onTap: onLikeTap,
                ),
                const SizedBox(width: 12),
                _SmallActionButton(
                  icon: Icons.mode_comment_outlined,
                  label: '${post.comments}',
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _SmallActionButton(
                  icon: Icons.share_outlined,
                  label: '${post.shares}',
                  onTap: () {},
                ),
                const Spacer(),
                IconButton(
                  onPressed: onBookmarkTap,
                  icon: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                  ),
                  color: isBookmarked
                      ? AppColors.primaryGold
                      : AppColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: onFollowTap,
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                  label: const Text('Follow'),
                ),
                OutlinedButton.icon(
                  onPressed: onMessageTap,
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  label: const Text('Message'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.reply_rounded, size: 16),
                  label: const Text('Reply'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.flag_outlined, size: 16),
                  label: const Text('Report'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedLikeButton extends StatelessWidget {
  const _AnimatedLikeButton({
    required this.liked,
    required this.count,
    required this.onTap,
  });

  final bool liked;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        scale: liked ? 1.08 : 1,
        child: Row(
          children: <Widget>[
            Icon(
              liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 18,
              color: liked ? Colors.redAccent : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text('$count', style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MediaPlaceholder extends StatelessWidget {
  const _MediaPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 176,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: <Color>[
            AppColors.surfaceElevated,
            AppColors.primaryGold.withValues(alpha: 0.24),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _VideoPostPanel extends StatelessWidget {
  const _VideoPostPanel({
    required this.isLiked,
    required this.onLikeTap,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
  });

  final bool isLiked;
  final VoidCallback onLikeTap;
  final int likeCount;
  final int commentCount;
  final int shareCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surfaceElevated,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: <Color>[
                  Colors.black.withValues(alpha: 0.65),
                  AppColors.primaryGold.withValues(alpha: 0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _ControlTag(label: '00:42'),
              const SizedBox(width: 6),
              _ControlTag(label: '12.3K views'),
              const SizedBox(width: 6),
              _ControlTag(label: 'Autoplay visible'),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: const <Widget>[
              _ControlTag(label: 'Autoplay'),
              _ControlTag(label: 'Mute'),
              _ControlTag(label: 'Fullscreen'),
              _ControlTag(label: 'PiP'),
              _ControlTag(label: 'Speed 1.25x'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _AnimatedLikeButton(
                liked: isLiked,
                count: likeCount,
                onTap: onLikeTap,
              ),
              const SizedBox(width: 10),
              _SmallActionButton(
                icon: Icons.mode_comment_outlined,
                label: '$commentCount',
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _SmallActionButton(
                icon: Icons.share_outlined,
                label: '$shareCount',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PollPanel extends StatelessWidget {
  const _PollPanel({
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<_PollOption> options;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final int totalVotes = options.fold<int>(
      0,
      (int total, _PollOption item) => total + item.votes,
    );

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surfaceElevated,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...List<Widget>.generate(options.length, (int index) {
            final _PollOption item = options[index];
            final double progress = totalVotes == 0
                ? 0
                : item.votes / totalVotes;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onSelect(index),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          selectedIndex == index
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: selectedIndex == index
                              ? AppColors.primaryGold
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.label,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text('${(progress * 100).round()}%'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          color: AppColors.primaryGold,
                          backgroundColor: AppColors.divider,
                          borderRadius: BorderRadius.circular(999),
                          minHeight: 8,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          Text(
            '$totalVotes total votes • 2 days remaining',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({required this.bestAnswer});

  final String? bestAnswer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.emoji_events_rounded, color: Color(0xFFF5A623)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              bestAnswer == null
                  ? 'No best answer yet. Be the first to help.'
                  : 'Best Answer Badge: $bestAnswer',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.primaryGold.withValues(alpha: 0.14),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.primaryGold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _VolunteerCard extends StatelessWidget {
  const _VolunteerCard({
    required this.item,
    required this.joined,
    required this.onJoinTap,
  });

  final _VolunteerOpportunity item;
  final bool joined;
  final VoidCallback onJoinTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.divider),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryGold.withValues(alpha: 0.18),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                color: Color(0xFFF5A623),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.date} • ${item.location} • ${item.volunteersNeeded} volunteers needed',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: onJoinTap,
              child: Text(joined ? 'Joined' : 'Join'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscussionCard extends StatelessWidget {
  const _DiscussionCard({required this.item});

  final _Discussion item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 212,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.topic,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                '${item.replies} replies • ${item.participants} participants',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 8),
              _ControlTag(label: 'Trending score ${item.score}'),
              const Spacer(),
              SizedBox(
                height: 34,
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                  ),
                  onPressed: () {},
                  child: const Text('Join Discussion'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestedPersonCard extends StatelessWidget {
  const _SuggestedPersonCard({
    required this.item,
    required this.isFollowing,
    required this.onFollowTap,
    required this.onMessageTap,
    required this.onProfileTap,
  });

  final _SuggestedPerson item;
  final bool isFollowing;
  final VoidCallback onFollowTap;
  final VoidCallback onMessageTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.divider),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onProfileTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryGold.withValues(
                        alpha: 0.18,
                      ),
                      child: Text(item.name.substring(0, 1)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item.role),
                const SizedBox(height: 2),
                Text(
                  '${item.mutualCommunities} mutual communities',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const Spacer(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: onFollowTap,
                        child: Text(isFollowing ? 'Following' : 'Follow'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onMessageTap,
                        child: const Text('Message'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventHighlightCard extends StatelessWidget {
  const _EventHighlightCard({required this.item});

  final _EventHighlight item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 78,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: <Color>[
                      AppColors.surfaceElevated,
                      AppColors.primaryGold.withValues(alpha: 0.22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text('${item.location} • ${item.date}'),
              const SizedBox(height: 4),
              _ControlTag(label: 'Starts in ${item.countdown}'),
              const Spacer(),
              FilledButton(onPressed: () {}, child: const Text('Register')),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveEventCard extends StatelessWidget {
  const _LiveEventCard({required this.item});

  final _LiveEvent item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${item.participants} participants • ${item.viewers} viewers',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.live_tv_rounded),
                  label: const Text('Watch Live'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.forum_rounded),
                  label: const Text('Join Chat'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GovSchemeCard extends StatelessWidget {
  const _GovSchemeCard({required this.item});

  final _GovScheme item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 248,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFFF5A623),
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'Eligibility: ${item.eligibility}',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const Spacer(),
              FilledButton(onPressed: () {}, child: const Text('Apply')),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessStoryCard extends StatelessWidget {
  const _SuccessStoryCard({required this.story});

  final _SuccessStory story;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              story.title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(child: _BeforeAfterBox(label: 'Before')),
                const SizedBox(width: 8),
                Expanded(child: _BeforeAfterBox(label: 'After')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BeforeAfterBox extends StatelessWidget {
  const _BeforeAfterBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.surfaceElevated,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BloodDonationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Blood Donation',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _statusTag('Urgent Requests: 3'),
                _statusTag('Nearby Donors: 27'),
                _statusTag('O+ Needed in 4 km'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.bloodtype_rounded),
                    label: const Text('Donate Blood'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.medical_services_rounded),
                    label: const Text('Request Blood'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _NearbyCommunityCard extends StatelessWidget {
  const _NearbyCommunityCard({
    required this.item,
    required this.joined,
    required this.onJoinTap,
  });

  final _NearbyCommunity item;
  final bool joined;
  final VoidCallback onJoinTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 212,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.members} members',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const Spacer(),
              FilledButton.tonal(
                onPressed: onJoinTap,
                child: Text(joined ? 'Joined' : 'Join'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.item});

  final _CommunityProject item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Timeline: ${item.timeline} • Status: ${item.status}',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: item.progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(999),
                  color: AppColors.primaryGold,
                  backgroundColor: AppColors.divider,
                );
              },
            ),
            const SizedBox(height: 6),
            Text(
              '${(item.progress * 100).round()}% complete • ${item.volunteers} volunteers',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(child: _BeforeAfterBox(label: 'Before')),
                const SizedBox(width: 8),
                Expanded(child: _BeforeAfterBox(label: 'After')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.forum_rounded, size: 16),
                  label: const Text('Discussion'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.volunteer_activism_rounded, size: 16),
                  label: const Text('Volunteer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContributorCard extends StatelessWidget {
  const _ContributorCard({
    required this.item,
    required this.isFollowing,
    required this.onFollowTap,
    required this.onProfileTap,
    required this.onMessageTap,
  });

  final _Contributor item;
  final bool isFollowing;
  final VoidCallback onFollowTap;
  final VoidCallback onProfileTap;
  final VoidCallback onMessageTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.divider),
      ),
      child: ListTile(
        onTap: onProfileTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryGold.withValues(alpha: 0.18),
          child: Text(item.name.substring(0, 1)),
        ),
        title: Text(
          '#${item.rank} ${item.name}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('${item.role} • ${item.points} points • ${item.badge}'),
        trailing: Wrap(
          spacing: 6,
          children: <Widget>[
            IconButton(
              onPressed: onMessageTap,
              icon: const Icon(Icons.chat_bubble_outline_rounded),
            ),
            FilledButton.tonal(
              onPressed: onFollowTap,
              child: Text(isFollowing ? 'Following' : 'Follow'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTag extends StatelessWidget {
  const _NotificationTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5),
      ),
    );
  }
}

class _ControlTag extends StatelessWidget {
  const _ControlTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _TopicItem {
  const _TopicItem(this.label);

  final String label;
}

enum _PostType {
  text,
  photo,
  video,
  multiImage,
  poll,
  question,
  announcement,
  event,
  governmentUpdate,
}

class _PollOption {
  const _PollOption({required this.label, required this.votes});

  final String label;
  final int votes;
}

class _CommunityPost {
  const _CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.location,
    required this.isVerified,
    required this.timeLabel,
    required this.type,
    required this.content,
    required this.likes,
    required this.comments,
    required this.shares,
    this.pollOptions = const <_PollOption>[],
    this.bestAnswer,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String location;
  final bool isVerified;
  final String timeLabel;
  final _PostType type;
  final String content;
  final int likes;
  final int comments;
  final int shares;
  final List<_PollOption> pollOptions;
  final String? bestAnswer;
}

class _VolunteerOpportunity {
  const _VolunteerOpportunity({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.volunteersNeeded,
  });

  final String id;
  final String title;
  final String date;
  final String location;
  final int volunteersNeeded;
}

class _GovScheme {
  const _GovScheme({
    required this.name,
    required this.description,
    required this.eligibility,
  });

  final String name;
  final String description;
  final String eligibility;
}

class _SuccessStory {
  const _SuccessStory({required this.title});

  final String title;
}

class _NearbyCommunity {
  const _NearbyCommunity({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
  });

  final String id;
  final String name;
  final String description;
  final int members;
}

class _CommunityProject {
  const _CommunityProject({
    required this.title,
    required this.progress,
    required this.timeline,
    required this.volunteers,
    required this.status,
  });

  final String title;
  final double progress;
  final String timeline;
  final int volunteers;
  final String status;
}

class _Contributor {
  const _Contributor({
    required this.userId,
    required this.name,
    required this.role,
    required this.points,
    required this.badge,
    required this.rank,
  });

  final String userId;
  final String name;
  final String role;
  final int points;
  final String badge;
  final int rank;
}

class _ImpactStat {
  const _ImpactStat({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final int value;
  final String subtitle;
}

class _Discussion {
  const _Discussion({
    required this.topic,
    required this.replies,
    required this.participants,
    required this.score,
  });

  final String topic;
  final int replies;
  final int participants;
  final int score;
}

class _SuggestedPerson {
  const _SuggestedPerson({
    required this.userId,
    required this.name,
    required this.role,
    required this.mutualCommunities,
  });

  final String userId;
  final String name;
  final String role;
  final int mutualCommunities;
}

class _EventHighlight {
  const _EventHighlight({
    required this.title,
    required this.location,
    required this.date,
    required this.countdown,
  });

  final String title;
  final String location;
  final String date;
  final String countdown;
}

class _LiveEvent {
  const _LiveEvent({
    required this.title,
    required this.participants,
    required this.viewers,
  });

  final String title;
  final int participants;
  final int viewers;
}

const List<String> _filters = <String>[
  'Latest',
  'Trending',
  'Nearby',
  'Official',
  'Photos',
  'Videos',
  'Questions',
  'Polls',
  'Events',
];

const List<_TopicItem> _trendingTopics = <_TopicItem>[
  _TopicItem('Water Supply'),
  _TopicItem('Tree Plantation'),
  _TopicItem('Traffic'),
  _TopicItem('Education'),
  _TopicItem('Blood Donation'),
  _TopicItem('Road Repairs'),
  _TopicItem('Women Safety'),
  _TopicItem('Clean City'),
];

const List<_QuickActionItem> _quickActions = <_QuickActionItem>[
  _QuickActionItem(Icons.edit_note_rounded, 'Create Post'),
  _QuickActionItem(Icons.videocam_rounded, 'Upload Video'),
  _QuickActionItem(Icons.photo_library_rounded, 'Upload Photos'),
  _QuickActionItem(Icons.poll_rounded, 'Create Poll'),
  _QuickActionItem(Icons.help_center_rounded, 'Ask Question'),
  _QuickActionItem(Icons.event_available_rounded, 'Create Event'),
  _QuickActionItem(Icons.report_problem_rounded, 'Report Issue'),
  _QuickActionItem(Icons.campaign_rounded, 'Announcement (Leader)'),
  _QuickActionItem(Icons.location_on_rounded, 'Share Location'),
  _QuickActionItem(Icons.forum_rounded, 'Start Discussion'),
];

const List<_CommunityPost> _demoPosts = <_CommunityPost>[
  _CommunityPost(
    id: 'p1',
    authorId: 'citizen_1',
    authorName: 'Aarav Rao',
    authorRole: 'Verified Citizen',
    location: 'Ward 94',
    isVerified: true,
    timeLabel: '12 min ago',
    type: _PostType.text,
    content:
        'Drainage overflow near Sector 3 has reduced after yesterday\'s cleanup drive. Thank you volunteers and ward officers.',
    likes: 128,
    comments: 23,
    shares: 9,
  ),
  _CommunityPost(
    id: 'p2',
    authorId: 'leader_1',
    authorName: 'Priya Sharma',
    authorRole: 'Verified Leader',
    location: 'Hyderabad Central',
    isVerified: true,
    timeLabel: '28 min ago',
    type: _PostType.announcement,
    content:
        'Official announcement: weekend road repair in Ward 94 starts at 7 AM. Please use alternate routes.',
    likes: 422,
    comments: 64,
    shares: 41,
  ),
  _CommunityPost(
    id: 'p3',
    authorId: 'ngo_1',
    authorName: 'Green Circle NGO',
    authorRole: 'Top NGO',
    location: 'KPHB Zone',
    isVerified: true,
    timeLabel: '1 hr ago',
    type: _PostType.video,
    content:
        'Highlights from the community cleaning campaign held this morning.',
    likes: 301,
    comments: 32,
    shares: 26,
  ),
  _CommunityPost(
    id: 'p4',
    authorId: 'citizen_2',
    authorName: 'Neha Reddy',
    authorRole: 'Citizen',
    location: 'Miyapur',
    isVerified: false,
    timeLabel: '2 hr ago',
    type: _PostType.poll,
    content: 'Should our ward have a new park?',
    likes: 89,
    comments: 17,
    shares: 4,
    pollOptions: <_PollOption>[
      _PollOption(label: 'Yes', votes: 212),
      _PollOption(label: 'No', votes: 44),
      _PollOption(label: 'Maybe', votes: 73),
    ],
  ),
  _CommunityPost(
    id: 'p5',
    authorId: 'citizen_3',
    authorName: 'Rahul Verma',
    authorRole: 'Volunteer',
    location: 'Ward 91',
    isVerified: true,
    timeLabel: '3 hr ago',
    type: _PostType.question,
    content:
        'What is the easiest process to register for municipal water complaint tracking online?',
    likes: 53,
    comments: 19,
    shares: 3,
    bestAnswer:
        'Use the ward portal and attach your consumer ID for faster routing.',
  ),
  _CommunityPost(
    id: 'p6',
    authorId: 'official_1',
    authorName: 'Ward Office 94',
    authorRole: 'Government',
    location: 'City Secretariat',
    isVerified: true,
    timeLabel: '4 hr ago',
    type: _PostType.governmentUpdate,
    content:
        'Ayushman Bharat registration help desk is available this week at community hall.',
    likes: 210,
    comments: 21,
    shares: 30,
  ),
  _CommunityPost(
    id: 'p7',
    authorId: 'vol_2',
    authorName: 'Volunteer Network',
    authorRole: 'Volunteer Team',
    location: 'City-wide',
    isVerified: true,
    timeLabel: '5 hr ago',
    type: _PostType.event,
    content: 'Tree plantation drive this Sunday. Gloves and saplings provided.',
    likes: 177,
    comments: 36,
    shares: 18,
  ),
  _CommunityPost(
    id: 'p8',
    authorId: 'citizen_4',
    authorName: 'Maya Singh',
    authorRole: 'Citizen',
    location: 'Lake View Colony',
    isVerified: false,
    timeLabel: '6 hr ago',
    type: _PostType.photo,
    content:
        'Street lights restored near Lake View road. Sharing latest photos.',
    likes: 141,
    comments: 11,
    shares: 7,
  ),
];

const List<_VolunteerOpportunity> _volunteerOpportunities =
    <_VolunteerOpportunity>[
      _VolunteerOpportunity(
        id: 'v1',
        title: 'Tree Plantation',
        date: 'Sat, 10 Aug',
        location: 'Ward Park',
        volunteersNeeded: 45,
      ),
      _VolunteerOpportunity(
        id: 'v2',
        title: 'Blood Donation',
        date: 'Sun, 11 Aug',
        location: 'Civic Center',
        volunteersNeeded: 20,
      ),
      _VolunteerOpportunity(
        id: 'v3',
        title: 'Food Distribution',
        date: 'Tue, 13 Aug',
        location: 'Old Market',
        volunteersNeeded: 35,
      ),
      _VolunteerOpportunity(
        id: 'v4',
        title: 'Disaster Relief',
        date: 'Fri, 16 Aug',
        location: 'Community Hall',
        volunteersNeeded: 28,
      ),
      _VolunteerOpportunity(
        id: 'v5',
        title: 'Community Cleaning',
        date: 'Sun, 18 Aug',
        location: 'River Side',
        volunteersNeeded: 52,
      ),
    ];

const List<_GovScheme> _govSchemes = <_GovScheme>[
  _GovScheme(
    name: 'Ayushman Bharat',
    description: 'Health coverage support for eligible families.',
    eligibility: 'Low-income families',
  ),
  _GovScheme(
    name: 'PMAY',
    description: 'Housing support for urban and rural citizens.',
    eligibility: 'First-time home applicants',
  ),
  _GovScheme(
    name: 'Digital India',
    description: 'Digital access, services, and awareness programs.',
    eligibility: 'All citizens',
  ),
  _GovScheme(
    name: 'Skill India',
    description: 'Skill development and job readiness support.',
    eligibility: 'Youth and job seekers',
  ),
];

const List<_SuccessStory> _successStories = <_SuccessStory>[
  _SuccessStory(title: 'Road Repaired'),
  _SuccessStory(title: 'Garbage Removed'),
  _SuccessStory(title: 'Street Lights Installed'),
  _SuccessStory(title: 'Water Tank Fixed'),
];

const List<_NearbyCommunity> _nearbyCommunities = <_NearbyCommunity>[
  _NearbyCommunity(
    id: 'c1',
    name: 'KPHB Residents',
    description: 'Local civic updates and neighborhood alerts.',
    members: 2184,
  ),
  _NearbyCommunity(
    id: 'c2',
    name: 'Hyderabad Volunteers',
    description: 'Volunteer drives for health, food, and cleanup.',
    members: 980,
  ),
  _NearbyCommunity(
    id: 'c3',
    name: 'Ward 94 Citizens',
    description: 'Ward-level issue tracking and progress updates.',
    members: 1642,
  ),
  _NearbyCommunity(
    id: 'c4',
    name: 'Women Empowerment',
    description: 'Safety, leadership, and awareness initiatives.',
    members: 1128,
  ),
  _NearbyCommunity(
    id: 'c5',
    name: 'Students Community',
    description: 'Student civic engagement and mentoring network.',
    members: 1340,
  ),
];

const List<_CommunityProject> _projects = <_CommunityProject>[
  _CommunityProject(
    title: 'Road Repair',
    progress: 0.62,
    timeline: 'Aug - Sep',
    volunteers: 32,
    status: 'In Progress',
  ),
  _CommunityProject(
    title: 'Park Development',
    progress: 0.44,
    timeline: 'Jul - Oct',
    volunteers: 41,
    status: 'Active',
  ),
  _CommunityProject(
    title: 'Drainage Improvement',
    progress: 0.79,
    timeline: 'Jun - Aug',
    volunteers: 18,
    status: 'Near Completion',
  ),
];

const List<_Contributor> _contributors = <_Contributor>[
  _Contributor(
    userId: 'citizen_top_1',
    name: 'Anita Mehra',
    role: 'Top Citizen',
    points: 1820,
    badge: 'Community Hero',
    rank: 1,
  ),
  _Contributor(
    userId: 'leader_top_1',
    name: 'Raghav Pratap',
    role: 'Top Leader',
    points: 2460,
    badge: 'Issue Solver',
    rank: 2,
  ),
  _Contributor(
    userId: 'vol_top_1',
    name: 'Farah Khan',
    role: 'Top Volunteer',
    points: 1740,
    badge: 'Green Champion',
    rank: 3,
  ),
  _Contributor(
    userId: 'ngo_top_1',
    name: 'Serve India NGO',
    role: 'Top NGO',
    points: 2310,
    badge: 'Top Contributor',
    rank: 4,
  ),
];

const List<_ImpactStat> _impactStats = <_ImpactStat>[
  _ImpactStat(
    icon: Icons.report_problem_rounded,
    title: 'Issues Resolved Today',
    value: 42,
    subtitle: '+8 vs yesterday',
  ),
  _ImpactStat(
    icon: Icons.park_rounded,
    title: 'Trees Planted',
    value: 186,
    subtitle: 'This week',
  ),
  _ImpactStat(
    icon: Icons.groups_rounded,
    title: 'Active Volunteers',
    value: 324,
    subtitle: 'Across 19 drives',
  ),
  _ImpactStat(
    icon: Icons.bloodtype_rounded,
    title: 'Blood Donations',
    value: 27,
    subtitle: 'Today in your city',
  ),
  _ImpactStat(
    icon: Icons.event_rounded,
    title: 'Events Today',
    value: 11,
    subtitle: '4 are live now',
  ),
  _ImpactStat(
    icon: Icons.emoji_events_rounded,
    title: 'Community Points Earned',
    value: 12940,
    subtitle: 'Last 24 hours',
  ),
];

const List<_Discussion> _trendingDiscussions = <_Discussion>[
  _Discussion(topic: 'Road Repair', replies: 84, participants: 219, score: 96),
  _Discussion(topic: 'Water Supply', replies: 67, participants: 184, score: 91),
  _Discussion(topic: 'Traffic', replies: 53, participants: 141, score: 87),
  _Discussion(
    topic: 'Tree Plantation',
    replies: 48,
    participants: 126,
    score: 84,
  ),
  _Discussion(topic: 'Education', replies: 36, participants: 104, score: 79),
];

const List<_SuggestedPerson> _suggestedPeople = <_SuggestedPerson>[
  _SuggestedPerson(
    userId: 'sp1',
    name: 'Lakshmi Rao',
    role: 'Verified Citizen',
    mutualCommunities: 4,
  ),
  _SuggestedPerson(
    userId: 'sp2',
    name: 'Arjun Malhotra',
    role: 'Leader',
    mutualCommunities: 3,
  ),
  _SuggestedPerson(
    userId: 'sp3',
    name: 'Sana Iqbal',
    role: 'Volunteer',
    mutualCommunities: 5,
  ),
  _SuggestedPerson(
    userId: 'sp4',
    name: 'Nikhil Reddy',
    role: 'Citizen',
    mutualCommunities: 2,
  ),
];

const List<_EventHighlight> _eventHighlights = <_EventHighlight>[
  _EventHighlight(
    title: 'Ward 94 Civic Townhall',
    location: 'Community Hall',
    date: '20 Jul',
    countdown: '2d 08h',
  ),
  _EventHighlight(
    title: 'Mega Tree Plantation Drive',
    location: 'Lake Park',
    date: '21 Jul',
    countdown: '3d 03h',
  ),
  _EventHighlight(
    title: 'Blood Donation Camp',
    location: 'Civic Center',
    date: '22 Jul',
    countdown: '4d 06h',
  ),
];

const List<_LiveEvent> _liveEvents = <_LiveEvent>[
  _LiveEvent(
    title: 'Road Repair Live Briefing',
    participants: 214,
    viewers: 987,
  ),
  _LiveEvent(title: 'Women Safety Forum', participants: 142, viewers: 621),
];
