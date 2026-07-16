import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../main.dart';
import '../../../messaging/models/public_user_profile.dart';

import '../widgets/bottom_navigation.dart';
import '../widgets/category_tabs.dart';
import '../widgets/home_header.dart';
import '../widgets/post_card.dart';
import '../../../search/presentation/pages/search_explorer_screen.dart';

const String _eventsRoute = '/events';
const String _trackRoute = '/track';
const String _communityRoute = '/community';
const String _profileRoute = '/profile';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;
  int _selectedNavIndex = 0;
  bool _showSearchBar = false;
  final ScrollController _feedScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  static const List<String> _localNames = [
    'Aarav Sharma',
    'Priya Nandan',
    'Rohit Menon',
    'Sana Qureshi',
    'Manav Gupta',
    'Aditi Jain',
    'Vikram Sethi',
    'Riya Kapoor',
    'Tarun Bedi',
    'Neha Thomas',
  ];

  static const List<String> _stateNames = [
    'Nisha Verma',
    'Rahul Joshi',
    'Ishita Rao',
    'Karan Shetty',
    'Mehul Rana',
    'Pooja Khatri',
    'Dhruv Patel',
    'Sanya Iyer',
    'Harsh Arora',
    'Divya Kaul',
  ];

  static const List<String> _nationalNames = [
    'Anika Mehra',
    'Kabir Rao',
    'Samar Khanna',
    'Tanya Bose',
    'Arjun Malhotra',
    'Mira Dutta',
    'Varun Nair',
    'Naina Bhasin',
    'Kushal Anand',
    'Siya Roy',
  ];

  String get _language => AppLanguage.instance.language;
  String _tr(String key) =>
      AppLocalizations.translate(key, language: _language);

  List<String> _localRoles() => [
    _tr('role_ward_coordinator'),
    _tr('role_municipal_lead'),
    _tr('role_community_officer'),
    _tr('role_block_supervisor'),
  ];

  List<String> _stateRoles() => [
    _tr('role_state_coordinator'),
    _tr('role_program_manager'),
    _tr('role_regional_director'),
    _tr('role_operations_lead'),
  ];

  List<String> _nationalRoles() => [
    _tr('role_national_strategy_lead'),
    _tr('role_operations_head'),
    _tr('role_policy_director'),
    _tr('role_transformation_lead'),
  ];

  List<String> _localMessages() => [
    _tr('local_msg_1'),
    _tr('local_msg_2'),
    _tr('local_msg_3'),
    _tr('local_msg_4'),
    _tr('local_msg_5'),
  ];

  List<String> _stateMessages() => [
    _tr('state_msg_1'),
    _tr('state_msg_2'),
    _tr('state_msg_3'),
    _tr('state_msg_4'),
    _tr('state_msg_5'),
  ];

  List<String> _nationalMessages() => [
    _tr('national_msg_1'),
    _tr('national_msg_2'),
    _tr('national_msg_3'),
    _tr('national_msg_4'),
    _tr('national_msg_5'),
  ];

  void _handleBottomNavSelection(int index) {
    setState(() => _selectedNavIndex = index);
    _trackAction('nav_${BottomNavigation.items[index].toLowerCase()}');

    if (index == 0) return;
    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(_trackRoute);
      return;
    }
    if (index == 2) {
      Navigator.of(context).pushReplacementNamed(_communityRoute);
      return;
    }
    if (index == 3) {
      Navigator.of(context).pushReplacementNamed(_eventsRoute);
      return;
    }

    Navigator.of(context).pushReplacementNamed(_profileRoute);
  }

  void _trackAction(String action) {
    assert(() {
      debugPrint('HomeAction: $action');
      return true;
    }());
  }

  void _openPublicProfile(PostCardData post) {
    Navigator.of(context).pushNamed(
      AppRoutes.publicProfile,
      arguments: PublicProfileRouteArgs(
        userId: post.userId,
        displayName: post.leaderName,
        heroTag: 'profile_avatar_${post.userId}',
      ),
    );
  }

  void _scrollFeedToTop() {
    if (!_feedScrollController.hasClients) {
      return;
    }
    _feedScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleSearchBar() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchExplorerScreen(
          initialQuery: _searchController.text,
          initialNavIndex: _selectedNavIndex,
        ),
      ),
    );
  }

  void _closeSearchBar() {
    if (!_showSearchBar) {
      return;
    }

    setState(() {
      _showSearchBar = false;
      _searchController.clear();
    });
    _searchFocusNode.unfocus();
  }

  void _handleOutsideTap() {
    if (_showSearchBar) {
      _closeSearchBar();
      return;
    }
    FocusScope.of(context).unfocus();
  }

  void _handleFeedScroll(UserScrollNotification notification) {
    if (_showSearchBar && notification.direction != ScrollDirection.idle) {
      _closeSearchBar();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _feedScrollController.dispose();
    super.dispose();
  }

  bool _matchesSearch(PostCardData post, String query) {
    final q = query.toLowerCase();
    return post.leaderName.toLowerCase().contains(q) ||
        post.role.toLowerCase().contains(q) ||
        post.description.toLowerCase().contains(q) ||
        post.category.toLowerCase().contains(q);
  }

  void _openNotificationsPanel() {
    _trackAction('notifications_open');
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color sheetBg = isDark ? const Color(0xff121212) : Colors.white;
    final Color grip = isDark
        ? const Color(0xff3A3A3A)
        : const Color(0xFFD0D7E2);
    final Color titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color alertText = isDark
        ? const Color(0xffE8E8E8)
        : const Color(0xFF334155);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final alerts = <String>[
          _tr('alert_community_report'),
          _tr('alert_state_digest'),
          _tr('alert_new_feedback'),
          _tr('alert_policy_briefing'),
        ];
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: grip,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _tr('notifications'),
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                ...alerts.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xff1a1a1a)
                          : const Color(0xfff8fafc),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xff2a2a2a)
                            : const Color(0xffe2e8f0),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xfff5a623,
                            ).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: Color(0xfff5a623),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              color: alertText,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<PostCardData> _buildFeed() {
    return [
      ..._generateCategoryFeed(
        category: 'Local',
        names: _localNames,
        roles: _localRoles(),
        messages: _localMessages(),
        count: 24,
      ),
      ..._generateCategoryFeed(
        category: 'State',
        names: _stateNames,
        roles: _stateRoles(),
        messages: _stateMessages(),
        count: 24,
      ),
      ..._generateCategoryFeed(
        category: 'National',
        names: _nationalNames,
        roles: _nationalRoles(),
        messages: _nationalMessages(),
        count: 24,
      ),
    ];
  }

  List<PostCardData> _generateCategoryFeed({
    required String category,
    required List<String> names,
    required List<String> roles,
    required List<String> messages,
    required int count,
  }) {
    return List<PostCardData>.generate(count, (index) {
      final leaderName = names[index % names.length];
      final role = roles[index % roles.length];
      final description = messages[index % messages.length];
      final String userId =
          'user_${leaderName.toLowerCase().replaceAll(' ', '_')}';
      final initials = leaderName
          .split(' ')
          .where((part) => part.isNotEmpty)
          .take(2)
          .map((part) => part[0])
          .join();

      final avatarIndex = (index % 4) + 1;
      final likes = 220 + ((index * 39) % 1800);
      final comments = 28 + ((index * 11) % 260);
      final shares = 12 + ((index * 7) % 140);
      final boosts = 8 + ((index * 5) % 120);
      final saves = 4 + ((index * 3) % 95);
      final minutes = 1 + ((index * 3) % 4);
      final seconds = (index * 13) % 60;

      return PostCardData(
        userId: userId,
        category: category,
        leaderName: leaderName,
        role: role,
        ward: 'Ward ${(index % 32) + 1}',
        city: 'Hyderabad',
        state: 'Telangana',
        timeAgo: '${(index % 8) + 1}h',
        joinDate: DateTime(2021 + (index % 3), ((index % 12) + 1), 5),
        description: description,
        likeCount: likes,
        commentCount: comments,
        shareCount: shares,
        boostCount: boosts,
        saveCount: saves,
        avatarAsset: 'assets/images/avatar$avatarIndex.png',
        avatarInitials: initials,
        isVerified: index % 3 != 0,
        mediaAsset: 'assets/images/cover.jpg',
        mediaDuration:
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLanguage.instance,
      builder: (context, _) {
        final feed = _buildFeed();
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final Color pageBg = Theme.of(context).scaffoldBackgroundColor;
        final Color primaryText = isDark
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF0F172A);
        final Color secondaryText = isDark
            ? const Color(0xFF8B949E)
            : const Color(0xFF64748B);
        final Color fieldBg = isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF1F5F9);
        final selectedTab = CategoryTabs.tabs[_selectedTabIndex];
        final query = _searchController.text.trim();
        final filteredFeed = feed
            .where((post) {
              if (post.category != selectedTab) {
                return false;
              }
              if (query.isEmpty) {
                return true;
              }
              return _matchesSearch(post, query);
            })
            .toList(growable: false);

        return Scaffold(
          backgroundColor: pageBg,
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: isDark
                ? const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF0A0A0A), Color(0xFF000000)],
                    ),
                  )
                : null,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth = constraints.maxWidth >= 600
                      ? 390.0
                      : constraints.maxWidth;

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentWidth),
                      child: Column(
                        children: [
                          HomeHeader(
                            onNotificationTap: _openNotificationsPanel,
                            onLogoTap: _scrollFeedToTop,
                            onSearchTap: _toggleSearchBar,
                            searchActive: _showSearchBar,
                            searchController: _searchController,
                            searchFocusNode: _searchFocusNode,
                            onSearchChanged: (_) => setState(() {}),
                            searchHintText: _tr('search_meetings'),
                            searchFieldColor: fieldBg,
                            searchTextColor: primaryText,
                            searchHintColor: secondaryText,
                          ),
                          const SizedBox(height: 12),

                          // Upgraded Search bar container
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: fieldBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(
                                    0xFFF5A623,
                                  ).withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (_) => setState(() {}),
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                ),
                                decoration: InputDecoration(
                                  hintText: _tr('search_meetings'),
                                  hintStyle: TextStyle(
                                    color: secondaryText,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: const Color(
                                      0xfff5a623,
                                    ).withValues(alpha: 0.8),
                                    size: 20,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {});
                                          },
                                          icon: Icon(
                                            Icons.close_rounded,
                                            color: secondaryText,
                                            size: 18,
                                          ),
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Category tabs
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CategoryTabs(
                              selectedIndex: _selectedTabIndex,
                              onTabSelected: (index) {
                                setState(() => _selectedTabIndex = index);
                                _trackAction(
                                  'tab_${CategoryTabs.tabs[index].toLowerCase()}',
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Feed List View
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final offsetAnimation = Tween<Offset>(
                                  begin: const Offset(0.02, 0),
                                  end: Offset.zero,
                                ).animate(animation);
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              child: ListView.separated(
                                key: ValueKey<String>(selectedTab),
                                controller: _feedScrollController,
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  2,
                                  16,
                                  24,
                                ),
                                itemBuilder: (context, index) => PostCard(
                                  data: filteredFeed[index],
                                  onMenuTap: () => _trackAction('post_menu'),
                                  onProfileTap: () =>
                                      _openPublicProfile(filteredFeed[index]),
                                  onLikeTap: () => _trackAction('post_like'),
                                  onCommentTap: () =>
                                      _trackAction('post_comment'),
                                  onShareTap: () => _trackAction('post_share'),
                                  onBoostTap: () => _trackAction('post_boost'),
                                  onBookmarkTap: () =>
                                      _trackAction('post_bookmark'),
                                ),
                                separatorBuilder: (_, index) =>
                                    const SizedBox(height: 16),
                                itemCount: filteredFeed.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigation(
            currentIndex: _selectedNavIndex,
            onItemSelected: _handleBottomNavSelection,
          ),
        );
      },
    );
  }
}
