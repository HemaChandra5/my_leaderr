import 'package:flutter/material.dart';

import '../widgets/bottom_navigation.dart';
import '../widgets/category_tabs.dart';
import '../widgets/home_header.dart';
import '../widgets/post_card.dart';

const String _eventsRoute = '/events';
const String _trackRoute = '/track';
const String _createMenuRoute = '/create-menu';
const String _profileRoute = '/profile';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;
  int _selectedNavIndex = 0;
  final ScrollController _feedScrollController = ScrollController();

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

  static const List<String> _localRoles = [
    'Ward Coordinator',
    'Municipal Lead',
    'Community Officer',
    'Block Supervisor',
  ];

  static const List<String> _stateRoles = [
    'State Coordinator',
    'Program Manager',
    'Regional Director',
    'Operations Lead',
  ];

  static const List<String> _nationalRoles = [
    'National Strategy Lead',
    'Operations Head',
    'Policy Director',
    'Transformation Lead',
  ];

  static const List<String> _localMessages = [
    'Ward-level service dashboard is now live with transparent SLA tracking and weekly closure reports.',
    'Drainage and road maintenance tickets are now mapped by locality to improve response time this quarter.',
    'Citizen helpdesk now supports real-time issue routing to reduce duplicate complaints and backlog.',
    'Night safety lighting program has entered phase two with predictive outage monitoring enabled.',
    'We completed 100 percent geotag verification for sanitation requests across all neighborhood clusters.',
  ];

  static const List<String> _stateMessages = [
    'State scholarship onboarding crossed major milestones with faster verification and reduced drop-offs.',
    'District scorecards now publish weekly governance KPIs for education, health, and response performance.',
    'State service registry has been normalized to improve cross-department reporting and governance audits.',
    'A new escalation matrix reduced critical issue turnaround time by over 30 percent in pilot districts.',
    'We have launched a unified state command view for service continuity and performance tracking.',
  ];

  static const List<String> _nationalMessages = [
    'National policy sprint delivered standardized digital service patterns now rolling out across departments.',
    'Cross-region command workflows are active with real-time escalation and measurable incident SLAs.',
    'National transformation framework now includes quarterly readiness scoring for platform-first delivery.',
    'Public service modernization roadmap has entered execution stage with focused KPI accountability.',
    'Inter-state operating model is now synchronized for data governance, reporting cadence, and resilience.',
  ];

  late final List<PostCardData> _feed = _buildFeed();

  void _handleBottomNavSelection(int index) {
    setState(() => _selectedNavIndex = index);
    _trackAction('nav_${BottomNavigation.items[index].toLowerCase()}');

    if (index == 0) {
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(_trackRoute);
      return;
    }

    if (index == 2) {
      Navigator.of(context).pushNamed(_createMenuRoute);
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

  @override
  void dispose() {
    _feedScrollController.dispose();
    super.dispose();
  }

  void _openNotificationsPanel() {
    _trackAction('notifications_open');
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xff141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        final alerts = <String>[
          'Community report approved in your ward.',
          'State analytics digest is ready to review.',
          'New feedback received from citizens.',
          'National policy briefing starts in 30 minutes.',
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
                      color: const Color(0xff3A3A3A),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
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
                            style: const TextStyle(
                              color: Color(0xffE8E8E8),
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
        roles: _localRoles,
        messages: _localMessages,
        count: 24,
      ),
      ..._generateCategoryFeed(
        category: 'State',
        names: _stateNames,
        roles: _stateRoles,
        messages: _stateMessages,
        count: 24,
      ),
      ..._generateCategoryFeed(
        category: 'National',
        names: _nationalNames,
        roles: _nationalRoles,
        messages: _nationalMessages,
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
    final selectedTab = CategoryTabs.tabs[_selectedTabIndex];
    final filteredFeed = _feed
        .where((post) => post.category == selectedTab)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xff090A0B),
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
                      onLogoTap: _scrollFeedToTop,
                    ),
                    const SizedBox(height: 18),
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
                    const SizedBox(height: 18),
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
                          padding: const EdgeInsets.fromLTRB(16, 2, 16, 112),
                          itemBuilder: (context, index) => PostCard(
                            data: filteredFeed[index],
                            onMenuTap: () => _trackAction('post_menu'),
                            onLikeTap: () => _trackAction('post_like'),
                            onCommentTap: () => _trackAction('post_comment'),
                            onShareTap: () => _trackAction('post_share'),
                            onBoostTap: () => _trackAction('post_boost'),
                            onBookmarkTap: () => _trackAction('post_bookmark'),
                          ),
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 18),
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
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedNavIndex,
        onItemSelected: _handleBottomNavSelection,
      ),
    );
  }
}
