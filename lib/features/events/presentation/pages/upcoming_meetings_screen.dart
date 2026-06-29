import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const double _kGrid = 8;
const String _fontFamily = 'Inter';
const String _homeRoute = '/';

const String _eventsRoute = '/events';
const String _upcomingMeetingsRoute = '/events/upcoming';
const String _trackRoute = '/track';
const String _createMenuRoute = '/create-menu';

class MeetingModel {
  const MeetingModel({
    required this.title,
    required this.date,
    required this.location,
    required this.interestedCount,
    required this.isInterested,
  });

  final String title;
  final DateTime date;
  final String location;
  final int interestedCount;
  final bool isInterested;

  MeetingModel copyWith({
    String? title,
    DateTime? date,
    String? location,
    int? interestedCount,
    bool? isInterested,
  }) {
    return MeetingModel(
      title: title ?? this.title,
      date: date ?? this.date,
      location: location ?? this.location,
      interestedCount: interestedCount ?? this.interestedCount,
      isInterested: isInterested ?? this.isInterested,
    );
  }
}

enum MeetingsFilter { all, upcoming }

class UpcomingMeetingsScreen extends StatefulWidget {
  const UpcomingMeetingsScreen({super.key});

  @override
  State<UpcomingMeetingsScreen> createState() => _UpcomingMeetingsScreenState();
}

class _UpcomingMeetingsScreenState extends State<UpcomingMeetingsScreen>
    with SingleTickerProviderStateMixin {
  static const Color _background = Color(0xFF000000);
  static const Color _surfaceCard = Color(0xFF111111);
  static const Color _surfaceAlt = Color(0xFF161B22);
  static const Color _gold = Color(0xFFF5A623);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFF8B949E);
  static const Color _border = Color(0xFF30363D);
  static const Color _green = Color(0xFF22C55E);

  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _listAnimationController;

  MeetingsFilter _selectedFilter = MeetingsFilter.upcoming;
  bool _isRsvpGoing = false;

  List<MeetingModel> _meetings = <MeetingModel>[
    MeetingModel(
      title: 'Constituency Development Meeting',
      date: DateTime(2026, 5, 20, 10, 30),
      location: 'Ward Office, Sector 4',
      interestedCount: 235,
      isInterested: true,
    ),
    MeetingModel(
      title: 'Public Grievance Meeting',
      date: DateTime(2026, 6, 25, 14, 0),
      location: 'Community Hall, Central Block',
      interestedCount: 180,
      isInterested: false,
    ),
    MeetingModel(
      title: 'Youth Empowerment Discussion',
      date: DateTime(2026, 7, 3, 16, 30),
      location: 'Municipal Auditorium',
      interestedCount: 312,
      isInterested: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  List<MeetingModel> get _filteredMeetings {
    final String query = _searchController.text.trim().toLowerCase();
    final DateTime now = DateTime.now();

    Iterable<MeetingModel> result = _meetings;

    if (_selectedFilter == MeetingsFilter.upcoming) {
      result = result.where((MeetingModel m) => m.date.isAfter(now));
    }

    if (query.isNotEmpty) {
      result = result.where(
        (MeetingModel m) =>
            m.title.toLowerCase().contains(query) ||
            m.location.toLowerCase().contains(query),
      );
    }

    return result.toList();
  }

  void _onFilterChanged(MeetingsFilter filter) {
    if (filter == MeetingsFilter.all) {
      Navigator.of(context).pushReplacementNamed(_eventsRoute);
      return;
    }

    if (filter == MeetingsFilter.upcoming && _selectedFilter == filter) {
      return;
    }

    setState(() {
      _selectedFilter = filter;
      _listAnimationController
        ..reset()
        ..forward();
    });
  }

  void _toggleInterested(int indexInFiltered) {
    final List<MeetingModel> filtered = _filteredMeetings;
    if (indexInFiltered < 0 || indexInFiltered >= filtered.length) {
      return;
    }

    final MeetingModel selected = filtered[indexInFiltered];
    final int sourceIndex = _meetings.indexOf(selected);
    if (sourceIndex == -1) {
      return;
    }

    final bool nextInterested = !_meetings[sourceIndex].isInterested;
    final int nextCount = nextInterested
        ? _meetings[sourceIndex].interestedCount + 1
        : (_meetings[sourceIndex].interestedCount - 1).clamp(0, 999999999);

    setState(() {
      _meetings[sourceIndex] = _meetings[sourceIndex].copyWith(
        isInterested: nextInterested,
        interestedCount: nextCount,
      );
    });
  }

  void _onBottomNavTap(String route) {
    if (route == _eventsRoute || route == _upcomingMeetingsRoute) {
      return;
    }

    if (route == _homeRoute || route == '/home') {
      Navigator.of(context).pushReplacementNamed(_homeRoute);
      return;
    }

    if (route == _createMenuRoute) {
      Navigator.of(context).pushNamed(_createMenuRoute);
      return;
    }

    if (route == _trackRoute) {
      Navigator.of(context).pushReplacementNamed(_trackRoute);
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
  }

  String _formatDateTime(DateTime dateTime) {
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

    final int hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} • ${hour.toString().padLeft(2, '0')}:$minute $amPm';
  }

  void _showNotificationSnackbar() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Notifications enabled'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final List<MeetingModel> meetings = _filteredMeetings;

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
          backgroundColor: _background,
          appBar: AppBar(
            backgroundColor: _background,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            toolbarHeight: 72,
            title: Stack(
              alignment: Alignment.center,
              children: [
                const Align(alignment: Alignment.center, child: _LeaderLogo()),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(width: 40),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Material(
                    color: const Color(0xff17191C),
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: _showNotificationSnackbar,
                      splashRadius: 22,
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        size: 22,
                        color: Color(0xffFFFFFF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                _kGrid * 2,
                _kGrid,
                _kGrid * 2,
                _kGrid * 2,
              ),
              children: <Widget>[
                SearchBarWidget(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: _kGrid * 1.5),
                SegmentedToggle(
                  selected: _selectedFilter,
                  onChanged: _onFilterChanged,
                ),
                const SizedBox(height: _kGrid * 2),
                const Text(
                  'Featured Meeting',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: _fontFamily,
                  ),
                ),
                const SizedBox(height: _kGrid),
                FeaturedMeetingCard(
                  isGoing: _isRsvpGoing,
                  onRsvpTap: () {
                    setState(() {
                      _isRsvpGoing = !_isRsvpGoing;
                    });
                  },
                  formattedDate: _formatDateTime(DateTime(2026, 7, 12, 11, 0)),
                ),
                const SizedBox(height: _kGrid * 2),
                const Text(
                  'Upcoming Meetings',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: _fontFamily,
                  ),
                ),
                const SizedBox(height: _kGrid * 1.5),
                ...List<Widget>.generate(meetings.length, (int index) {
                  final MeetingModel meeting = meetings[index];
                  final int beginMs = index * 150;
                  final int endMs = beginMs + 500;
                  final Duration total =
                      _listAnimationController.duration ??
                      const Duration(milliseconds: 900);
                  final double start = (beginMs / total.inMilliseconds).clamp(
                    0.0,
                    1.0,
                  );
                  final double end = (endMs / total.inMilliseconds).clamp(
                    0.0,
                    1.0,
                  );

                  final CurvedAnimation animation = CurvedAnimation(
                    parent: _listAnimationController,
                    curve: Interval(start, end, curve: Curves.easeOutCubic),
                  );

                  return AnimatedBuilder(
                    animation: animation,
                    builder: (BuildContext context, Widget? child) {
                      final double value = animation.value;
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 18),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: index == meetings.length - 1 ? 0 : _kGrid * 2,
                      ),
                      child: MeetingListItem(
                        meeting: meeting,
                        onInterestedTap: () => _toggleInterested(index),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavBar(onTap: _onBottomNavTap),
        ),
      ),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 14,
          fontFamily: _fontFamily,
        ),
        decoration: InputDecoration(
          hintText: 'Search meetings, events, keywords...',
          hintStyle: const TextStyle(
            color: Color(0xFF8B949E),
            fontSize: 14,
            fontFamily: _fontFamily,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF8B949E),
            size: 20,
          ),
          filled: true,
          fillColor: const Color(0xFF161B22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: _kGrid,
            vertical: _kGrid,
          ),
        ),
      ),
    );
  }
}

class SegmentedToggle extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final MeetingsFilter selected;
  final ValueChanged<MeetingsFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SegmentButton(
              label: 'All',
              active: selected == MeetingsFilter.all,
              onTap: () => onChanged(MeetingsFilter.all),
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: 'Upcoming',
              active: selected == MeetingsFilter.upcoming,
              onTap: () => onChanged(MeetingsFilter.upcoming),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      height: _kGrid * 5.5,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFF5A623) : Colors.transparent,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active
                    ? const Color(0xFF000000)
                    : const Color(0xFF8B949E),
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
                fontFamily: _fontFamily,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FeaturedMeetingCard extends StatelessWidget {
  const FeaturedMeetingCard({
    super.key,
    required this.isGoing,
    required this.onRsvpTap,
    required this.formattedDate,
  });

  final bool isGoing;
  final VoidCallback onRsvpTap;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.network(
              'https://images.unsplash.com/photo-1529107386315-e1a2ed48a620?auto=format&fit=crop&w=1600&q=80',
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
            Positioned(
              left: _kGrid * 2,
              right: _kGrid * 2,
              bottom: _kGrid * 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Public Grievance Camp',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  const SizedBox(height: _kGrid),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF8B949E),
                        size: 15,
                      ),
                      const SizedBox(width: _kGrid / 2),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 12,
                            fontFamily: _fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: _kGrid / 2),
                  const Row(
                    children: <Widget>[
                      Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF8B949E),
                        size: 15,
                      ),
                      SizedBox(width: _kGrid / 2),
                      Expanded(
                        child: Text(
                          'District Coordination Hall',
                          style: TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 12,
                            fontFamily: _fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: _kGrid),
                  const Text(
                    '250 Going • 15 Interested',
                    style: TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 12,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  const SizedBox(height: _kGrid),
                  _RsvpButton(isGoing: isGoing, onTap: onRsvpTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RsvpButton extends StatefulWidget {
  const _RsvpButton({required this.isGoing, required this.onTap});

  final bool isGoing;
  final VoidCallback onTap;

  @override
  State<_RsvpButton> createState() => _RsvpButtonState();
}

class _RsvpButtonState extends State<_RsvpButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final Matrix4 transform = _pressed
        ? (Matrix4.identity()..scale(0.97))
        : Matrix4.identity();

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: transform,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: _kGrid * 2),
        decoration: BoxDecoration(
          color: widget.isGoing
              ? const Color(0xFF22C55E)
              : const Color(0xFFF5A623),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            widget.isGoing ? 'Going' : 'RSVP Now',
            style: const TextStyle(
              color: Color(0xFF000000),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: _fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}

class MeetingListItem extends StatelessWidget {
  const MeetingListItem({
    super.key,
    required this.meeting,
    required this.onInterestedTap,
  });

  final MeetingModel meeting;
  final VoidCallback onInterestedTap;

  String _formatDateTime(DateTime dateTime) {
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

    final int hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} • ${hour.toString().padLeft(2, '0')}:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DateBlockWidget(date: meeting.date),
        const SizedBox(width: _kGrid * 1.5),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        meeting.title,
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: _fontFamily,
                        ),
                      ),
                    ),
                    const SizedBox(width: _kGrid),
                    _InterestedBadge(
                      isInterested: meeting.isInterested,
                      onTap: onInterestedTap,
                    ),
                  ],
                ),
                const SizedBox(height: _kGrid),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF8B949E),
                      size: 14,
                    ),
                    const SizedBox(width: _kGrid / 2),
                    Expanded(
                      child: Text(
                        _formatDateTime(meeting.date),
                        style: const TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 12,
                          fontFamily: _fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: _kGrid / 2),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF8B949E),
                      size: 14,
                    ),
                    const SizedBox(width: _kGrid / 2),
                    Expanded(
                      child: Text(
                        meeting.location,
                        style: const TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 12,
                          fontFamily: _fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: _kGrid),
                Text(
                  '${meeting.interestedCount} Interested',
                  style: const TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 12,
                    fontFamily: _fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DateBlockWidget extends StatelessWidget {
  const DateBlockWidget({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    const List<String> months = <String>[
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: _kGrid * 1.5),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          Text(
            date.day.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: _fontFamily,
            ),
          ),
          const SizedBox(height: _kGrid / 2),
          Text(
            months[date.month - 1],
            style: const TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 12,
              fontFamily: _fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestedBadge extends StatelessWidget {
  const _InterestedBadge({required this.isInterested, required this.onTap});

  final bool isInterested;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 28),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isInterested
              ? const Color(0xFF22C55E)
              : const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(12),
          border: isInterested
              ? null
              : Border.all(color: const Color(0xFF30363D), width: 1),
        ),
        child: Text(
          isInterested ? 'Interested' : 'Mark Interested',
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: _fontFamily,
          ),
        ),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1117),
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
                active: false,
                onTap: () => onTap('/home'),
              ),
              _NavItem(
                icon: Icons.track_changes_rounded,
                label: 'Issues',
                active: false,
                onTap: () => onTap(_trackRoute),
              ),
              _AddButton(onTap: () => onTap(_createMenuRoute)),
              _NavItem(
                icon: Icons.event_outlined,
                label: 'Events',
                active: true,
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
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final Matrix4 transform = _pressed
        ? (Matrix4.identity()..scale(0.94))
        : Matrix4.identity();

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: transform,
        width: _kGrid * 6,
        height: _kGrid * 6,
        decoration: const BoxDecoration(
          color: Color(0xFFF5A623),
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Color(0xFF000000), size: 24),
      ),
    );
  }
}

class _LeaderLogo extends StatelessWidget {
  const _LeaderLogo();

  @override
  Widget build(BuildContext context) {
    return const Image(
      image: AssetImage('assets/images/my_logo.jpg'),
      height: 66,
      fit: BoxFit.contain,
    );
  }
}
