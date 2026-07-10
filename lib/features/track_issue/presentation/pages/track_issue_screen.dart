import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';

const double _kGrid = 8;
const String _homeRoute = '/home';
const String _communityRoute = '/community';
const String _eventsRoute = '/events';
const String _trackRoute = '/track';
const String _profileRoute = '/profile';

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
    if (query.isEmpty) {
      return _updates;
    }
    return _updates
        .where((update) {
          return update.name.toLowerCase().contains(query) ||
              update.designation.toLowerCase().contains(query) ||
              update.message.toLowerCase().contains(query) ||
              update.status.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

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
    if (route == _trackRoute) {
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
              title: const _LeaderLogo(),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: _kGrid * 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: _kGrid),
                    SizedBox(
                      height: 48,
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
                            Icons.search,
                            color: secondaryText,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: fieldBg,
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
                    const SizedBox(height: _kGrid * 1.5),
                    Text(
                      _tr('live_updates'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: _kGrid * 2),
                    Expanded(
                      child: TimelineWidget(
                        updates: _filteredUpdates,
                        controller: _controller,
                        stagger: _itemStagger,
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

class TimelineWidget extends StatelessWidget {
  const TimelineWidget({
    super.key,
    required this.updates,
    required this.controller,
    required this.stagger,
  });

  final List<IssueUpdate> updates;
  final AnimationController controller;
  final Duration stagger;

  @override
  Widget build(BuildContext context) {
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
          ),
        );
      },
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.update,
    required this.isFirst,
    required this.isLast,
  });

  static const Color _lineColor = Color(0xFF5E6772);

  final IssueUpdate update;
  final bool isFirst;
  final bool isLast;

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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _kGrid * 3,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst ? Colors.transparent : _lineColor,
                  ),
                ),
                Container(
                  width: _kGrid * 1.5,
                  height: _kGrid * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _dotColor(update.status),
                    boxShadow: [
                      BoxShadow(
                        color: _dotColor(update.status).withValues(alpha: 0.5),
                        blurRadius: _kGrid,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : _lineColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: _kGrid),
          Expanded(child: UpdateCard(update: update)),
        ],
      ),
    );
  }
}

class UpdateCard extends StatelessWidget {
  const UpdateCard({super.key, required this.update});

  final IssueUpdate update;

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
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} • ${hour.toString().padLeft(2, '0')}:$minute $meridiem';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = Theme.of(context).colorScheme.surface;
    final Color primaryText = isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF0F172A);
    final Color secondaryText = isDark
        ? const Color(0xFF8B949E)
        : const Color(0xFF64748B);
    return Container(
      margin: const EdgeInsets.only(bottom: _kGrid * 2),
      padding: const EdgeInsets.all(_kGrid * 2),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(_kGrid * 2),
        border: Border.all(
          color: const Color(0xFFF5A623).withValues(alpha: 0.22),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF5A623).withValues(alpha: 0.08),
            blurRadius: _kGrid,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(_kGrid * 2.5),
                child: Image.network(
                  update.imageUrl,
                  width: _kGrid * 5,
                  height: _kGrid * 5,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: _kGrid * 1.5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      update.name,
                      style: TextStyle(
                        color: primaryText,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: _kGrid / 2),
                    Text(
                      update.designation,
                      style: TextStyle(color: secondaryText, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: _kGrid),
              StatusBadge(status: update.status),
            ],
          ),
          const SizedBox(height: _kGrid * 1.5),
          Text(
            _formatDate(update.timestamp),
            style: TextStyle(color: secondaryText, fontSize: 12),
          ),
          const SizedBox(height: _kGrid * 1.5),
          Text(
            update.message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: primaryText, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: _kGrid * 1.5),
          ClipRRect(
            borderRadius: BorderRadius.circular(_kGrid * 1.5),
            child: SizedBox(
              width: double.infinity,
              height: _kGrid * 20,
              child: Image.network(update.imageUrl, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

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
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(
        horizontal: _kGrid * 1.5,
        vertical: _kGrid,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(_kGrid * 2),
        border: Border.fromBorderSide(border),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
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
      radius: _kGrid * 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            ),
          ),
        ],
      ),
    );
  }
}

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
    final Matrix4 transform = _pressed
        ? (Matrix4.identity()..scale(0.98))
        : Matrix4.identity();

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: transform,
        height: _kGrid * 6.5,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_kGrid * 3.75),
          border: Border.all(color: widget.gold, width: 2),
          gradient: LinearGradient(
            colors: [
              widget.navy.withValues(alpha: 0.35),
              const Color(0x000D1B3E),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFFF5A623),
            ),
            const SizedBox(width: _kGrid),
            Text(
              AppLocalizations.translate(
                'notify_me_update',
                language: widget.language,
              ),
              style: const TextStyle(
                color: Color(0xFFF5A623),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
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
      height: 74,
      fit: BoxFit.contain,
    );
  }
}
