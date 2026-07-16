import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../main.dart';
import '../../../messaging/models/public_user_profile.dart';

const double _kGrid = 8;
const String _homeRoute = '/home';
const String _communityRoute = '/community';
const String _eventsRoute = '/events';
const String _trackRoute = '/track';
const String _profileRoute = '/profile';

// ─── Data ─────────────────────────────────────────────────────────────────────
class IssueUpdate {
  const IssueUpdate({
    required this.name,
    required this.designation,
    required this.status,
    required this.message,
    required this.imageUrl,
    required this.timestamp,
  });

  final String name;
  final String designation;
  final String status;
  final String message;
  final String imageUrl;
  final DateTime timestamp;
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class TrackIssueScreen extends StatefulWidget {
  const TrackIssueScreen({super.key});

  @override
  State<TrackIssueScreen> createState() => _TrackIssueScreenState();
}

class _TrackIssueScreenState extends State<TrackIssueScreen>
    with SingleTickerProviderStateMixin {
  static const Color _gold = Color(0xFFF5A623);
  static const Color _navy = Color(0xFF0D1B3E);

  static const Duration _itemStagger = Duration(milliseconds: 150);
  static const Duration _entryDuration = Duration(milliseconds: 700);
  final TextEditingController _searchController = TextEditingController();

  final List<IssueUpdate> _updates = [
    IssueUpdate(
      name: 'Ravi Kumar',
      designation: 'Field Supervisor',
      status: 'started',
      message:
          'The civic issue has been acknowledged and on-ground work started with the local maintenance team.',
      imageUrl:
          'https://images.unsplash.com/photo-1521295121783-8a321d551ad2?auto=format&fit=crop&w=1400&q=80',
      timestamp: DateTime(2024, 5, 21, 9, 30),
    ),
    IssueUpdate(
      name: 'Priya Sharma',
      designation: 'Project Engineer',
      status: 'in_progress',
      message:
          'Drainage alignment was corrected and resurfacing is underway. Team expects completion by evening.',
      imageUrl:
          'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?auto=format&fit=crop&w=1400&q=80',
      timestamp: DateTime(2024, 5, 21, 11, 15),
    ),
    IssueUpdate(
      name: 'Amit Verma',
      designation: 'Ward Officer',
      status: 'completed',
      message:
          'Final inspection passed and the issue is fully resolved. Area has been cleaned and reopened for use.',
      imageUrl:
          'https://images.unsplash.com/photo-1504307651254-35680f356dfd?auto=format&fit=crop&w=1400&q=80',
      timestamp: DateTime(2024, 5, 21, 16, 5),
    ),
  ];

  late final AnimationController _controller;

  String get _language => AppLanguage.instance.language;
  String _tr(String key) =>
      AppLocalizations.translate(key, language: _language);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _entryDuration)
      ..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  List<IssueUpdate> get _filteredUpdates {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _updates;
    return _updates
        .where(
          (u) =>
              u.name.toLowerCase().contains(query) ||
              u.designation.toLowerCase().contains(query) ||
              u.message.toLowerCase().contains(query) ||
              u.status.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  void _showNotificationSnackbar() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1C1C1C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: _gold,
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
    if (route == _trackRoute) return;
    if (route == _homeRoute) {
      Navigator.of(context).pushReplacementNamed(_homeRoute);
      return;
    }
    if (route == _communityRoute) {
      Navigator.of(context).pushReplacementNamed(_communityRoute);
      return;
    }
    if (route == _eventsRoute) {
      Navigator.of(context).pushReplacementNamed(_eventsRoute);
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

  void _openPublicProfile(String name) {
    final String userId = 'user_${name.toLowerCase().replaceAll(' ', '_')}';
    Navigator.of(context).pushNamed(
      AppRoutes.publicProfile,
      arguments: PublicProfileRouteArgs(userId: userId, displayName: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLanguage.instance,
      builder: (context, _) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final Color background = Theme.of(context).scaffoldBackgroundColor;
        final Color primaryText = isDark
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF0F172A);
        final Color secondaryText = isDark
            ? const Color(0xFF8B949E)
            : const Color(0xFF64748B);
        final Color fieldBg = isDark
            ? const Color(0xFF161B22)
            : const Color(0xFFEFF3F8);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: background,
            body: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF0A0A0A), Color(0xFF000000)],
                      )
                    : null,
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Premium Header ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Row(
                        children: [
                          const _LeaderLogo(),
                          const Spacer(),
                          _NotifIconBtn(
                            onTap: _showNotificationSnackbar,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Issue Title card ────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: isDark
                              ? const Color(0xFF141414)
                              : Colors.white,
                          border: Border.all(
                            color: _gold.withValues(alpha: 0.22),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withValues(alpha: 0.06),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFF5A623),
                                    Color(0xFFD4831A),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _tr('live_updates').toUpperCase(),
                                    style: const TextStyle(
                                      color: _gold,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2.0,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Real-time civic issue tracking',
                                    style: TextStyle(
                                      color: secondaryText.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 11,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Status summary
                            _StatusSummaryBadge(updates: _filteredUpdates),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Search Bar ─────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: fieldBg,
                          border: Border.all(
                            color: _gold.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: TextStyle(color: primaryText, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: _tr('search_meetings'),
                            hintStyle: TextStyle(
                              color: secondaryText,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: _gold.withValues(alpha: 0.7),
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

                    const SizedBox(height: 16),

                    // ── Timeline ───────────────────────────────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TimelineWidget(
                          updates: _filteredUpdates,
                          controller: _controller,
                          stagger: _itemStagger,
                          onUserTap: _openPublicProfile,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _kGrid * 2,
                      _kGrid,
                      _kGrid * 2,
                      _kGrid,
                    ),
                    child: _NotifyButton(
                      onTap: _showNotificationSnackbar,
                      gold: _gold,
                      navy: _navy,
                      language: _language,
                    ),
                  ),
                ),
                BottomNavBar(onTap: _handleBottomNavTap, language: _language),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Status Summary Badge ──────────────────────────────────────────────────────
class _StatusSummaryBadge extends StatelessWidget {
  const _StatusSummaryBadge({required this.updates});
  final List<IssueUpdate> updates;

  @override
  Widget build(BuildContext context) {
    final completed = updates.where((u) => u.status == 'completed').length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF5A623).withValues(alpha: 0.12),
        border: Border.all(
          color: const Color(0xFFF5A623).withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Text(
        '$completed/${updates.length} done',
        style: const TextStyle(
          color: Color(0xFFF5A623),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Notification Icon Button ─────────────────────────────────────────────────
class _NotifIconBtn extends StatefulWidget {
  const _NotifIconBtn({required this.onTap, required this.isDark});
  final VoidCallback onTap;
  final bool isDark;

  @override
  State<_NotifIconBtn> createState() => _NotifIconBtnState();
}

class _NotifIconBtnState extends State<_NotifIconBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isDark
                ? const Color(0xFF1E1E1E)
                : const Color(0xFFF1F5F9),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                size: 21,
              ),
              Positioned(
                right: 9,
                top: 9,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5A623),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isDark
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
    );
  }
}

// ─── Timeline Widget ──────────────────────────────────────────────────────────
class TimelineWidget extends StatelessWidget {
  const TimelineWidget({
    super.key,
    required this.updates,
    required this.controller,
    required this.stagger,
    required this.onUserTap,
  });

  final List<IssueUpdate> updates;
  final AnimationController controller;
  final Duration stagger;
  final ValueChanged<String> onUserTap;

  @override
  Widget build(BuildContext context) {
    if (updates.isEmpty) {
      return const _EmptyState();
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: updates.length,
      itemBuilder: (context, index) {
        final IssueUpdate update = updates[index];
        final int beginMs = index * stagger.inMilliseconds;
        final int endMs = beginMs + 500;
        final Duration total =
            controller.duration ?? const Duration(milliseconds: 700);
        final double start = (beginMs / total.inMilliseconds).clamp(0.0, 1.0);
        final double finish = (endMs / total.inMilliseconds).clamp(0.0, 1.0);

        final CurvedAnimation itemAnimation = CurvedAnimation(
          parent: controller,
          curve: Interval(start, finish, curve: Curves.easeOutCubic),
        );

        return AnimatedBuilder(
          animation: itemAnimation,
          builder: (context, child) {
            final double value = itemAnimation.value;
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 24),
                child: child,
              ),
            );
          },
          child: _TimelineRow(
            update: update,
            isFirst: index == 0,
            isLast: index == updates.length - 1,
            onUserTap: onUserTap,
          ),
        );
      },
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: const Color(0xFF8B949E).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 14),
          const Text(
            'No results found',
            style: TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Timeline Row ─────────────────────────────────────────────────────────────
class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.update,
    required this.isFirst,
    required this.isLast,
    required this.onUserTap,
  });

  final IssueUpdate update;
  final bool isFirst;
  final bool isLast;
  final ValueChanged<String> onUserTap;

  Color _dotColor(String status) {
    switch (status) {
      case 'started':
        return const Color(0xFF22C55E);
      case 'in_progress':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFFF5A623);
      default:
        return const Color(0xFF8B949E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dot = _dotColor(update.status);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline rail ──────────────────────────────────────────────
          SizedBox(
            width: _kGrid * 3.5,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: 2,
                      color: isFirst
                          ? Colors.transparent
                          : const Color(0xFF2E3440),
                    ),
                  ),
                ),
                // Glowing dot
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dot,
                    boxShadow: [
                      BoxShadow(
                        color: dot.withValues(alpha: 0.55),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 2,
                      color: isLast
                          ? Colors.transparent
                          : const Color(0xFF2E3440),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: _kGrid),

          Expanded(
            child: UpdateCard(update: update, onUserTap: onUserTap),
          ),
        ],
      ),
    );
  }
}

// ─── Update Card ──────────────────────────────────────────────────────────────
class UpdateCard extends StatelessWidget {
  const UpdateCard({super.key, required this.update, required this.onUserTap});

  final IssueUpdate update;
  final ValueChanged<String> onUserTap;

  String _formatDate(DateTime dt) {
    const months = [
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
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final meridiem = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  •  '
        '${hour.toString().padLeft(2, '0')}:$minute $meridiem';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryText = isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF0F172A);
    final Color secondaryText = isDark
        ? const Color(0xFF8B949E)
        : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: _kGrid * 2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1C1C1C), Color(0xFF141414)],
              )
            : null,
        color: isDark ? null : Colors.white,
        border: Border.all(
          color: const Color(0xFFF5A623).withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF5A623).withValues(alpha: 0.06),
            blurRadius: 16,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  InkWell(
                    onTap: () => onUserTap(update.name),
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF5A623).withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          update.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (e1, e2, e3) => const Icon(
                            Icons.person,
                            color: Color(0xFFF5A623),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name & designation
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => onUserTap(update.name),
                          borderRadius: BorderRadius.circular(8),
                          child: Text(
                            update.name,
                            style: TextStyle(
                              color: primaryText,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          update.designation,
                          style: TextStyle(color: secondaryText, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: update.status),
                ],
              ),
            ),

            // ── Timestamp ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: secondaryText.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(update.timestamp),
                    style: TextStyle(
                      color: secondaryText.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // ── Thin gold divider ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF5A623).withValues(alpha: 0.0),
                      const Color(0xFFF5A623).withValues(alpha: 0.25),
                      const Color(0xFFF5A623).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Message ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                update.message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primaryText,
                  fontSize: 14,
                  height: 1.55,
                  letterSpacing: 0.1,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Image ─────────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: _kGrid * 20,
                    child: Image.network(
                      update.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (e1, e2, e3) => Container(
                        color: const Color(0xFF1C1C1C),
                        child: const Icon(
                          Icons.broken_image_rounded,
                          color: Color(0xFF8B949E),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  // gradient overlay on image
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.45),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final language = AppLanguage.instance.language;
    final bool isStarted = status == 'started';
    final bool isProgress = status == 'in_progress';
    final bool isCompleted = status == 'completed';

    final String label = switch (status) {
      'started' => AppLocalizations.translate(
        'work_started',
        language: language,
      ),
      'in_progress' => AppLocalizations.translate(
        'in_progress',
        language: language,
      ),
      'completed' => AppLocalizations.translate(
        'completed',
        language: language,
      ),
      _ => AppLocalizations.translate('update', language: language),
    };

    final Color bgColor = isStarted
        ? const Color(0xFF22C55E)
        : isProgress
        ? const Color(0xFF3B82F6)
        : const Color(0xFF0F1114);

    final Color textColor = isCompleted
        ? const Color(0xFFF5A623)
        : const Color(0xFFFFFFFF);
    final BorderSide border = isCompleted
        ? const BorderSide(color: Color(0xFFF5A623), width: 1)
        : BorderSide.none;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _kGrid * 1.25,
        vertical: _kGrid * 0.75,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(_kGrid * 2),
        border: Border.fromBorderSide(border),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: isCompleted ? 0.0 : 0.35),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.onTap, required this.language});

  final ValueChanged<String> onTap;
  final String language;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color navBg = isDark ? const Color(0xFF0D1117) : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFF5A623).withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _kGrid * 2,
            vertical: _kGrid * 1.25,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                  active: true,
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
                  active: false,
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
      radius: _kGrid * 3.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: active
                  ? const Color(0xFFF5A623).withValues(alpha: 0.13)
                  : Colors.transparent,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: active ? 0.2 : 0.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notify Button ────────────────────────────────────────────────────────────
class _NotifyButton extends StatefulWidget {
  const _NotifyButton({
    required this.onTap,
    required this.gold,
    required this.navy,
    required this.language,
  });

  final VoidCallback onTap;
  final Color gold;
  final Color navy;
  final String language;

  @override
  State<_NotifyButton> createState() => _NotifyButtonState();
}

class _NotifyButtonState extends State<_NotifyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: _kGrid * 7,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_kGrid * 3.75),
            border: Border.all(color: widget.gold, width: 1.5),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [widget.navy.withValues(alpha: 0.35), Colors.transparent],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gold.withValues(alpha: 0.12),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.gold.withValues(alpha: 0.12),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: widget.gold,
                  size: 20,
                ),
              ),
              const SizedBox(width: _kGrid * 1.25),
              Text(
                AppLocalizations.translate(
                  'notify_me_update',
                  language: widget.language,
                ),
                style: TextStyle(
                  color: widget.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Leader Logo ──────────────────────────────────────────────────────────────
class _LeaderLogo extends StatelessWidget {
  const _LeaderLogo();

  @override
  Widget build(BuildContext context) {
    return const Image(
      image: AssetImage('assets/images/logo_transparent.png'),
      height: 74,
      fit: BoxFit.contain,
    );
  }
}
