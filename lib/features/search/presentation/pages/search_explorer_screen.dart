import 'package:flutter/material.dart';

const String _homeRoute = '/home';
const String _trackRoute = '/track';
const String _communityRoute = '/community';
const String _eventsRoute = '/events';

class SearchExplorerScreen extends StatefulWidget {
  const SearchExplorerScreen({
    super.key,
    this.initialQuery = '',
    this.initialNavIndex = 4,
  });

  final String initialQuery;
  final int initialNavIndex;

  @override
  State<SearchExplorerScreen> createState() =>
      _SearchExplorerScreenState();
}

class _SearchExplorerScreenState
    extends State<SearchExplorerScreen> {
  late final TextEditingController _searchController;
  late int _selectedNavIndex;
  int _selectedFilterIndex = 0;

  static const List<String> _filters = [
    'All',
    'People',
    'Events',
    'Hashtags',
    'Issues',
  ];

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: widget.initialQuery);
    _selectedNavIndex = widget.initialNavIndex.clamp(0, 4);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _selectedNavIndex = index);
    if (index == 0) Navigator.pushReplacementNamed(context, _homeRoute);
    if (index == 1) Navigator.pushReplacementNamed(context, _trackRoute);
    if (index == 2)
      Navigator.pushReplacementNamed(context, _communityRoute);
    if (index == 3)
      Navigator.pushReplacementNamed(context, _eventsRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _searchBar(),
            const SizedBox(height: 12),
            _filtersRow(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _SectionTitle('Top Results'),
                  SizedBox(height: 12),
                  _ModernResultTile(
                    title:
                        'Drainage work completed in PKB Colony',
                    subtitle: 'Post • Green Way Hospital',
                    trailing: '2h ago',
                    isUpcoming: false,
                  ),
                  _ModernResultTile(
                    title:
                        'Drainage issue - Block B, Kukatpally',
                    subtitle:
                        'Issue • Reported by citizens',
                    trailing: '1d ago',
                    isUpcoming: false,
                  ),
                  _ModernResultTile(
                    title: 'Drainage Cleaning Drive',
                    subtitle: 'Event • February 2026',
                    trailing: 'Upcoming',
                    isUpcoming: true,
                  ),
                  SizedBox(height: 24),
                  _SectionTitle('People'),
                  SizedBox(height: 12),
                  _ModernPeopleTile(
                    name: 'Ramesh Kumar',
                    role: 'Assistant Engineer',
                  ),
                  _ModernPeopleTile(
                    name: 'Sridevi Anand',
                    role: 'Ward Member',
                  ),
                  SizedBox(height: 24),
                  _SectionTitle('Hashtags'),
                  SizedBox(height: 12),
                  _ModernHashtagTile(
                      tag: '#drainage',
                      count: '1.2K posts'),
                  _ModernHashtagTile(
                      tag: '#drainageclearing',
                      count: '420 posts'),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _modernBottomBar(),
    );
  }

  ////////////////////////////////////////////////////////////
  /// HEADER
  ////////////////////////////////////////////////////////////

  Widget _header() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          const Text(
            '12. GLOBAL SEARCH',
            style: TextStyle(
              color: Color(0xFFFFC63D),
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.8,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          )
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// SEARCH BAR (MODERN)
  ////////////////////////////////////////////////////////////

  Widget _searchBar() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF121624),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: const Color(0x22FFFFFF)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search,
                color: Colors.white54),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                style:
                    const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'drainage',
                  hintStyle:
                      TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// FILTERS
  ////////////////////////////////////////////////////////////

  Widget _filtersRow() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding:
            const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final selected =
              index == _selectedFilterIndex;
          return GestureDetector(
            onTap: () =>
                setState(() => _selectedFilterIndex =
                    index),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFFC63D)
                    : const Color(0xFF1B2233),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  color: selected
                      ? Colors.black
                      : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// MODERN BOTTOM BAR
  ////////////////////////////////////////////////////////////

  Widget _modernBottomBar() {
    return Container(
      height: 70,
      margin:
          const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF071421),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          "Modern Bottom Bar (Reuse your existing)",
          style: TextStyle(color: Colors.white38),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// SECTION TITLE
////////////////////////////////////////////////////////////

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// RESULT TILE (MATCHES SECOND DESIGN)
////////////////////////////////////////////////////////////

class _ModernResultTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final bool isUpcoming;

  const _ModernResultTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF141B2D),
            Color(0xFF111827),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF1F2A44),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                      color: Colors.white54),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: TextStyle(
              color: isUpcoming
                  ? const Color(0xFFFFC63D)
                  : Colors.white38,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// PEOPLE TILE
////////////////////////////////////////////////////////////

class _ModernPeopleTile extends StatelessWidget {
  final String name;
  final String role;

  const _ModernPeopleTile({
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF141B2D),
            Color(0xFF111827),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w600)),
                Text(role,
                    style: const TextStyle(
                        color: Colors.white54)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(10),
              border: Border.all(
                  color:
                      const Color(0xFFFFC63D)),
            ),
            child: const Icon(
              Icons.person_add_alt_1,
              size: 18,
              color: Color(0xFFFFC63D),
            ),
          )
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// HASHTAG TILE
////////////////////////////////////////////////////////////

class _ModernHashtagTile extends StatelessWidget {
  final String tag;
  final String count;

  const _ModernHashtagTile({
    required this.tag,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF141B2D),
            Color(0xFF111827),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor:
                Color(0xFF1F2A44),
            child: Icon(Icons.tag,
                color: Color(0xFFFFC63D),
                size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              tag,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.w600),
            ),
          ),
          Text(
            count,
            style: const TextStyle(
                color: Colors.white54),
          )
        ],
      ),
    );
  }
}