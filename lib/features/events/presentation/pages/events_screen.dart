import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const double _kGrid = 8;
const String _fontFamily = 'Inter';
const String _homeRoute = '/home';
const String _eventsRoute = '/events';
const String _upcomingMeetingsRoute = '/events/upcoming';
const String _trackRoute = '/track';
const String _createMenuRoute = '/create-menu';
const String _profileRoute = '/profile';

class EventModel {
  const EventModel({
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.location,
    required this.status,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isVideo,
    this.duration,
    this.isBookmarked = false,
  });

  final String title;
  final String imageUrl;
  final DateTime date;
  final String location;
  final String status;
  final int likes;
  final int comments;
  final int shares;
  final bool isVideo;
  final String? duration;
  final bool isBookmarked;
}

enum EventFilter { all, upcoming }

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  static const Color _background = Color(0xFF000000);
  static const Color _card = Color(0xFF111111);
  static const Color _surface = Color(0xFF161B22);
  static const Color _gold = Color(0xFFF5A623);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF8B949E);
  static const Color _border = Color(0xFF30363D);

  late final AnimationController _staggerController;
  EventFilter _selectedFilter = EventFilter.all;

  final List<EventModel> _events = <EventModel>[
    EventModel(
      title: 'Tree Plantation Drive',
      imageUrl:
          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1400&q=80',
      date: DateTime(2026, 8, 12, 10, 30),
      location: 'Sector 9 Public Park, New Delhi',
      status: 'upcoming',
      likes: 328,
      comments: 42,
      shares: 18,
      isVideo: true,
      duration: '00:45',
      isBookmarked: true,
    ),
    EventModel(
      title: 'Youth Empowerment Program',
      imageUrl:
          'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=1400&q=80',
      date: DateTime(2026, 4, 18, 15, 0),
      location: 'City Convention Hall, Lucknow',
      status: 'completed',
      likes: 512,
      comments: 67,
      shares: 39,
      isVideo: false,
    ),
    EventModel(
      title: 'Public Health Awareness Rally',
      imageUrl:
          'https://images.unsplash.com/photo-1576765608866-5b51046452be?auto=format&fit=crop&w=1400&q=80',
      date: DateTime(2026, 7, 7, 9, 0),
      location: 'Riverfront Ground, Ahmedabad',
      status: 'ongoing',
      likes: 274,
      comments: 31,
      shares: 22,
      isVideo: true,
      duration: '01:12',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  List<EventModel> get _filteredEvents {
    if (_selectedFilter == EventFilter.upcoming) {
      final DateTime now = DateTime.now();
      return _events.where((EventModel e) => e.date.isAfter(now)).toList();
    }
    return _events;
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

  void _handleBottomNavTap(String route) {
    if (route == _eventsRoute) {
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

    if (route == _profileRoute) {
      Navigator.of(context).pushReplacementNamed(_profileRoute);
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
            toolbarHeight: 72,
            title: Stack(
              alignment: Alignment.center,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Image(
                    image: AssetImage('assets/images/my_logo.jpg'),
                    height: 66,
                    fit: BoxFit.contain,
                  ),
                ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: _kGrid),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _kGrid * 2),
                  child: SegmentedToggle(
                    selected: _selectedFilter,
                    onChanged: (EventFilter value) {
                      if (value == EventFilter.upcoming) {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(_upcomingMeetingsRoute);
                        return;
                      }

                      setState(() {
                        _selectedFilter = value;
                        _staggerController
                          ..reset()
                          ..forward();
                      });
                    },
                  ),
                ),
                const SizedBox(height: _kGrid * 2),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: _kGrid * 2),
                  child: Text(
                    'All Events',
                    style: TextStyle(
                      color: _primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: _fontFamily,
                    ),
                  ),
                ),
                const SizedBox(height: _kGrid * 2),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: _kGrid * 2),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (BuildContext context, int index) {
                      final EventModel event = _filteredEvents[index];
                      final int beginMs = index * 150;
                      final int endMs = beginMs + 500;
                      final Duration total =
                          _staggerController.duration ??
                          const Duration(milliseconds: 850);
                      final double start = (beginMs / total.inMilliseconds)
                          .clamp(0.0, 1.0);
                      final double end = (endMs / total.inMilliseconds).clamp(
                        0.0,
                        1.0,
                      );

                      final CurvedAnimation animation = CurvedAnimation(
                        parent: _staggerController,
                        curve: Interval(start, end, curve: Curves.easeOutCubic),
                      );

                      return AnimatedBuilder(
                        animation: animation,
                        builder: (BuildContext context, Widget? child) {
                          final double t = animation.value;
                          return Opacity(
                            opacity: t,
                            child: Transform.translate(
                              offset: Offset(0, (1 - t) * 22),
                              child: child,
                            ),
                          );
                        },
                        child: EventCard(event: event),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavBar(onTap: _handleBottomNavTap),
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

  final EventFilter selected;
  final ValueChanged<EventFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SegmentButton(
              label: 'All',
              active: selected == EventFilter.all,
              onTap: () => onChanged(EventFilter.all),
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: 'Upcoming',
              active: selected == EventFilter.upcoming,
              onTap: () => onChanged(EventFilter.upcoming),
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

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final EventModel event;

  String _formatDate(DateTime dateTime) {
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
    final String meridiem = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} • ${hour.toString().padLeft(2, '0')}:$minute $meridiem';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'upcoming':
        return const Color(0xFF3B82F6);
      case 'ongoing':
        return const Color(0xFF22C55E);
      case 'completed':
        return const Color(0xFFF5A623);
      default:
        return const Color(0xFF8B949E);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'upcoming':
        return 'Upcoming';
      case 'ongoing':
        return 'Ongoing';
      case 'completed':
        return 'Completed';
      default:
        return 'Event';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = event.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: _kGrid * 2),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(_kGrid * 2),
        border: Border.all(color: const Color(0xFF30363D)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(_kGrid * 2),
              topRight: Radius.circular(_kGrid * 2),
            ),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.network(event.imageUrl, fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.78),
                        ],
                      ),
                    ),
                  ),
                  if (event.isVideo)
                    Positioned(
                      top: _kGrid,
                      right: _kGrid,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _kGrid,
                          vertical: _kGrid / 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(_kGrid),
                        ),
                        child: Text(
                          event.duration ?? '00:00',
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 12,
                            fontFamily: _fontFamily,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: _kGrid * 1.5,
                    right: _kGrid * 1.5,
                    bottom: _kGrid * 1.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 16,
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
                                _formatDate(event.date),
                                style: const TextStyle(
                                  color: Color(0xFF8B949E),
                                  fontSize: 12,
                                  fontFamily: _fontFamily,
                                ),
                                overflow: TextOverflow.ellipsis,
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
                              size: 15,
                            ),
                            const SizedBox(width: _kGrid / 2),
                            Expanded(
                              child: Text(
                                event.location,
                                style: const TextStyle(
                                  color: Color(0xFF8B949E),
                                  fontSize: 12,
                                  fontFamily: _fontFamily,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: _kGrid),
                            Container(
                              constraints: const BoxConstraints(minHeight: 24),
                              padding: const EdgeInsets.symmetric(
                                horizontal: _kGrid,
                                vertical: _kGrid / 2,
                              ),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? const Color(0xFF161B22)
                                    : _statusColor(event.status),
                                borderRadius: BorderRadius.circular(
                                  _kGrid * 1.5,
                                ),
                                border: isCompleted
                                    ? Border.all(color: const Color(0xFFF5A623))
                                    : null,
                              ),
                              child: Text(
                                _statusLabel(event.status),
                                style: TextStyle(
                                  color: isCompleted
                                      ? const Color(0xFFF5A623)
                                      : const Color(0xFFFFFFFF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: _fontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              _kGrid * 1.5,
              _kGrid * 1.25,
              _kGrid * 1.5,
              _kGrid * 1.5,
            ),
            child: Row(
              children: <Widget>[
                _CountAction(
                  icon: Icons.favorite_border_rounded,
                  count: event.likes,
                  active: false,
                ),
                const SizedBox(width: _kGrid * 2),
                _CountAction(
                  icon: Icons.mode_comment_outlined,
                  count: event.comments,
                  active: false,
                ),
                const SizedBox(width: _kGrid * 2),
                _CountAction(
                  icon: Icons.share_outlined,
                  count: event.shares,
                  active: false,
                ),
                const Spacer(),
                Icon(
                  event.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: event.isBookmarked
                      ? const Color(0xFFF5A623)
                      : const Color(0xFF8B949E),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountAction extends StatelessWidget {
  const _CountAction({
    required this.icon,
    required this.count,
    required this.active,
  });

  final IconData icon;
  final int count;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color color = active
        ? const Color(0xFFF5A623)
        : const Color(0xFF8B949E);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: color, size: 18),
        const SizedBox(width: _kGrid / 2),
        Text(
          '$count',
          style: TextStyle(color: color, fontSize: 12, fontFamily: _fontFamily),
        ),
      ],
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
                onTap: () => onTap(_homeRoute),
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
                onTap: () => onTap(_profileRoute),
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
