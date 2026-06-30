import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const double _kGrid = 8;
const String _eventsRoute = '/events';
const String _trackRoute = '/track';
const String _createMenuRoute = '/create-menu';

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
  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF111111);
  static const Color _gold = Color(0xFFF5A623);
  static const Color _navy = Color(0xFF0D1B3E);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFF8B949E);
  static const Color _success = Color(0xFF22C55E);
  static const Color _progress = Color(0xFF3B82F6);
  static const Color _navBackground = Color(0xFF0D1117);

  static const Duration _itemStagger = Duration(milliseconds: 150);
  static const Duration _entryDuration = Duration(milliseconds: 700);

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _entryDuration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    if (route == _trackRoute) {
      return;
    }

    if (route == _createMenuRoute) {
      Navigator.of(context).pushNamed(_createMenuRoute);
      return;
    }

    if (route == _eventsRoute) {
      Navigator.of(context).pushReplacementNamed(_eventsRoute);
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
        scaffoldBackgroundColor: _bg,
        useMaterial3: true,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            backgroundColor: _bg,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: const _LeaderLogo(),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
                color: _textPrimary,
                tooltip: 'Notifications',
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
                  const Text(
                    'Live Updates',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: _kGrid * 2),
                  Expanded(
                    child: TimelineWidget(
                      updates: _updates,
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
                  ),
                ),
              ),
              BottomNavBar(onTap: _handleBottomNavTap),
            ],
          ),
        ),
      ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: _kGrid * 2),
      padding: const EdgeInsets.all(_kGrid * 2),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
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
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: _kGrid / 2),
                    Text(
                      update.designation,
                      style: const TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 12,
                      ),
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
            style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12),
          ),
          const SizedBox(height: _kGrid * 1.5),
          Text(
            update.message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 14,
              height: 1.4,
            ),
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
    final bool isStarted = status == 'started';
    final bool isProgress = status == 'in_progress';
    final bool isCompleted = status == 'completed';

    final String label = switch (status) {
      'started' => 'Work Started',
      'in_progress' => 'In Progress',
      'completed' => 'Completed',
      _ => 'Update',
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
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                active: false,
                onTap: () => onTap('/home'),
              ),
              _NavItem(
                icon: Icons.track_changes_rounded,
                label: 'Track',
                active: true,
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
            decoration: BoxDecoration(
              color: const Color(0xFFF5A623),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
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
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: _kGrid / 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifyButton extends StatefulWidget {
  const _NotifyButton({
    required this.onTap,
    required this.gold,
    required this.navy,
  });

  final VoidCallback onTap;
  final Color gold;
  final Color navy;

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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded, color: Color(0xFFF5A623)),
            SizedBox(width: _kGrid),
            Text(
              'Notify Me on Update',
              style: TextStyle(
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(
          Icons.workspace_premium_rounded,
          color: Color(0xFFF5A623),
          size: 22,
        ),
        SizedBox(width: _kGrid),
        Text(
          'MY LEADER',
          style: TextStyle(
            color: Color(0xFFF5A623),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}
