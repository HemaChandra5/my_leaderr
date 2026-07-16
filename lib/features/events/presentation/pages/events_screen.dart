import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../search/presentation/pages/search_explorer_screen.dart';

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
          backgroundColor: const Color(0xff121212),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xfff5a623),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                _tr('notifications_enabled'),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
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
            ? const Color(0xFF121212)
            : const Color(0xFFEFF3F8);
        final Color primaryText = isDark
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF0F172A);
        final Color secondaryText = isDark
            ? const Color(0xFF8B949E)
            : const Color(0xFF64748B);
        final Color border = isDark
            ? const Color(0xFF222427)
            : const Color(0xFFD7DEE8);
        final Color iconChip = isDark
            ? const Color(0xFF1a1a1a)
            : const Color(0xFFE7ECF3);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: background,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // ── Premium App Bar ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Container(
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Row(
                          children: [
                            Hero(
                              tag: 'app_logo_events',
                              child: Image(
                                image: const AssetImage(
                                  'assets/images/logo_transparent.png',
                                ),
                                height: 52,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox(),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: iconChip,
                              ),
                              child: IconButton(
                                onPressed: _showNotificationSnackbar,
                                splashRadius: 20,
                                icon: Icon(
                                  Icons.notifications_none_rounded,
                                  size: 20,
                                  color: primaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Search bar ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xfff5a623,
                            ).withValues(alpha: isDark ? 0.15 : 0.4),
                            width: 1,
                          ),
                        ),
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

                    // ── Segmented Toggle Filter ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    const SizedBox(height: 18),

                    // ── Title Section ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _tr('all_events'),
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: _fontFamily,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── List of Events ──
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
                          final double end = (endMs / total.inMilliseconds)
                              .clamp(0.0, 1.0);

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeText = isDark
        ? const Color(0xff000000)
        : const Color(0xffffffff);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: _kGrid * 5.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: active
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xfff5a623), Color(0xffd4831a)],
              )
            : null,
        color: active ? null : Colors.transparent,
        boxShadow: active
            ? [
                BoxShadow(
                  color: const Color(
                    0xfff5a623,
                  ).withValues(alpha: isDark ? 0.3 : 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? activeText : inactiveTextColor,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13.5,
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
    final Color cardBg = isDark
        ? const Color(0xff121212)
        : const Color(0xffffffff);
    final Color borderColor = isDark
        ? const Color(0x18f5a623)
        : const Color(0xFFe2e8f0);
    final Color inactiveText = isDark
        ? const Color(0xFF8B949E)
        : const Color(0xFF64748B);
    final bool isCompleted = widget.event.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: _kGrid * 2.5),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Image and overlays
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(19),
              topRight: Radius.circular(19),
            ),
            child: SizedBox(
              height: 190,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.network(widget.event.imageUrl, fit: BoxFit.cover),
                  // Dark bottom gradient overlay
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

                  // Video duration indicator if video
                  if (widget.event.isVideo)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_circle_fill_rounded,
                              color: Color(0xfff5a623),
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.event.duration ?? '00:00',
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                fontFamily: _fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Status Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF161B22)
                            : _statusColor(widget.event.status),
                        borderRadius: BorderRadius.circular(20),
                        border: isCompleted
                            ? Border.all(color: const Color(0xFFF5A623))
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: _statusColor(
                              widget.event.status,
                            ).withValues(alpha: isCompleted ? 0 : 0.35),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        _statusLabel(widget.event.status),
                        style: TextStyle(
                          color: isCompleted
                              ? const Color(0xFFF5A623)
                              : const Color(0xFFFFFFFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: _fontFamily,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),

                  // Bottom title & subtitle details
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.event.title,
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            fontFamily: _fontFamily,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Color(0xfff5a623),
                              size: 13,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _formatDate(widget.event.date),
                                style: const TextStyle(
                                  color: Color(0xffe6edf3),
                                  fontSize: 12,
                                  fontFamily: _fontFamily,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xfff5a623),
                              size: 13,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.event.location,
                                style: const TextStyle(
                                  color: Color(0xffe6edf3),
                                  fontSize: 12,
                                  fontFamily: _fontFamily,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
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

          // Action Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: <Widget>[
                _CountAction(
                  icon: Icons.thumb_up_alt_outlined,
                  activeIcon: Icons.thumb_up_alt_rounded,
                  count: _likeCount,
                  active: _liked,
                  onTap: () {
                    setState(() {
                      _liked = !_liked;
                      _likeCount = _nextCount(_likeCount, _liked);
                    });
                  },
                ),
                const SizedBox(width: 16),
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
                const SizedBox(width: 16),
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
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      _bookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: _bookmarked
                          ? const Color(0xFFF5A623)
                          : inactiveText,
                      size: 20,
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
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(active ? activeIcon : icon, color: color, size: 19),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
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
    final Color navBg = isDark
        ? const Color(0xff0d1117)
        : const Color(0xffffffff);
    final Color borderColor = isDark
        ? const Color(0x2bf5a623)
        : const Color(0xffe2e8f0);

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
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
                  icon: Icons.groups_2_rounded,
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
                  icon: Icons.event_note_rounded,
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
                  icon: Icons.person_rounded,
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
    final Color activeColor = const Color(0xfff5a623);
    final Color inactiveColor = isDark
        ? const Color(0xff8b949e)
        : const Color(0xff64748b);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: activeColor.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: active
                    ? activeColor.withValues(alpha: isDark ? 0.13 : 0.1)
                    : Colors.transparent,
              ),
              child: Icon(
                icon,
                color: active ? activeColor : inactiveColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: active ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                fontFamily: _fontFamily,
                letterSpacing: active ? 0.2 : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
