import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/mock_social_repository.dart';
import '../../models/chat_models.dart';
import '../../models/public_user_profile.dart';

class PublicUserProfileScreen extends StatefulWidget {
  const PublicUserProfileScreen({super.key, required this.args});

  final PublicProfileRouteArgs args;

  @override
  State<PublicUserProfileScreen> createState() =>
      _PublicUserProfileScreenState();
}

class _PublicUserProfileScreenState extends State<PublicUserProfileScreen>
    with SingleTickerProviderStateMixin {
  final SocialRepository _repo = MockSocialRepository.instance;
  late final AnimationController _introController;

  PublicUserProfile? _profile;
  bool _loading = true;
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _load();
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final PublicUserProfile p = await _repo.getPublicProfile(
      widget.args.userId,
      widget.args.displayName,
    );
    if (!mounted) return;

    setState(() {
      _profile = p;
      _loading = false;
    });
    _introController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final PublicUserProfile profile = _profile!;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isLarge = constraints.maxWidth >= 700;
            final double coverHeight =
                (MediaQuery.of(context).size.height * 0.31).clamp(220, 260);

            return NestedScrollView(
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        pinned: true,
                        floating: false,
                        title: Text(profile.name),
                        forceElevated: innerBoxIsScrolled,
                        actions: <Widget>[
                          PopupMenuButton<String>(
                            onSelected: _onProfileMenu,
                            itemBuilder: (BuildContext context) =>
                                const <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'report',
                                    child: Text('Report User'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'block',
                                    child: Text('Block User'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'share',
                                    child: Text('Share Profile'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'copy',
                                    child: Text('Copy Profile Link'),
                                  ),
                                ],
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _reveal(
                                order: 0,
                                child: _buildCoverAndIdentity(
                                  profile: profile,
                                  coverHeight: coverHeight,
                                ),
                              ),
                              const SizedBox(height: 18),
                              _reveal(order: 1, child: _actionButtons(profile)),
                              const SizedBox(height: 20),
                              _reveal(
                                order: 2,
                                child: _sectionTitle('Statistics'),
                              ),
                              _reveal(
                                order: 3,
                                child: _statsSections(
                                  profile: profile,
                                  isLarge: isLarge,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _reveal(order: 4, child: _sectionTitle('About')),
                              _reveal(order: 5, child: _about(profile)),
                              const SizedBox(height: 20),
                              _reveal(
                                order: 6,
                                child: _sectionTitle('Achievements'),
                              ),
                              _reveal(
                                order: 7,
                                child: _achievementChips(profile),
                              ),
                              const SizedBox(height: 20),
                              _reveal(
                                order: 8,
                                child: _sectionTitle('Recent Activity'),
                              ),
                              _reveal(
                                order: 9,
                                child: _recentActivity(profile),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _ProfileTabBarDelegate(
                          TabBar(
                            isScrollable: true,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: LinearGradient(
                                colors: <Color>[
                                  AppColors.goldLight,
                                  AppColors.primaryGold,
                                  AppColors.goldDeep,
                                ],
                              ),
                            ),
                            labelColor: AppColors.onGold,
                            unselectedLabelColor: AppColors.textMuted,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                            tabs: const <Tab>[
                              Tab(text: 'Posts'),
                              Tab(text: 'Videos'),
                              Tab(text: 'Issues'),
                              Tab(text: 'Events'),
                              Tab(text: 'About'),
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
              body: TabBarView(
                children: <Widget>[
                  _tabList(profile.recentPosts, Icons.article_rounded),
                  _tabList(profile.recentVideos, Icons.ondemand_video_rounded),
                  _tabList(
                    profile.recentIssues,
                    Icons.campaign_rounded,
                    emptyLabel: 'No issues raised yet',
                  ),
                  _tabList(profile.recentEvents, Icons.event_rounded),
                  _aboutTab(profile),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCoverAndIdentity({
    required PublicUserProfile profile,
    required double coverHeight,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fadeTo = Theme.of(context).scaffoldBackgroundColor;
    final String verificationStatus = profile.isVerified
        ? 'Verified'
        : 'Pending Verification';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              child: SizedBox(
                height: coverHeight,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/coverimage.png',
                      fit: BoxFit.cover,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.black.withValues(
                              alpha: isDark ? 0.30 : 0.15,
                            ),
                            Colors.black.withValues(
                              alpha: isDark ? 0.55 : 0.38,
                            ),
                            fadeTo,
                          ],
                          stops: const <double>[0.0, 0.68, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              bottom: -52,
              child: Hero(
                tag: widget.args.heroTag ?? 'profile_${profile.id}',
                child: _profileAvatar(profile),
              ),
            ),
          ],
        ),
        const SizedBox(height: 62),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                profile.name,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (profile.isVerified)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.goldLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: AppColors.primaryGold,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${profile.roleLabel} • Ward ${profile.ward}',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: <Widget>[
              _twoColumnDetail('City', profile.city, 'State', profile.state),
              const SizedBox(height: 10),
              _twoColumnDetail(
                'Joined Date',
                _date(profile.joinDate),
                'Community Rating',
                '${_communityRating(profile).toStringAsFixed(1)} / 5',
              ),
              const SizedBox(height: 10),
              _twoColumnDetail(
                'Trust Score',
                '${_trustScore(profile)}%',
                'Leader Level',
                _leaderLevel(profile),
              ),
              const SizedBox(height: 10),
              _twoColumnDetail(
                'Verification Status',
                verificationStatus,
                'Role',
                profile.roleLabel,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _profileAvatar(PublicUserProfile profile) {
    const double radius = 48;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.goldLight, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              backgroundColor: AppColors.surface,
              backgroundImage: profile.avatarImage == null
                  ? null
                  : AssetImage(profile.avatarImage!),
              child: profile.avatarImage == null
                  ? Text(
                      profile.avatarInitials,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButtons(PublicUserProfile profile) {
    return Row(
      children: <Widget>[
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  AppColors.goldLight,
                  AppColors.primaryGold,
                  AppColors.goldDeep,
                ],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.32),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: _onMessageTap,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.message_rounded, color: AppColors.onGold),
                      SizedBox(width: 8),
                      Text(
                        'Message',
                        style: TextStyle(
                          color: AppColors.onGold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AnimatedFollowButton(
            isFollowing: profile.isFollowing,
            onTap: _onFollowTap,
          ),
        ),
      ],
    );
  }

  Widget _statsSections({
    required PublicUserProfile profile,
    required bool isLarge,
  }) {
    final Map<String, int> network = <String, int>{
      'Posts': profile.stats.posts,
      'Followers': profile.stats.followers,
      'Following': profile.stats.following,
      'Likes': profile.stats.likesReceived,
    };
    final Map<String, int> leadership = <String, int>{
      'Issues Raised': profile.stats.issuesRaised,
      'Issues Solved': profile.stats.issuesSolved,
      'Community Points': profile.stats.communityPoints,
      'Move': profile.recentContributions.length,
    };
    final Map<String, int> impact = <String, int>{
      'Events': profile.stats.eventsOrganized,
      'Badges': profile.stats.badgesEarned,
    };

    if (isLarge) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: _metricCard('Network', network)),
          const SizedBox(width: 10),
          Expanded(child: _metricCard('Leadership', leadership)),
          const SizedBox(width: 10),
          Expanded(child: _metricCard('Impact', impact)),
        ],
      );
    }

    return Column(
      children: <Widget>[
        _metricCard('Network', network),
        const SizedBox(height: 10),
        _metricCard('Leadership', leadership),
        const SizedBox(height: 10),
        _metricCard('Impact', impact),
      ],
    );
  }

  Widget _metricCard(String title, Map<String, int> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.entries
                .map((MapEntry<String, int> e) => _metricPill(e.key, e.value))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _metricPill(String label, int value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedCounter(value: value),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _about(PublicUserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _kv('Bio', profile.about.bio),
          _kv('Occupation', profile.about.occupation),
          _kv('Languages', profile.about.languages.join(', ')),
          _kv('Interests', profile.about.interests.join(', ')),
          _kv('Community Vision', profile.about.socialImpact),
        ],
      ),
    );
  }

  Widget _achievementChips(PublicUserProfile profile) {
    final List<String> labels = <String>{
      ...profile.achievements,
      'Verified Leader',
      'Top Contributor',
      'Issue Solver',
      'Volunteer',
      'Community Hero',
    }.toList(growable: false);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels
          .map(
            (String text) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.goldLight),
                gradient: LinearGradient(
                  colors: <Color>[
                    AppColors.primaryGold.withValues(alpha: 0.14),
                    AppColors.goldLight.withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: AppColors.goldDeep,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _recentActivity(PublicUserProfile profile) {
    final Map<String, String> items = <String, String>{
      'Recent Posts': profile.recentPosts.isEmpty
          ? 'No recent posts'
          : profile.recentPosts.first,
      'Recent Videos': profile.recentVideos.isEmpty
          ? 'No recent videos'
          : profile.recentVideos.first,
      'Issues Raised': profile.recentIssues.isEmpty
          ? 'No recent issues'
          : profile.recentIssues.first,
      'Events Conducted': profile.recentEvents.isEmpty
          ? 'No recent events'
          : profile.recentEvents.first,
      'Community Contributions': profile.recentContributions.isEmpty
          ? 'No recent contributions'
          : profile.recentContributions.first,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: items.entries
            .map(
              (MapEntry<String, String> item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.fiber_manual_record_rounded,
                      size: 12,
                      color: AppColors.primaryGold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                          ),
                          children: <InlineSpan>[
                            TextSpan(
                              text: '${item.key}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(text: item.value),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _tabList(
    List<String> items,
    IconData icon, {
    String emptyLabel = 'Nothing to show yet',
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, int index) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  items[index],
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, int __) => const SizedBox(height: 10),
      itemCount: items.length,
    );
  }

  Widget _aboutTab(PublicUserProfile profile) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _about(profile),
        const SizedBox(height: 12),
        _achievementChips(profile),
        const SizedBox(height: 12),
        _mediaGrid(profile),
      ],
    );
  }

  Widget _mediaGrid(PublicUserProfile profile) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: profile.media.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (BuildContext context, int index) {
        final ProfileMedia media = profile.media[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(media.url, fit: BoxFit.cover),
              if (media.isVideo)
                const Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _reveal({required int order, required Widget child}) {
    final double start = (order * 0.08).clamp(0, 0.7);
    final Animation<double> animation = CurvedAnimation(
      parent: _introController,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * 16),
            child: child,
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _twoColumnDetail(String k1, String v1, String k2, String v2) {
    return Row(
      children: <Widget>[
        Expanded(child: _detailItem(k1, v1)),
        const SizedBox(width: 10),
        Expanded(child: _detailItem(k2, v2)),
      ],
    );
  }

  Widget _detailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  double _communityRating(PublicUserProfile profile) {
    final double base =
        profile.stats.communityPoints / math.max(profile.stats.posts, 1);
    return (3 + (base / 25)).clamp(1, 5).toDouble();
  }

  int _trustScore(PublicUserProfile profile) {
    return ((profile.stats.issuesSolved * 2) + profile.stats.followers ~/ 20)
        .clamp(35, 99);
  }

  String _leaderLevel(PublicUserProfile profile) {
    final int points = profile.stats.communityPoints;
    if (points >= 1500) return 'Platinum';
    if (points >= 900) return 'Gold';
    if (points >= 450) return 'Silver';
    return 'Rising';
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
          children: <InlineSpan>[
            TextSpan(
              text: '$k: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: v),
          ],
        ),
      ),
    );
  }

  void _onProfileMenu(String value) {
    if (value == 'block') {
      setState(() => _isBlocked = true);
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${value.replaceAll('_', ' ')} selected')),
      );
  }

  void _onFollowTap() {
    final PublicUserProfile profile = _profile!;
    setState(
      () => _profile = profile.copyWith(isFollowing: !profile.isFollowing),
    );
  }

  void _onMessageTap() {
    final PublicUserProfile profile = _profile!;
    final ChatPermissionResult result = ChatPermissionPolicy.canMessage(
      profile: profile,
      isBlocked: _isBlocked,
      currentUserId: 'me',
    );

    if (!result.allowed) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.reason)));
      return;
    }

    Navigator.of(context).pushNamed(
      '/messages/chat',
      arguments: ChatRouteArgs(
        conversationId: 'thread_${profile.id}',
        peerUserId: profile.id,
        peerName: profile.name,
        peerInitials: profile.avatarInitials,
        peerAvatar: profile.avatarImage,
        isVerified: profile.isVerified,
      ),
    );
  }

  String _date(DateTime dt) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _AnimatedFollowButton extends StatefulWidget {
  const _AnimatedFollowButton({required this.isFollowing, required this.onTap});

  final bool isFollowing;
  final VoidCallback onTap;

  @override
  State<_AnimatedFollowButton> createState() => _AnimatedFollowButtonState();
}

class _AnimatedFollowButtonState extends State<_AnimatedFollowButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        scale: _pressed ? 0.97 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.primaryGold, width: 1.5),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                widget.isFollowing
                    ? Icons.check_circle_rounded
                    : Icons.person_add_alt_rounded,
                color: AppColors.primaryGold,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isFollowing ? 'Following' : 'Follow',
                style: TextStyle(
                  color: AppColors.goldDeep,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      builder: (_, double animated, __) {
        return Text(
          animated.round().toString(),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        );
      },
    );
  }
}

class _ProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  _ProfileTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height + 8;

  @override
  double get maxExtent => tabBar.preferredSize.height + 8;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Material(
        color: AppColors.surface,
        elevation: overlapsContent ? 2 : 0,
        borderRadius: BorderRadius.circular(999),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ProfileTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}
