import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../community/state/community_hub_controller.dart';
import '../../../main.dart';
import '../../messaging/models/public_user_profile.dart';
import '../../../providers/user_provider.dart';
import '../../home/presentation/widgets/bottom_navigation.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../widgets/event_card.dart';
import '../widgets/event_category_selector.dart';
import '../widgets/event_shimmer.dart';
import '../widgets/featured_event_card.dart';
import 'add_event_screen.dart';
import 'event_details_screen.dart';

const String _homeRoute = '/home';
const String _communityRoute = '/community';
const String _eventsRoute = '/events';
const String _trackRoute = '/track';
const String _profileRoute = '/profile';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _eventService = const EventService();
  final PageController _upcomingPageController = PageController(
    viewportFraction: 0.94,
  );
  bool _notifPressed = false;

  List<EventModel> _allEvents = <EventModel>[];
  final Set<String> _bookmarkedEventIds = <String>{};
  final Set<String> _registeredEventIds = <String>{};
  EventCategory _selectedCategory = EventCategory.local;
  int _upcomingPageIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _upcomingPageController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    final List<EventModel> events = await _eventService.fetchEvents();
    if (!mounted) {
      return;
    }

    setState(() {
      _allEvents = events;
      _isLoading = false;
    });
  }

  List<EventModel> get _categoryEvents {
    final List<EventModel> allVisible = <EventModel>[
      ...context.read<CommunityHubController>().createdEvents,
      ..._allEvents,
    ];

    return allVisible
        .where((EventModel event) => event.category == _selectedCategory)
        .map(
          (EventModel event) => event.copyWith(
            isBookmarked: _bookmarkedEventIds.contains(event.id),
          ),
        )
        .toList(growable: false);
  }

  List<EventModel> get _upcomingEvents {
    final DateTime now = DateTime.now();
    final List<EventModel> upcoming =
        _categoryEvents
            .where((EventModel event) {
              if (event.status == EventStatus.completed) {
                return false;
              }
              return event.date.isAfter(now) ||
                  event.status == EventStatus.live;
            })
            .toList(growable: false)
          ..sort((EventModel a, EventModel b) => a.date.compareTo(b.date));

    return upcoming;
  }

  void _onBottomNavSelected(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(_homeRoute);
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(_trackRoute);
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed(_communityRoute);
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed(_eventsRoute);
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed(_profileRoute);
        break;
    }
  }

  Future<void> _openAddEvent() async {
    final EventModel? createdEvent = await Navigator.of(context)
        .push<EventModel>(
          MaterialPageRoute<EventModel>(builder: (_) => const AddEventScreen()),
        );

    if (!mounted || createdEvent == null) {
      return;
    }

    setState(() {
      _allEvents = <EventModel>[
        createdEvent,
        ..._allEvents.where((EventModel item) => item.id != createdEvent.id),
      ];
      _selectedCategory = createdEvent.category;
      _upcomingPageIndex = 0;
    });
  }

  void _openOrganizerProfile(String organizerName) {
    final String userId =
        'user_${organizerName.toLowerCase().replaceAll(' ', '_')}';
    debugPrint('Opening profile for user: $userId');
    Navigator.of(context).pushNamed(
      AppRoutes.publicProfile,
      arguments: PublicProfileRouteArgs(
        userId: userId,
        displayName: organizerName,
      ),
    );
  }

  Widget _buildTopBar() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        height: 80,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Row(
          children: <Widget>[
            Hero(
              tag: 'app_logo_events',
              child: Image.asset(
                'assets/images/logo_transparent.png',
                height: 74,
                fit: BoxFit.contain,
                errorBuilder: (BuildContext context, Object _, StackTrace? _) {
                  return const SizedBox();
                },
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTapDown: (_) => setState(() => _notifPressed = true),
              onTapUp: (_) => setState(() => _notifPressed = false),
              onTapCancel: () => setState(() => _notifPressed = false),
              onTap: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Notifications are up to date'),
                    ),
                  );
              },
              child: AnimatedScale(
                scale: _notifPressed ? 0.88 : 1,
                duration: const Duration(milliseconds: 120),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFFFFFFF),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.08,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.notifications_none_rounded,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        size: 21,
                      ),
                      Positioned(
                        right: 9,
                        top: 9,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBlock() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Events',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 29,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Discover leadership events around you.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildUpcomingSection(List<EventModel> upcomingEvents) {
    if (upcomingEvents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.event_busy_rounded, color: AppColors.primaryGold),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No upcoming events in ${_selectedCategory.label} right now.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        SizedBox(
          height: 288,
          child: PageView.builder(
            controller: _upcomingPageController,
            itemCount: upcomingEvents.length,
            onPageChanged: (int index) {
              setState(() => _upcomingPageIndex = index);
            },
            itemBuilder: (BuildContext context, int index) {
              final EventModel event = upcomingEvents[index];
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: index == upcomingEvents.length - 1 ? 16 : 8,
                ),
                child: FeaturedEventCard(
                  event: event,
                  onOrganizerTap: () => _openOrganizerProfile(event.organizer),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => EventDetailsScreen(event: event),
                      ),
                    );
                  },
                  onRegister: () {
                    setState(() => _registeredEventIds.add(event.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Registered for ${event.title}')),
                    );
                  },
                  onBookmark: () {
                    setState(() {
                      if (_bookmarkedEventIds.contains(event.id)) {
                        _bookmarkedEventIds.remove(event.id);
                      } else {
                        _bookmarkedEventIds.add(event.id);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(upcomingEvents.length, (int index) {
            final bool active = _upcomingPageIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? AppColors.primaryGold : AppColors.divider,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_busy_rounded,
                  color: AppColors.primaryGold,
                  size: 54,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Events Found',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for upcoming events.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsContent() {
    final List<EventModel> events = _categoryEvents;
    final List<EventModel> upcomingEvents = _upcomingEvents;

    return CustomScrollView(
      key: ValueKey<String>('events_${_selectedCategory.name}'),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: <Widget>[
        SliverToBoxAdapter(child: _buildTopBar()),
        SliverToBoxAdapter(child: _buildTitleBlock()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: EventCategorySelector(
              selected: _selectedCategory,
              onChanged: (EventCategory category) {
                setState(() {
                  _selectedCategory = category;
                  _upcomingPageIndex = 0;
                });
                if (_upcomingPageController.hasClients) {
                  _upcomingPageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                  );
                }
              },
            ),
          ),
        ),
        SliverToBoxAdapter(child: _sectionTitle('Upcoming Events')),
        SliverToBoxAdapter(child: _buildUpcomingSection(upcomingEvents)),
        SliverToBoxAdapter(child: _sectionTitle('All Events')),
        if (events.isEmpty)
          _buildEmptyState()
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.builder(
              itemCount: events.length,
              itemBuilder: (BuildContext context, int index) {
                final EventModel event = events[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: EventCard(
                    event: event,
                    index: index,
                    onOrganizerTap: () =>
                        _openOrganizerProfile(event.organizer),
                    onViewDetails: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EventDetailsScreen(event: event),
                        ),
                      );
                    },
                    onShare: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Share link copied for ${event.title}'),
                        ),
                      );
                    },
                    onBookmark: () {
                      setState(() {
                        if (_bookmarkedEventIds.contains(event.id)) {
                          _bookmarkedEventIds.remove(event.id);
                        } else {
                          _bookmarkedEventIds.add(event.id);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin =
        context.watch<UserProvider>().appUser?.isVerifiedLeader ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primaryGold,
        onRefresh: _loadEvents,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _isLoading
              ? const EventShimmerList(key: ValueKey<String>('loading'))
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _buildEventsContent(),
                ),
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _openAddEvent,
              backgroundColor: AppColors.primaryGold,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: BottomNavigation(
        currentIndex: 3,
        onItemSelected: _onBottomNavSelected,
      ),
    );
  }
}
