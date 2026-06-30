import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const double _kGrid = 8;
const String _fontFamily = 'Inter';

const Color _background = Color(0xFF000000);
const Color _menuContainer = Color(0xFF111111);
const Color _gold = Color(0xFFF5A623);
const Color _secondaryText = Color(0xFF8B949E);
const Color _divider = Color(0xFF1F242C);
const Color _navBackground = Color(0xFF0D1117);

const String _eventsRoute = '/events';
const String _trackRoute = '/track';
const String _createMenuRoute = '/create-menu';

class CreateMenuAction {
  const CreateMenuAction({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class CreateMenuOverlay extends StatelessWidget {
  const CreateMenuOverlay({super.key});

  static const List<CreateMenuAction> _actions = <CreateMenuAction>[
    CreateMenuAction(
      title: 'Create Community Post',
      subtitle: 'Share updates with your community',
      icon: Icons.chat_bubble_outline_rounded,
    ),
    CreateMenuAction(
      title: 'Create Event',
      subtitle: 'Organize and invite to events',
      icon: Icons.calendar_today_outlined,
    ),
    CreateMenuAction(
      title: 'Report Issue',
      subtitle: 'Report civic issues to authorities',
      icon: Icons.notifications_active_outlined,
    ),
    CreateMenuAction(
      title: 'Official Update (Leader)',
      subtitle: 'Share official update as a leader',
      icon: Icons.record_voice_over_outlined,
    ),
    CreateMenuAction(
      title: 'Public Announcement (Leader)',
      subtitle: 'Make an important announcement',
      icon: Icons.campaign_outlined,
    ),
  ];

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
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 200),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeOut,
          builder: (BuildContext context, double overlayValue, Widget? child) {
            return Opacity(opacity: overlayValue, child: child);
          },
          child: Scaffold(
            backgroundColor: _background,
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _kGrid * 2,
                      _kGrid * 2,
                      _kGrid,
                      _kGrid * 1.5,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Spacer(),
                        const Text(
                          'Create New',
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: _fontFamily,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          color: const Color(0xFFFFFFFF),
                          iconSize: 24,
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 200),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.easeOutCubic,
                    builder:
                        (BuildContext context, double value, Widget? child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 16),
                              child: child,
                            ),
                          );
                        },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: _kGrid * 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: _kGrid * 2),
                      decoration: BoxDecoration(
                        color: _menuContainer,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _divider),
                      ),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween<double>(begin: 0, end: 1),
                        curve: Curves.easeOut,
                        builder: (BuildContext context, double progress, Widget? _) {
                          return Column(
                            children: List<Widget>.generate(_actions.length, (
                              int index,
                            ) {
                              final CreateMenuAction action = _actions[index];
                              final double start = (index * 0.08).clamp(
                                0.0,
                                0.95,
                              );
                              final double end = (start + 0.28).clamp(0.0, 1.0);
                              final double t =
                                  ((progress - start) / (end - start)).clamp(
                                    0.0,
                                    1.0,
                                  );
                              final double eased = Curves.easeOutCubic
                                  .transform(t);

                              return Opacity(
                                opacity: eased,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - eased) * 10),
                                  child: Column(
                                    children: <Widget>[
                                      CreateMenuItem(
                                        action: action,
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          debugPrint(
                                            'Create action selected: ${action.title}',
                                          );
                                        },
                                      ),
                                      if (index != _actions.length - 1)
                                        const Padding(
                                          padding: EdgeInsets.only(
                                            left: 76,
                                            right: _kGrid * 2,
                                          ),
                                          child: Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: _divider,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  const _OverlayBottomNavBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CreateMenuItem extends StatelessWidget {
  const CreateMenuItem({super.key, required this.action, required this.onTap});

  final CreateMenuAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0x332D333B),
        highlightColor: const Color(0x1F2D333B),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _kGrid * 2,
            vertical: _kGrid * 1.5,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(action.icon, color: _gold, size: 24),
              ),
              const SizedBox(width: _kGrid * 1.5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      action.title,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: _fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.subtitle,
                      style: const TextStyle(
                        color: _secondaryText,
                        fontSize: 13,
                        fontFamily: _fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayBottomNavBar extends StatelessWidget {
  const _OverlayBottomNavBar();

  void _onTap(BuildContext context, String route) {
    if (route == _createMenuRoute) {
      return;
    }

    Navigator.of(context).pop();

    if (route == _eventsRoute || route == _trackRoute) {
      Future<void>.microtask(() {
        Navigator.of(context).pushReplacementNamed(route);
      });
      return;
    }

    Future<void>.microtask(() {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('This section is coming soon'),
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _navBackground,
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
                onTap: () => _onTap(context, '/home'),
              ),
              _NavItem(
                icon: Icons.track_changes_rounded,
                label: 'Track',
                active: false,
                onTap: () => _onTap(context, _trackRoute),
              ),
              _ActiveAddButton(onTap: () => _onTap(context, _createMenuRoute)),
              _NavItem(
                icon: Icons.event_outlined,
                label: 'Events',
                active: false,
                onTap: () => _onTap(context, _eventsRoute),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                active: false,
                onTap: () => _onTap(context, '/profile'),
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
    final Color color = active ? _gold : _secondaryText;

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

class _ActiveAddButton extends StatelessWidget {
  const _ActiveAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: _kGrid * 3,
      child: Container(
        width: _kGrid * 6,
        height: _kGrid * 6,
        decoration: const BoxDecoration(
          color: _gold,
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
