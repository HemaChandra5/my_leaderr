import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';

const double _kGrid = 8;
const String _fontFamily = 'Inter';

const Color _gold = Color(0xFFF5A623);
const String _eventsRoute = '/events';
const String _trackRoute = '/track';
const String _communityRoute = '/community';
const String _createMenuRoute = '/create-menu';
const String _homeRoute = '/home';
const String _profileRoute = '/profile';

class CreateMenuAction {
  const CreateMenuAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? route;
}

class CreateMenuOverlay extends StatelessWidget {
  const CreateMenuOverlay({super.key});

  List<CreateMenuAction> _buildActions(String language) {
    return <CreateMenuAction>[
      CreateMenuAction(
        title: AppLocalizations.translate('create_post', language: language),
        subtitle: AppLocalizations.translate(
          'create_post_subtitle',
          language: language,
        ),
        icon: Icons.chat_bubble_outline_rounded,
      ),
      CreateMenuAction(
        title: AppLocalizations.translate('create_event', language: language),
        subtitle: AppLocalizations.translate(
          'create_event_subtitle',
          language: language,
        ),
        icon: Icons.calendar_today_outlined,
      ),
      CreateMenuAction(
        title: AppLocalizations.translate('report_issue', language: language),
        subtitle: AppLocalizations.translate(
          'report_issue_subtitle',
          language: language,
        ),
        icon: Icons.notifications_active_outlined,
        route: _trackRoute,
      ),
      CreateMenuAction(
        title: AppLocalizations.translate(
          'official_update',
          language: language,
        ),
        subtitle: AppLocalizations.translate(
          'official_update_subtitle',
          language: language,
        ),
        icon: Icons.record_voice_over_outlined,
      ),
      CreateMenuAction(
        title: AppLocalizations.translate(
          'public_announcement',
          language: language,
        ),
        subtitle: AppLocalizations.translate(
          'public_announcement_subtitle',
          language: language,
        ),
        icon: Icons.campaign_outlined,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLanguage.instance,
      builder: (context, _) {
        final String language = AppLanguage.instance.language;
        final List<CreateMenuAction> actions = _buildActions(language);
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final NavigatorState navigator = Navigator.of(context);
        final Color background = Theme.of(context).scaffoldBackgroundColor;
        final Color menuContainer = Theme.of(context).colorScheme.surface;
        final Color divider = isDark
            ? const Color(0xFF1F242C)
            : const Color(0xFFD7DEE8);
        final Color secondaryText = isDark
            ? const Color(0xFF8B949E)
            : const Color(0xFF64748B);
        final Color primaryText = isDark
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF0F172A);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 200),
            tween: Tween<double>(begin: 0, end: 1),
            curve: Curves.easeOut,
            builder:
                (BuildContext context, double overlayValue, Widget? child) {
                  return Opacity(opacity: overlayValue, child: child);
                },
            child: Scaffold(
              backgroundColor: background,
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
                          Text(
                            AppLocalizations.translate(
                              'create_new',
                              language: language,
                            ),
                            style: TextStyle(
                              color: primaryText,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: _fontFamily,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => navigator.pop(),
                            icon: const Icon(Icons.close_rounded),
                            color: primaryText,
                            iconSize: 24,
                            tooltip: AppLocalizations.translate(
                              'close',
                              language: language,
                            ),
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
                        padding: const EdgeInsets.symmetric(
                          vertical: _kGrid * 2,
                        ),
                        decoration: BoxDecoration(
                          color: menuContainer,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: divider),
                        ),
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 500),
                          tween: Tween<double>(begin: 0, end: 1),
                          curve: Curves.easeOut,
                          builder:
                              (
                                BuildContext context,
                                double progress,
                                Widget? _,
                              ) {
                                return Column(
                                  children: List<Widget>.generate(
                                    actions.length,
                                    (int index) {
                                      final CreateMenuAction action =
                                          actions[index];
                                      final double start = (index * 0.08).clamp(
                                        0.0,
                                        0.95,
                                      );
                                      final double end = (start + 0.28).clamp(
                                        0.0,
                                        1.0,
                                      );
                                      final double t =
                                          ((progress - start) / (end - start))
                                              .clamp(0.0, 1.0);
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
                                                primaryText: primaryText,
                                                secondaryText: secondaryText,
                                                onTap: () {
                                                  navigator.pop();
                                                  if (action.route != null) {
                                                    navigator
                                                        .pushReplacementNamed(
                                                          action.route!,
                                                        );
                                                  }
                                                },
                                              ),
                                              if (index != actions.length - 1)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 76,
                                                    right: _kGrid * 2,
                                                  ),
                                                  child: Divider(
                                                    height: 1,
                                                    thickness: 1,
                                                    color: divider,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                        ),
                      ),
                    ),
                    const Spacer(),
                    _OverlayBottomNavBar(language: language),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CreateMenuItem extends StatelessWidget {
  const CreateMenuItem({
    super.key,
    required this.action,
    required this.primaryText,
    required this.secondaryText,
    required this.onTap,
  });

  final CreateMenuAction action;
  final Color primaryText;
  final Color secondaryText;
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
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: _fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.subtitle,
                      style: TextStyle(
                        color: secondaryText,
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
  const _OverlayBottomNavBar({required this.language});

  final String language;

  void _onTap(BuildContext context, String route) {
    if (route == _communityRoute || route == _createMenuRoute) {
      return;
    }

    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    navigator.pop();

    if (route == _homeRoute || route == '/home') {
      navigator.pushReplacementNamed(_homeRoute);
      return;
    }

    if (route == _eventsRoute || route == _trackRoute) {
      navigator.pushReplacementNamed(route);
      return;
    }

    if (route == _profileRoute) {
      navigator.pushReplacementNamed(_profileRoute);
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            AppLocalizations.translate('coming_soon', language: language),
          ),
        ),
      );
  }

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
                  onTap: () => _onTap(context, _homeRoute),
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
                  onTap: () => _onTap(context, _trackRoute),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.groups_2_outlined,
                  label: AppLocalizations.translate(
                    'community',
                    language: language,
                  ),
                  active: true,
                  onTap: () => _onTap(context, _communityRoute),
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
                  onTap: () => _onTap(context, _eventsRoute),
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
                  onTap: () => _onTap(context, _profileRoute),
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
    final Color inactiveColor = isDark
        ? const Color(0xFF8B949E)
        : const Color(0xFF64748B);
    final Color color = active ? _gold : inactiveColor;

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
