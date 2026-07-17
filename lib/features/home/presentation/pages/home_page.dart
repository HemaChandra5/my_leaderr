import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';

import '../widgets/bottom_navigation.dart';
import '../widgets/category_tabs.dart';
import '../widgets/home_header.dart';
import '../widgets/post_card.dart';

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
    if (_showSearchBar) {
      _closeSearchBar();
      return;
    }

    setState(() {
      _showSearchBar = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
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
    final Color sheetBg = isDark ? const Color(0xff141414) : Colors.white;
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
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
                    height: 4,
                    decoration: BoxDecoration(
                      color: grip,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _tr('notifications'),
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...alerts.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xffF5A623),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              color: alertText,
                              fontSize: 14,
                              height: 1.35,
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
        category: category,
        leaderName: leaderName,
        role: role,
        timeAgo: '${(index % 8) + 1}h',
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
            ? const Color(0xFF161B22)
            : const Color(0xFFEFF3F8);
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

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _handleOutsideTap,
          child: Scaffold(
            backgroundColor: pageBg,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
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
                            onSearchTap: _toggleSearchBar,
                            onLogoTap: _scrollFeedToTop,
                            searchActive: _showSearchBar,
                            searchController: _searchController,
                            searchFocusNode: _searchFocusNode,
                            onSearchChanged: (_) => setState(() {}),
                            searchHintText: _tr('search_meetings'),
                            searchFieldColor: fieldBg,
                            searchTextColor: primaryText,
                            searchHintColor: secondaryText,
                          ),
                          const SizedBox(height: 0),
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
                          const SizedBox(height: 12),
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
                              child: NotificationListener<UserScrollNotification>(
                                onNotification: (notification) {
                                  _handleFeedScroll(notification);
                                  return false;
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
                                    112,
                                  ),
                                  itemBuilder: (context, index) => PostCard(
                                    data: filteredFeed[index],
                                    onMenuTap: () => _trackAction('post_menu'),
                                    onLikeTap: () => _trackAction('post_like'),
                                    onCommentTap: () =>
                                        _trackAction('post_comment'),
                                    onShareTap: () => _trackAction('post_share'),
                                    onBoostTap: () => _trackAction('post_boost'),
                                    onBookmarkTap: () =>
                                        _trackAction('post_bookmark'),
                                  ),
                                  separatorBuilder: (_, index) =>
                                      const SizedBox(height: 18),
                                  itemCount: filteredFeed.length,
                                ),
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
            bottomNavigationBar: BottomNavigation(
              currentIndex: _selectedNavIndex,
              onItemSelected: _handleBottomNavSelection,
            ),
          ),
        );
      },
    );
  }
}
