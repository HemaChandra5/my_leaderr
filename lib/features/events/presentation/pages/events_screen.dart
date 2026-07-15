import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';

const double _kGrid = 8;
const String _fontFamily = 'Inter';
const String _homeRoute = '/home';
const String _communityRoute = '/community';
const String _eventsRoute = '/events';
const String _upcomingMeetingsRoute = '/events/upcoming';
const String _trackRoute = '/track';
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
  final TextEditingController _searchController = TextEditingController();
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
    _searchController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  List<EventModel> get _filteredEvents {
    final query = _searchController.text.trim().toLowerCase();
    if (_selectedFilter == EventFilter.upcoming) {
      final DateTime now = DateTime.now();
      return _events
          .where((EventModel e) {
            if (!e.date.isAfter(now)) {
              return false;
            }
            if (query.isEmpty) {
              return true;
            }
            return e.title.toLowerCase().contains(query) ||
                e.location.toLowerCase().contains(query) ||
                e.status.toLowerCase().contains(query);
          })
          .toList(growable: false);
    }
    if (query.isEmpty) {
      return _events;
    }
    return _events
        .where((EventModel e) {
          return e.title.toLowerCase().contains(query) ||
              e.location.toLowerCase().contains(query) ||
              e.status.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  String get _language => AppLanguage.instance.language;
  String _tr(String key) =>
      AppLocalizations.translate(key, language: _language);

  void _showNotificationSnackbar() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(_tr('notifications_enabled')),
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

    if (route == _communityRoute) {
      Navigator.of(context).pushReplacementNamed(_communityRoute);
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
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(_tr('coming_soon')),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLanguage.instance,
      builder: (context, _) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final Color background = Theme.of(context).scaffoldBackgroundColor;
        final Color surfaceAlt = isDark
            ? const Color(0xFF161B22)
            : const Color(0xFFEFF3F8);
        final Color primaryText = isDark
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF0F172A);
        final Color secondaryText = isDark
            ? const Color(0xFF8B949E)
            : const Color(0xFF64748B);
        final Color border = isDark
            ? const Color(0xFF30363D)
            : const Color(0xFFD7DEE8);
        final Color iconChip = isDark
            ? const Color(0xFF17191C)
            : const Color(0xFFE7ECF3);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: background,
            appBar: AppBar(
              backgroundColor: background,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              centerTitle: true,
              toolbarHeight: 80,
              title: const Image(
                image: AssetImage('assets/images/logo.png'),
                height: 74,
                fit: BoxFit.contain,
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: iconChip,
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: _showNotificationSnackbar,
                      splashRadius: 22,
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        size: 22,
                        color: primaryText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: _kGrid),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _kGrid * 2),
                    child: SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 14,
                          fontFamily: _fontFamily,
                        ),
                        decoration: InputDecoration(
                          hintText: _tr('search_meetings'),
                          hintStyle: TextStyle(
                            color: secondaryText,
                            fontSize: 14,
                            fontFamily: _fontFamily,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: secondaryText,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: surfaceAlt,
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
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: _kGrid * 1.5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _kGrid * 2),
                    child: SegmentedToggle(
                      selected: _selectedFilter,
                      background: surfaceAlt,
                      borderColor: border,
                      inactiveTextColor: secondaryText,
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: _kGrid * 2),
                    child: Text(
                      _tr('all_events'),
                      style: TextStyle(
                        color: primaryText,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: _kGrid * 2,
                      ),
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
                          curve: Interval(
                            start,
                            end,
                            curve: Curves.easeOutCubic,
                          ),
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
                          child: EventCard(
                            key: ValueKey<String>(
                              '${event.title}_${event.date.toIso8601String()}',
                            ),
                            event: event,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavBar(
              onTap: _handleBottomNavTap,
              language: _language,
            ),
          ),
        );
      },
    );
  }
}

class SegmentedToggle extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.background,
    required this.borderColor,
    required this.inactiveTextColor,
  });

  final EventFilter selected;
  final ValueChanged<EventFilter> onChanged;
  final Color background;
  final Color borderColor;
  final Color inactiveTextColor;

  @override
  Widget build(BuildContext context) {
    final language = AppLanguage.instance.language;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SegmentButton(
              label: AppLocalizations.translate('all', language: language),
              active: selected == EventFilter.all,
              inactiveTextColor: inactiveTextColor,
              onTap: () => onChanged(EventFilter.all),
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: AppLocalizations.translate('upcoming', language: language),
              active: selected == EventFilter.upcoming,
              inactiveTextColor: inactiveTextColor,
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
    required this.inactiveTextColor,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color inactiveTextColor;
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
                color: active ? const Color(0xFF000000) : inactiveTextColor,
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

class EventCard extends StatefulWidget {
  const EventCard({super.key, required this.event});

  final EventModel event;

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late int _likeCount;
  late int _commentCount;
  late int _shareCount;

  late bool _liked;
  bool _commented = false;
  bool _shared = false;
  late bool _bookmarked;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.event.likes;
    _commentCount = widget.event.comments;
    _shareCount = widget.event.shares;
    _liked = false;
    _bookmarked = widget.event.isBookmarked;
  }

  int _nextCount(int current, bool active) {
    return active ? current + 1 : (current > 0 ? current - 1 : 0);
  }

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
    final language = AppLanguage.instance.language;
    switch (status) {
      case 'upcoming':
        return AppLocalizations.translate('upcoming', language: language);
      case 'ongoing':
        return AppLocalizations.translate('ongoing', language: language);
      case 'completed':
        return AppLocalizations.translate('completed', language: language);
      default:
        return AppLocalizations.translate('events', language: language);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = Theme.of(context).colorScheme.surface;
    final Color borderColor = isDark
        ? const Color(0x66F5A623)
        : const Color(0x99D6A848);
    final Color inactiveText = isDark
        ? const Color(0xFF8B949E)
        : const Color(0xFF64748B);
    final bool isCompleted = widget.event.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: _kGrid * 2),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(_kGrid * 2),
        border: Border.all(color: borderColor),
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
                  Image.network(widget.event.imageUrl, fit: BoxFit.cover),
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
                  if (widget.event.isVideo)
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
                          widget.event.duration ?? '00:00',
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
                          widget.event.title,
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
                                _formatDate(widget.event.date),
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
                                widget.event.location,
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
                                    : _statusColor(widget.event.status),
                                borderRadius: BorderRadius.circular(
                                  _kGrid * 1.5,
                                ),
                                border: isCompleted
                                    ? Border.all(color: const Color(0xFFF5A623))
                                    : null,
                              ),
                              child: Text(
                                _statusLabel(widget.event.status),
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
                  activeIcon: Icons.favorite_rounded,
                  count: _likeCount,
                  active: _liked,
                  onTap: () {
                    setState(() {
                      _liked = !_liked;
                      _likeCount = _nextCount(_likeCount, _liked);
                    });
                  },
                ),
                const SizedBox(width: _kGrid * 2),
                _CountAction(
                  icon: Icons.mode_comment_outlined,
                  activeIcon: Icons.mode_comment_rounded,
                  count: _commentCount,
                  active: _commented,
                  onTap: () {
                    setState(() {
                      _commented = !_commented;
                      _commentCount = _nextCount(_commentCount, _commented);
                    });
                  },
                ),
                const SizedBox(width: _kGrid * 2),
                _CountAction(
                  icon: Icons.reply_outlined,
                  activeIcon: Icons.reply_rounded,
                  count: _shareCount,
                  active: _shared,
                  onTap: () {
                    setState(() {
                      _shared = !_shared;
                      _shareCount = _nextCount(_shareCount, _shared);
                    });
                  },
                ),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    setState(() {
                      _bookmarked = !_bookmarked;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      _bookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: _bookmarked
                          ? const Color(0xFFF5A623)
                          : inactiveText,
                    ),
                  ),
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
    required this.activeIcon,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color inactive = isDark
        ? const Color(0xFF8B949E)
        : const Color(0xFF64748B);
    final Color color = active ? const Color(0xFFF5A623) : inactive;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(active ? activeIcon : icon, color: color, size: 18),
            const SizedBox(width: _kGrid / 2),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontFamily: _fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.onTap, required this.language});

  final ValueChanged<String> onTap;
  final String language;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color navBackground = isDark ? const Color(0xFF0D1117) : Colors.white;
    return Container(
      color: navBackground,
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
              Expanded(
                child: _NavItem(
                  icon: Icons.home_outlined,
                  label: AppLocalizations.translate('home', language: language),
                  active: false,
                  onTap: () => onTap(_homeRoute),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.track_changes_rounded,
                  label: AppLocalizations.translate(
                    'issues',
                    language: language,
                  ),
                  active: false,
                  onTap: () => onTap(_trackRoute),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.groups_2_outlined,
                  label: AppLocalizations.translate(
                    'community',
                    language: language,
                  ),
                  active: false,
                  onTap: () => onTap(_communityRoute),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.event_outlined,
                  label: AppLocalizations.translate(
                    'events',
                    language: language,
                  ),
                  active: true,
                  onTap: () => onTap(_eventsRoute),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: AppLocalizations.translate(
                    'profile',
                    language: language,
                  ),
                  active: false,
                  onTap: () => onTap(_profileRoute),
                ),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color inactive = isDark
        ? const Color(0xFF8B949E)
        : const Color(0xFF64748B);
    final Color color = active ? const Color(0xFFF5A623) : inactive;

    return InkResponse(
      onTap: onTap,
      radius: _kGrid * 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: 22),
          const SizedBox(height: _kGrid / 2),
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              fontFamily: _fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
