import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter/services.dart';

const double _kGrid = 8;
const String _fontFamily = 'Inter';

const String _homeRoute = '/home';
const String _eventsRoute = '/events';
const String _trackRoute = '/track';
const String _createMenuRoute = '/create-menu';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color _background = Color(0xFF000000);
  static const Color _card = Color(0xFF111111);
  static const Color _gold = Color(0xFFF5A623);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFF8B949E);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _background,
        useMaterial3: true,
        fontFamily: _fontFamily,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: _background,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: const Text(
              'Home',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                fontFamily: _fontFamily,
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(_kGrid * 2),
              children: const <Widget>[
                _WelcomeCard(),
                SizedBox(height: _kGrid * 2),
                _QuickActionsCard(),
                SizedBox(height: _kGrid * 2),
                _StatsRow(),
              ],
            ),
          ),
          bottomNavigationBar: _BottomNavBar(
            onTap: (String route) {
              if (route == _homeRoute) {
                return;
              }

              if (route == _createMenuRoute) {
                Navigator.of(context).pushNamed(_createMenuRoute);
                return;
              }

              if (route == _eventsRoute || route == _trackRoute) {
                Navigator.of(context).pushReplacementNamed(route);
                return;
              }

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('This section is coming soon'),
                  ),
                );
            },
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_kGrid * 2),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x22F5A623)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
            'Welcome Back',
            style: TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 13,
              fontFamily: _fontFamily,
            ),
          ),
          SizedBox(height: _kGrid),
          Text(
            'MY LEADER Dashboard',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: _fontFamily,
            ),
          ),
          SizedBox(height: _kGrid),
          Text(
            'Track civic issues, follow events, and share updates with your community in one place.',
            style: TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 14,
              height: 1.4,
              fontFamily: _fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_kGrid * 2),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: _fontFamily,
            ),
          ),
          const SizedBox(height: _kGrid * 1.5),
          Row(
            children: <Widget>[
              Expanded(
                child: _ActionButton(
                  label: 'Open Events',
                  icon: Icons.event_outlined,
                  onTap: () =>
                      Navigator.of(context).pushReplacementNamed(_eventsRoute),
                ),
              ),
              const SizedBox(width: _kGrid),
              Expanded(
                child: _ActionButton(
                  label: 'Track Issue',
                  icon: Icons.track_changes_rounded,
                  onTap: () =>
                      Navigator.of(context).pushReplacementNamed(_trackRoute),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0x33F5A623)),
        foregroundColor: const Color(0xFFF5A623),
        padding: const EdgeInsets.symmetric(vertical: _kGrid * 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontFamily: _fontFamily)),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Expanded(
          child: _StatCard(
            label: 'Open Issues',
            value: '12',
            color: Color(0xFF3B82F6),
          ),
        ),
        SizedBox(width: _kGrid),
        Expanded(
          child: _StatCard(
            label: 'Upcoming Events',
            value: '5',
            color: Color(0xFFF5A623),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_kGrid * 2),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 12,
              fontFamily: _fontFamily,
            ),
          ),
          const SizedBox(height: _kGrid),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: _fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF161B22),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _kGrid * 2,
            vertical: _kGrid,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                active: true,
                onTap: () => onTap(_homeRoute),
              ),
              _NavItem(
                icon: Icons.track_changes_rounded,
                label: 'Track',
                active: false,
                onTap: () => onTap(_trackRoute),
              ),
              _AddButton(onTap: () => onTap(_createMenuRoute)),
              _NavItem(
                icon: Icons.event_outlined,
                label: 'Events',
                active: false,
                onTap: () => onTap(_eventsRoute),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                active: false,
                onTap: () => onTap('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_kGrid * 3),
          child: Ink(
            width: _kGrid * 6,
            height: _kGrid * 6,
            decoration: const BoxDecoration(
              color: Color(0xFFF5A623),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Color(0xFF000000), size: 24),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = active
        ? const Color(0xFFF5A623)
        : const Color(0xFF8B949E);

    return InkResponse(
      onTap: onTap,
      radius: _kGrid * 3,
      child: SizedBox(
        width: _kGrid * 7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: color, size: 22),
            const SizedBox(height: _kGrid / 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                fontFamily: _fontFamily,
              ),
            ),
          ],
        ),
=======

import '../widgets/bottom_navigation.dart';
import '../widgets/category_tabs.dart';
import '../widgets/home_header.dart';
import '../widgets/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;
  int _selectedNavIndex = 0;

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

  void _trackAction(String action) {
    assert(() {
      debugPrint('HomeAction: $action');
      return true;
    }());
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
                    HomeHeader(onNotificationTap: _openNotificationsPanel),
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab',
        elevation: 3,
        shape: const CircleBorder(),
        backgroundColor: const Color(0xffF5A623),
        onPressed: () => _trackAction('create_tap'),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedNavIndex,
        onItemSelected: (index) {
          setState(() => _selectedNavIndex = index);
          _trackAction('nav_${BottomNavigation.items[index].toLowerCase()}');
        },
>>>>>>> 54b773b9e0b229e6e98c691dfac2f3716867d032
      ),
    );
  }
}
