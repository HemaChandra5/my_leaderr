import 'dart:async';

import 'package:flutter/material.dart';

const String _homeRoute = '/home';
const String _trackRoute = '/track';
const String _communityRoute = '/community';
const String _eventsRoute = '/events';

const Color _goldAccent = Color(0xFFFFC63D);

class SearchExplorerScreen extends StatefulWidget {
  const SearchExplorerScreen({
    super.key,
    this.initialQuery = '',
    this.initialNavIndex = 4,
  });

  final String initialQuery;
  final int initialNavIndex;

  @override
  State<SearchExplorerScreen> createState() => _SearchExplorerScreenState();
}

class _SearchExplorerScreenState extends State<SearchExplorerScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late int _selectedNavIndex;

  Timer? _debounce;
  int _selectedFilterIndex = 0;
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _isListening = false;
  bool _hasMore = true;

  static const int _pageSize = 8;

  final List<String> _recentSearches = <String>[
    'Road Repair',
    'Blood Donation',
    'Hyderabad',
    'Ward 94',
    'Tree Plantation',
  ];

  static const List<String> _trendingSearches = <String>[
    '🔥 Water Supply',
    '🔥 Road Repair',
    '🔥 PMAY Scheme',
    '🔥 Blood Donation',
    '🔥 Women\'s Safety',
    '🔥 Digital India',
  ];

  static const List<String> _emptySuggestions = <String>[
    'Ward grievance redressal',
    'Citizen volunteers nearby',
    'Govt scholarships 2026',
    'Women safety initiatives',
    'Public health camps',
  ];

  static const List<_DiscoverItem> _discoverItems = <_DiscoverItem>[
    _DiscoverItem(
      'Popular Leaders',
      Icons.workspace_premium_rounded,
      'Leaders with high civic impact',
    ),
    _DiscoverItem(
      'Trending Communities',
      Icons.groups_rounded,
      'High-growth citizen communities',
    ),
    _DiscoverItem(
      'Top Volunteers',
      Icons.volunteer_activism_rounded,
      'Most active public contributors',
    ),
    _DiscoverItem(
      'Government Departments',
      Icons.account_balance_rounded,
      'Official public service departments',
    ),
    _DiscoverItem(
      'Featured NGOs',
      Icons.favorite_rounded,
      'Trusted civil organizations',
    ),
  ];

  static const List<String> _filters = <String>[
    'All',
    'People',
    'Leaders',
    'Posts',
    'Videos',
    'Events',
    'Issues',
    'Communities',
    'Government',
    'Schemes',
    'Projects',
    'Nearby',
    'Verified',
  ];

  static final List<_SearchItem> _seedData = <_SearchItem>[
    _SearchItem.people(
      title: 'Ramesh Kumar',
      subtitle: 'Assistant Engineer',
      location: 'Kukatpally, Hyderabad',
      isVerified: true,
    ),
    _SearchItem.leader(
      title: 'Sridevi Anand',
      subtitle: 'Ward Leader - Zone 3',
      location: 'Ward 94',
      isVerified: true,
    ),
    _SearchItem.issue(
      title: 'Drainage issue - Block B',
      subtitle: 'Water logging after rain',
      location: 'Kukatpally',
      status: 'In Progress',
      priority: 'High',
      isNearby: true,
    ),
    _SearchItem.post(
      title: 'Road repair completed near Green Way Hospital',
      subtitle: 'Citizens thanked department for rapid action',
      location: 'Ameerpet',
      likes: 146,
      comments: 32,
    ),
    _SearchItem.event(
      title: 'City Clean-up Drive',
      subtitle: 'Join your local volunteers this Sunday',
      location: 'NTR Grounds',
      eventDate: DateTime(2026, 7, 30, 10, 0),
    ),
    _SearchItem.video(
      title: 'How to raise civic complaints from My Leader',
      subtitle: 'Official onboarding video',
      location: 'Digital Learning',
      views: 4200,
      duration: '04:12',
    ),
    _SearchItem.community(
      title: 'Hyderabad Civic Warriors',
      subtitle: 'Neighborhood action and governance support',
      location: 'Hyderabad',
      members: 18200,
      isVerified: true,
    ),
    _SearchItem.scheme(
      title: 'PMAY Urban Housing',
      subtitle: 'Affordable housing support for families',
      location: 'India',
      eligibility: 'Income-based',
    ),
    _SearchItem.government(
      title: 'Water Works Department',
      subtitle: 'Public utility and supply management',
      location: 'State Secretariat',
      isVerified: true,
    ),
    _SearchItem.project(
      title: 'Drainage Modernization - Phase 2',
      subtitle: 'Smart flow mapping and widening works',
      location: 'Ward 91-96',
      status: 'Active',
      priority: 'Medium',
    ),
    _SearchItem.announcement(
      title: 'Monsoon Preparedness Advisory',
      subtitle: 'Guidelines for flood-prone localities',
      location: 'District Admin',
      isVerified: true,
    ),
    _SearchItem.volunteer(
      title: 'Blood Donation Volunteer Network',
      subtitle: 'Urgent donor coordination group',
      location: 'Citywide',
      members: 640,
    ),
    _SearchItem.poll(
      title: 'Which area needs streetlight upgrades first?',
      subtitle: 'Citizen priority poll',
      location: 'Zone 2',
    ),
    _SearchItem.document(
      title: 'Ward Infrastructure Baseline Report',
      subtitle: 'Public document - PDF',
      location: 'Open Data Portal',
    ),
    _SearchItem.bloodRequest(
      title: 'O+ Blood Needed - Government Hospital',
      subtitle: 'Verified emergency request',
      location: 'Secunderabad',
      isNearby: true,
      isVerified: true,
    ),
    _SearchItem.people(
      title: 'Asha Priya',
      subtitle: 'Community Mobilizer',
      location: 'Madhapur',
      isNearby: true,
    ),
    _SearchItem.event(
      title: 'Drainage Awareness Workshop',
      subtitle: 'Interactive civic session',
      location: 'Community Hall, Ward 94',
      eventDate: DateTime(2026, 8, 2, 17, 30),
      isNearby: true,
    ),
    _SearchItem.video(
      title: 'Drainage Projects Explained',
      subtitle: 'Department briefing',
      location: 'Civic Media',
      views: 12800,
      duration: '08:40',
    ),
    _SearchItem.issue(
      title: 'Streetlight outage near school',
      subtitle: 'Dark zone causing safety concerns',
      location: 'Begumpet',
      status: 'Pending',
      priority: 'High',
      isNearby: true,
    ),
    _SearchItem.community(
      title: 'Women Safety Collective',
      subtitle: 'Safety patrol and awareness network',
      location: 'Citywide',
      members: 9200,
      isVerified: true,
    ),
  ];

  List<_SearchItem> _allResults = <_SearchItem>[];
  List<_SearchItem> _matchedResults = <_SearchItem>[];
  List<_SearchItem> _visibleResults = <_SearchItem>[];
  List<String> _aiSuggestions = <String>[];

  String get _query => _searchController.text.trim();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _scrollController = ScrollController()..addListener(_onScroll);
    _selectedNavIndex = widget.initialNavIndex.clamp(0, 4);
    _allResults = List<_SearchItem>.from(_seedData);
    _runSearch(immediate: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_selectedNavIndex == index) {
      return;
    }
    setState(() => _selectedNavIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, _homeRoute);
    }
    if (index == 1) {
      Navigator.pushReplacementNamed(context, _trackRoute);
    }
    if (index == 2) {
      Navigator.pushReplacementNamed(context, _communityRoute);
    }
    if (index == 3) {
      Navigator.pushReplacementNamed(context, _eventsRoute);
    }
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore) {
      return;
    }
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 220) {
      _loadMore();
    }
  }

  void _runSearch({bool immediate = false}) {
    _debounce?.cancel();

    if (immediate) {
      _applySearch();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 320), _applySearch);
  }

  void _applySearch() {
    final String normalized = _query.toLowerCase();
    final String selectedFilter = _filters[_selectedFilterIndex];

    final List<_SearchItem> matched = _allResults
        .where((item) {
          final bool filterMatch = _matchesFilter(selectedFilter, item);
          if (!filterMatch) {
            return false;
          }

          if (normalized.isEmpty) {
            return true;
          }

          return item.title.toLowerCase().contains(normalized) ||
              item.subtitle.toLowerCase().contains(normalized) ||
              item.location.toLowerCase().contains(normalized) ||
              item.typeLabel.toLowerCase().contains(normalized);
        })
        .toList(growable: false);

    setState(() {
      _matchedResults = matched;
      _aiSuggestions = _buildAiSuggestions(_query);
      _currentPage = 0;
      _visibleResults = <_SearchItem>[];
      _hasMore = matched.isNotEmpty;
    });

    _appendPage();
  }

  bool _matchesFilter(String filter, _SearchItem item) {
    switch (filter) {
      case 'All':
        return true;
      case 'People':
        return item.type == _SearchType.people;
      case 'Leaders':
        return item.type == _SearchType.leader;
      case 'Posts':
        return item.type == _SearchType.post;
      case 'Videos':
        return item.type == _SearchType.video;
      case 'Events':
        return item.type == _SearchType.event;
      case 'Issues':
        return item.type == _SearchType.issue;
      case 'Communities':
        return item.type == _SearchType.community;
      case 'Government':
        return item.type == _SearchType.government ||
            item.type == _SearchType.announcement;
      case 'Schemes':
        return item.type == _SearchType.scheme;
      case 'Projects':
        return item.type == _SearchType.project;
      case 'Nearby':
        return item.isNearby;
      case 'Verified':
        return item.isVerified;
      default:
        return true;
    }
  }

  void _appendPage() {
    if (_isLoadingMore || !_hasMore) {
      return;
    }

    setState(() => _isLoadingMore = true);

    Future<void>.delayed(const Duration(milliseconds: 240), () {
      if (!mounted) {
        return;
      }

      final int start = _currentPage * _pageSize;
      final int end = (start + _pageSize).clamp(0, _matchedResults.length);

      if (start >= _matchedResults.length) {
        setState(() {
          _hasMore = false;
          _isLoadingMore = false;
        });
        return;
      }

      setState(() {
        _visibleResults = <_SearchItem>[
          ..._visibleResults,
          ..._matchedResults.sublist(start, end),
        ];
        _currentPage += 1;
        _hasMore = end < _matchedResults.length;
        _isLoadingMore = false;
      });
    });
  }

  void _loadMore() {
    _appendPage();
  }

  void _addRecentSearch(String query) {
    final String value = query.trim();
    if (value.isEmpty) {
      return;
    }

    setState(() {
      _recentSearches.removeWhere(
        (element) => element.toLowerCase() == value.toLowerCase(),
      );
      _recentSearches.insert(0, value);
      if (_recentSearches.length > 8) {
        _recentSearches.removeLast();
      }
    });
  }

  void _onSubmitSearch(String query) {
    _addRecentSearch(query);
    _runSearch(immediate: true);
    FocusScope.of(context).unfocus();
  }

  void _onTapChipSearch(String value) {
    _searchController
      ..text = value
      ..selection = TextSelection.collapsed(offset: value.length);
    _onSubmitSearch(value);
  }

  Future<void> _startVoiceSearch() async {
    if (_isListening) {
      return;
    }

    setState(() => _isListening = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }

    const String heardQuery = 'Drainage';
    _searchController
      ..text = heardQuery
      ..selection = TextSelection.collapsed(offset: heardQuery.length);
    setState(() => _isListening = false);
    _onSubmitSearch(heardQuery);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice search recognized: Drainage'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  List<String> _buildAiSuggestions(String query) {
    final String normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return <String>[];
    }

    if (normalized.contains('drainage')) {
      return <String>[
        'Drainage Issues',
        'Drainage Projects',
        'Drainage Officials',
        'Nearby Drainage Complaints',
        'Drainage Videos',
        'Drainage Events',
        'Drainage Government Department',
      ];
    }

    return <String>[
      '$query Issues',
      '$query Events',
      '$query Communities',
      '$query Government Resources',
      '$query Nearby Results',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xFF050505) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              _goldAccent.withValues(alpha: isDark ? 0.09 : 0.14),
              bg,
              bg,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _buildHeader(theme),
              _buildSearchBar(theme),
              const SizedBox(height: 10),
              _buildFilters(theme),
              const SizedBox(height: 10),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: _query.isEmpty
                      ? _buildExploreHub(theme)
                      : _buildSearchResults(theme),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final Color onSurface = theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: <Widget>[
          Icon(Icons.hub_rounded, color: _goldAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'My Leader Civic Intelligence Hub',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: onSurface,
                letterSpacing: 0.2,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    final bool hasText = _query.isNotEmpty;

    return Hero(
      tag: 'global-search-bar-hero',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Material(
          color: Colors.transparent,
          child: SearchBar(
            controller: _searchController,
            elevation: WidgetStateProperty.all(0),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 14),
            ),
            hintText: 'Search people, issues, events, videos, communities...',
            leading: const Icon(Icons.search_rounded),
            onChanged: (_) => _runSearch(),
            onSubmitted: _onSubmitSearch,
            trailing: <Widget>[
              IconButton(
                tooltip: 'Voice Search',
                onPressed: _startVoiceSearch,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    _isListening ? Icons.graphic_eq : Icons.mic_none_rounded,
                    key: ValueKey<bool>(_isListening),
                    color: _isListening ? _goldAccent : null,
                  ),
                ),
              ),
              if (hasText)
                IconButton(
                  tooltip: 'Clear',
                  onPressed: () {
                    _searchController.clear();
                    _runSearch(immediate: true);
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              IconButton(
                tooltip: 'Filter',
                onPressed: () {
                  _scrollToTop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Use category chips to filter globally.'),
                      duration: Duration(milliseconds: 1100),
                    ),
                  );
                },
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) {
          final bool selected = _selectedFilterIndex == index;
          return AnimatedScale(
            scale: selected ? 1 : 0.97,
            duration: const Duration(milliseconds: 180),
            child: FilterChip(
              selected: selected,
              label: Text(_filters[index]),
              onSelected: (_) {
                setState(() => _selectedFilterIndex = index);
                _runSearch(immediate: true);
              },
              selectedColor: _goldAccent.withValues(alpha: 0.24),
              checkmarkColor: _goldAccent,
              side: BorderSide(
                color: selected
                    ? _goldAccent.withValues(alpha: 0.8)
                    : theme.colorScheme.outline.withValues(alpha: 0.45),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExploreHub(ThemeData theme) {
    return ListView(
      key: const ValueKey<String>('explore-hub-list'),
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      children: <Widget>[
        _fadeIn(0, _welcomeCard(theme)),
        const SizedBox(height: 14),
        _fadeIn(
          1,
          _chipSection(
            theme,
            title: 'Search Suggestions',
            chips: _emptySuggestions,
          ),
        ),
        const SizedBox(height: 14),
        _fadeIn(2, _recentSearchSection(theme)),
        const SizedBox(height: 14),
        _fadeIn(
          3,
          _chipSection(
            theme,
            title: 'Trending Searches',
            chips: _trendingSearches,
          ),
        ),
        const SizedBox(height: 16),
        _fadeIn(4, _sectionTitle(theme, 'Discover')),
        const SizedBox(height: 10),
        _fadeIn(5, _discoverCarousel(theme)),
        const SizedBox(height: 18),
        _fadeIn(6, _twoColumnCards(theme)),
      ],
    );
  }

  Widget _welcomeCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(theme, emphasized: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _goldAccent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: _goldAccent,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Welcome back',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Discover leaders, schemes, issues, events, communities, and civic intelligence from one global command center.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _recentSearchSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _sectionTitle(theme, 'Recent Searches'),
              const Spacer(),
              TextButton(
                onPressed: _recentSearches.isEmpty
                    ? null
                    : () => setState(_recentSearches.clear),
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches
                .map(
                  (value) => ActionChip(
                    label: Text(value),
                    avatar: const Icon(Icons.history_rounded, size: 16),
                    onPressed: () => _onTapChipSearch(value),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _chipSection(
    ThemeData theme, {
    required String title,
    required List<String> chips,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionTitle(theme, title),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (value) => AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    child: ActionChip(
                      label: Text(value),
                      onPressed: () =>
                          _onTapChipSearch(value.replaceFirst('🔥 ', '')),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _discoverCarousel(ThemeData theme) {
    return SizedBox(
      height: 158,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _discoverItems.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final _DiscoverItem item = _discoverItems[index];
          return Hero(
            tag: 'discover-${item.title}',
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 230,
                padding: const EdgeInsets.all(14),
                decoration: _cardDecoration(theme, emphasized: index == 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(item.icon, color: _goldAccent),
                    const SizedBox(height: 10),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    const Text(
                      'Explore →',
                      style: TextStyle(color: _goldAccent),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _twoColumnCards(ThemeData theme) {
    final List<_MiniSection> sections = <_MiniSection>[
      const _MiniSection(
        'Nearby Activity',
        Icons.near_me_rounded,
        '12 new updates around your current zone.',
      ),
      const _MiniSection(
        'Popular Leaders',
        Icons.workspace_premium_rounded,
        'High trust leaders trending this week.',
      ),
      const _MiniSection(
        'Trending Community Posts',
        Icons.dynamic_feed_rounded,
        'Most discussed civic updates by citizens.',
      ),
      const _MiniSection(
        'Upcoming Events',
        Icons.event_available_rounded,
        '6 events in the next 10 days.',
      ),
      const _MiniSection(
        'Government Announcements',
        Icons.campaign_rounded,
        'Latest verified notices and advisories.',
      ),
      const _MiniSection(
        'Suggested Communities',
        Icons.forum_rounded,
        'Join groups aligned to your interests.',
      ),
      const _MiniSection(
        'Volunteer Opportunities',
        Icons.volunteer_activism_rounded,
        'Immediate opportunities near you.',
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWide = constraints.maxWidth >= 740;
        final bool isCompact = constraints.maxWidth < 390;
        final int columns = isWide ? 3 : 2;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: sections.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: isWide
                ? 1.35
                : isCompact
                ? 0.92
                : 0.98,
          ),
          itemBuilder: (BuildContext context, int index) {
            final _MiniSection section = sections[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: _cardDecoration(theme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(section.icon, color: _goldAccent),
                  const SizedBox(height: 8),
                  Text(
                    section.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      section.body,
                      style: theme.textTheme.bodySmall,
                      maxLines: isCompact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => _onTapChipSearch(section.title),
                    child: const Text('Open'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    return ListView(
      key: const ValueKey<String>('search-results-list'),
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      children: <Widget>[
        if (_aiSuggestions.isNotEmpty) ...<Widget>[
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: _cardDecoration(theme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _sectionTitle(theme, 'Smart AI Suggestions'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _aiSuggestions
                        .map(
                          (value) => ActionChip(
                            label: Text(value),
                            avatar: const Icon(Icons.auto_awesome, size: 16),
                            onPressed: () => _onTapChipSearch(value),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_visibleResults.isEmpty)
          _emptyResults(theme)
        else
          ..._visibleResults.asMap().entries.map(
            (entry) => _fadeIn(
              entry.key,
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildResultCard(theme, entry.value),
              ),
            ),
          ),
        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (!_isLoadingMore && _hasMore && _visibleResults.isNotEmpty)
          TextButton.icon(
            onPressed: _loadMore,
            icon: const Icon(Icons.expand_more_rounded),
            label: const Text('Load more'),
          ),
      ],
    );
  }

  Widget _emptyResults(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(theme, emphasized: true),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'No exact match for "$_query"',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try nearby, trending, and government-backed resources below.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _chipSection(
          theme,
          title: 'Similar Results',
          chips: <String>[
            '$_query services',
            '$_query projects',
            '$_query community',
          ],
        ),
        const SizedBox(height: 10),
        _chipSection(
          theme,
          title: 'Nearby Results',
          chips: const <String>[
            'Nearby grievances',
            'Nearby events',
            'Nearby volunteers',
          ],
        ),
        const SizedBox(height: 10),
        _chipSection(
          theme,
          title: 'Trending Results',
          chips: _trendingSearches,
        ),
        const SizedBox(height: 10),
        _chipSection(
          theme,
          title: 'Government Resources',
          chips: const <String>[
            'Public Department Directory',
            'Citizen Charter',
            'Urban Mission Dashboard',
          ],
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () => _onTapChipSearch('Create issue: $_query'),
          style: FilledButton.styleFrom(
            backgroundColor: _goldAccent,
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(48),
          ),
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: const Text('Create New Issue'),
        ),
      ],
    );
  }

  Widget _buildResultCard(ThemeData theme, _SearchItem item) {
    switch (item.type) {
      case _SearchType.people:
      case _SearchType.leader:
        return _personCard(theme, item);
      case _SearchType.event:
        return _eventCard(theme, item);
      case _SearchType.post:
        return _postCard(theme, item);
      case _SearchType.video:
        return _videoCard(theme, item);
      case _SearchType.issue:
        return _issueCard(theme, item);
      case _SearchType.community:
      case _SearchType.volunteer:
        return _communityCard(theme, item);
      case _SearchType.scheme:
        return _schemeCard(theme, item);
      default:
        return _genericCard(theme, item);
    }
  }

  Widget _personCard(ThemeData theme, _SearchItem item) {
    return Container(
      decoration: _cardDecoration(theme),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Hero(
          tag: 'profile-${item.title}',
          child: CircleAvatar(
            backgroundColor: _goldAccent.withValues(alpha: 0.2),
            child: Text(item.title.characters.first.toUpperCase()),
          ),
        ),
        title: Text(item.title),
        subtitle: Text('${item.subtitle} • ${item.location}'),
        trailing: Wrap(
          spacing: 6,
          children: <Widget>[
            OutlinedButton(onPressed: () {}, child: const Text('Follow')),
            FilledButton.tonal(onPressed: () {}, child: const Text('Message')),
          ],
        ),
      ),
    );
  }

  Widget _eventCard(ThemeData theme, _SearchItem item) {
    final DateTime now = DateTime.now();
    final DateTime date = item.eventDate ?? now;
    final Duration diff = date.difference(now);
    final String countdown = diff.isNegative
        ? 'Live now'
        : '${diff.inDays}d ${diff.inHours.remainder(24)}h left';

    return Container(
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _goldAccent.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: const Center(
              child: Icon(Icons.event_rounded, color: _goldAccent, size: 34),
            ),
          ),
          ListTile(
            title: Text(item.title),
            subtitle: Text('${item.location} • $countdown'),
            trailing: FilledButton(
              onPressed: () {},
              child: const Text('Register'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _postCard(ThemeData theme, _SearchItem item) {
    return Container(
      decoration: _cardDecoration(theme),
      child: Column(
        children: <Widget>[
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.75,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: const Icon(Icons.image_rounded, size: 36),
          ),
          ListTile(title: Text(item.title), subtitle: Text(item.subtitle)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              children: <Widget>[
                const Icon(Icons.favorite_border_rounded, size: 18),
                const SizedBox(width: 4),
                Text('${item.likes}'),
                const SizedBox(width: 14),
                const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                const SizedBox(width: 4),
                Text('${item.comments}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoCard(ThemeData theme, _SearchItem item) {
    return Container(
      decoration: _cardDecoration(theme),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.75,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: const Icon(Icons.ondemand_video_rounded, size: 36),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    child: Text(
                      item.duration ?? '00:00',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ListTile(
            title: Text(item.title),
            subtitle: Text('${item.subtitle} • ${item.views} views'),
          ),
        ],
      ),
    );
  }

  Widget _issueCard(ThemeData theme, _SearchItem item) {
    return Container(
      decoration: _cardDecoration(theme),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: const CircleAvatar(child: Icon(Icons.report_problem_rounded)),
        title: Text(item.title),
        subtitle: Text(
          '${item.subtitle}\nStatus: ${item.status} • Priority: ${item.priority}',
        ),
        isThreeLine: true,
        trailing: OutlinedButton(onPressed: () {}, child: const Text('Track')),
      ),
    );
  }

  Widget _communityCard(ThemeData theme, _SearchItem item) {
    return Container(
      decoration: _cardDecoration(theme),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: const CircleAvatar(child: Icon(Icons.groups_rounded)),
        title: Text(item.title),
        subtitle: Text('${item.subtitle}\n${item.members ?? 0} members'),
        isThreeLine: true,
        trailing: FilledButton.tonal(
          onPressed: () {},
          child: const Text('Join'),
        ),
      ),
    );
  }

  Widget _schemeCard(ThemeData theme, _SearchItem item) {
    return Container(
      decoration: _cardDecoration(theme),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: const CircleAvatar(child: Icon(Icons.policy_rounded)),
        title: Text(item.title),
        subtitle: Text('Eligibility: ${item.eligibility ?? 'Check portal'}'),
        trailing: FilledButton(onPressed: () {}, child: const Text('Apply')),
      ),
    );
  }

  Widget _genericCard(ThemeData theme, _SearchItem item) {
    return Container(
      decoration: _cardDecoration(theme),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _goldAccent.withValues(alpha: 0.15),
          child: Icon(item.icon, color: _goldAccent),
        ),
        title: Text(item.title),
        subtitle: Text('${item.typeLabel} • ${item.subtitle}'),
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    final List<_NavItem> navItems = <_NavItem>[
      const _NavItem('Home', Icons.home_rounded),
      const _NavItem('Track', Icons.track_changes_rounded),
      const _NavItem('Community', Icons.groups_2_rounded),
      const _NavItem('Events', Icons.event_rounded),
      const _NavItem('Search', Icons.search_rounded),
    ];

    return Container(
      height: 76,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: List<Widget>.generate(navItems.length, (int index) {
          final bool selected = index == _selectedNavIndex;
          return Expanded(
            child: InkWell(
              onTap: () => _onNavTap(index),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: selected
                      ? _goldAccent.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? _goldAccent.withValues(alpha: 0.7)
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      navItems[index].icon,
                      color: selected
                          ? _goldAccent
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      navItems[index].label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: selected
                            ? _goldAccent
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
    );
  }

  Widget _fadeIn(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 220 + (index * 35)),
      curve: Curves.easeOut,
      builder: (BuildContext context, double value, Widget? animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }

  BoxDecoration _cardDecoration(ThemeData theme, {bool emphasized = false}) {
    final bool isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        colors: emphasized
            ? <Color>[
                _goldAccent.withValues(alpha: isDark ? 0.16 : 0.2),
                theme.colorScheme.surface,
              ]
            : <Color>[
                theme.colorScheme.surface.withValues(alpha: 0.95),
                theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: emphasized
            ? _goldAccent.withValues(alpha: 0.45)
            : theme.colorScheme.outline.withValues(alpha: 0.22),
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.07),
          blurRadius: emphasized ? 20 : 12,
          spreadRadius: emphasized ? 0 : -2,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _DiscoverItem {
  const _DiscoverItem(this.title, this.icon, this.subtitle);

  final String title;
  final IconData icon;
  final String subtitle;
}

class _MiniSection {
  const _MiniSection(this.title, this.icon, this.body);

  final String title;
  final IconData icon;
  final String body;
}

enum _SearchType {
  people,
  leader,
  post,
  video,
  event,
  issue,
  community,
  government,
  scheme,
  volunteer,
  poll,
  announcement,
  project,
  bloodRequest,
  document,
}

class _SearchItem {
  const _SearchItem._({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.location,
    this.isVerified = false,
    this.isNearby = false,
    this.likes,
    this.comments,
    this.views,
    this.duration,
    this.eventDate,
    this.status,
    this.priority,
    this.members,
    this.eligibility,
  });

  final _SearchType type;
  final String title;
  final String subtitle;
  final String location;
  final bool isVerified;
  final bool isNearby;
  final int? likes;
  final int? comments;
  final int? views;
  final String? duration;
  final DateTime? eventDate;
  final String? status;
  final String? priority;
  final int? members;
  final String? eligibility;

  String get typeLabel {
    switch (type) {
      case _SearchType.people:
        return 'People';
      case _SearchType.leader:
        return 'Leader';
      case _SearchType.post:
        return 'Post';
      case _SearchType.video:
        return 'Video';
      case _SearchType.event:
        return 'Event';
      case _SearchType.issue:
        return 'Issue';
      case _SearchType.community:
        return 'Community';
      case _SearchType.government:
        return 'Government';
      case _SearchType.scheme:
        return 'Scheme';
      case _SearchType.volunteer:
        return 'Volunteer';
      case _SearchType.poll:
        return 'Poll';
      case _SearchType.announcement:
        return 'Announcement';
      case _SearchType.project:
        return 'Project';
      case _SearchType.bloodRequest:
        return 'Blood Request';
      case _SearchType.document:
        return 'Document';
    }
  }

  IconData get icon {
    switch (type) {
      case _SearchType.people:
      case _SearchType.leader:
        return Icons.person_rounded;
      case _SearchType.post:
        return Icons.feed_rounded;
      case _SearchType.video:
        return Icons.play_circle_fill_rounded;
      case _SearchType.event:
        return Icons.event_rounded;
      case _SearchType.issue:
        return Icons.report_problem_rounded;
      case _SearchType.community:
        return Icons.groups_rounded;
      case _SearchType.government:
        return Icons.account_balance_rounded;
      case _SearchType.scheme:
        return Icons.policy_rounded;
      case _SearchType.volunteer:
        return Icons.volunteer_activism_rounded;
      case _SearchType.poll:
        return Icons.poll_rounded;
      case _SearchType.announcement:
        return Icons.campaign_rounded;
      case _SearchType.project:
        return Icons.architecture_rounded;
      case _SearchType.bloodRequest:
        return Icons.bloodtype_rounded;
      case _SearchType.document:
        return Icons.description_rounded;
    }
  }

  factory _SearchItem.people({
    required String title,
    required String subtitle,
    required String location,
    bool isVerified = false,
    bool isNearby = false,
  }) {
    return _SearchItem._(
      type: _SearchType.people,
      title: title,
      subtitle: subtitle,
      location: location,
      isVerified: isVerified,
      isNearby: isNearby,
    );
  }

  factory _SearchItem.leader({
    required String title,
    required String subtitle,
    required String location,
    bool isVerified = false,
  }) {
    return _SearchItem._(
      type: _SearchType.leader,
      title: title,
      subtitle: subtitle,
      location: location,
      isVerified: isVerified,
    );
  }

  factory _SearchItem.post({
    required String title,
    required String subtitle,
    required String location,
    int likes = 0,
    int comments = 0,
  }) {
    return _SearchItem._(
      type: _SearchType.post,
      title: title,
      subtitle: subtitle,
      location: location,
      likes: likes,
      comments: comments,
    );
  }

  factory _SearchItem.video({
    required String title,
    required String subtitle,
    required String location,
    int views = 0,
    String duration = '00:00',
  }) {
    return _SearchItem._(
      type: _SearchType.video,
      title: title,
      subtitle: subtitle,
      location: location,
      views: views,
      duration: duration,
    );
  }

  factory _SearchItem.event({
    required String title,
    required String subtitle,
    required String location,
    DateTime? eventDate,
    bool isNearby = false,
  }) {
    return _SearchItem._(
      type: _SearchType.event,
      title: title,
      subtitle: subtitle,
      location: location,
      eventDate: eventDate,
      isNearby: isNearby,
    );
  }

  factory _SearchItem.issue({
    required String title,
    required String subtitle,
    required String location,
    String status = 'Pending',
    String priority = 'Medium',
    bool isNearby = false,
  }) {
    return _SearchItem._(
      type: _SearchType.issue,
      title: title,
      subtitle: subtitle,
      location: location,
      status: status,
      priority: priority,
      isNearby: isNearby,
    );
  }

  factory _SearchItem.community({
    required String title,
    required String subtitle,
    required String location,
    int members = 0,
    bool isVerified = false,
  }) {
    return _SearchItem._(
      type: _SearchType.community,
      title: title,
      subtitle: subtitle,
      location: location,
      members: members,
      isVerified: isVerified,
    );
  }

  factory _SearchItem.scheme({
    required String title,
    required String subtitle,
    required String location,
    required String eligibility,
  }) {
    return _SearchItem._(
      type: _SearchType.scheme,
      title: title,
      subtitle: subtitle,
      location: location,
      eligibility: eligibility,
    );
  }

  factory _SearchItem.government({
    required String title,
    required String subtitle,
    required String location,
    bool isVerified = false,
  }) {
    return _SearchItem._(
      type: _SearchType.government,
      title: title,
      subtitle: subtitle,
      location: location,
      isVerified: isVerified,
    );
  }

  factory _SearchItem.volunteer({
    required String title,
    required String subtitle,
    required String location,
    int members = 0,
  }) {
    return _SearchItem._(
      type: _SearchType.volunteer,
      title: title,
      subtitle: subtitle,
      location: location,
      members: members,
    );
  }

  factory _SearchItem.poll({
    required String title,
    required String subtitle,
    required String location,
  }) {
    return _SearchItem._(
      type: _SearchType.poll,
      title: title,
      subtitle: subtitle,
      location: location,
    );
  }

  factory _SearchItem.announcement({
    required String title,
    required String subtitle,
    required String location,
    bool isVerified = false,
  }) {
    return _SearchItem._(
      type: _SearchType.announcement,
      title: title,
      subtitle: subtitle,
      location: location,
      isVerified: isVerified,
    );
  }

  factory _SearchItem.project({
    required String title,
    required String subtitle,
    required String location,
    String status = 'Active',
    String priority = 'Medium',
  }) {
    return _SearchItem._(
      type: _SearchType.project,
      title: title,
      subtitle: subtitle,
      location: location,
      status: status,
      priority: priority,
    );
  }

  factory _SearchItem.bloodRequest({
    required String title,
    required String subtitle,
    required String location,
    bool isNearby = false,
    bool isVerified = false,
  }) {
    return _SearchItem._(
      type: _SearchType.bloodRequest,
      title: title,
      subtitle: subtitle,
      location: location,
      isNearby: isNearby,
      isVerified: isVerified,
    );
  }

  factory _SearchItem.document({
    required String title,
    required String subtitle,
    required String location,
  }) {
    return _SearchItem._(
      type: _SearchType.document,
      title: title,
      subtitle: subtitle,
      location: location,
    );
  }
}
