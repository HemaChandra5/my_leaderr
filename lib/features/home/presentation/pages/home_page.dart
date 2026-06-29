import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const double _kGrid = 8;
const String _fontFamily = 'Inter';

const String _homeRoute = '/home';
const String _eventsRoute = '/events';
const String _trackRoute = '/track';
const String _createMenuRoute = '/create-menu';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color _background = Color(0xFF000000);
  static const Color _card = Color(0xFF111111);
  static const Color _gold = Color(0xFFF5A623);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFF8B949E);

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
            title: const Text(
              'Home',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                fontFamily: _fontFamily,
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(_kGrid * 2),
              children: const <Widget>[
                _WelcomeCard(),
                SizedBox(height: _kGrid * 2),
                _QuickActionsCard(),
                SizedBox(height: _kGrid * 2),
                _StatsRow(),
              ],
            ),
          ),
          bottomNavigationBar: _BottomNavBar(
            onTap: (String route) {
              if (route == _homeRoute) {
                return;
              }

              if (route == _createMenuRoute) {
                Navigator.of(context).pushNamed(_createMenuRoute);
                return;
              }

              if (route == _eventsRoute || route == _trackRoute) {
                Navigator.of(context).pushReplacementNamed(route);
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
            },
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_kGrid * 2),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x22F5A623)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
            'Welcome Back',
            style: TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 13,
              fontFamily: _fontFamily,
            ),
          ),
          SizedBox(height: _kGrid),
          Text(
            'MY LEADER Dashboard',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: _fontFamily,
            ),
          ),
          SizedBox(height: _kGrid),
          Text(
            'Track civic issues, follow events, and share updates with your community in one place.',
            style: TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 14,
              height: 1.4,
              fontFamily: _fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_kGrid * 2),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: _fontFamily,
            ),
          ),
          const SizedBox(height: _kGrid * 1.5),
          Row(
            children: <Widget>[
              Expanded(
                child: _ActionButton(
                  label: 'Open Events',
                  icon: Icons.event_outlined,
                  onTap: () =>
                      Navigator.of(context).pushReplacementNamed(_eventsRoute),
                ),
              ),
              const SizedBox(width: _kGrid),
              Expanded(
                child: _ActionButton(
                  label: 'Track Issue',
                  icon: Icons.track_changes_rounded,
                  onTap: () =>
                      Navigator.of(context).pushReplacementNamed(_trackRoute),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0x33F5A623)),
        foregroundColor: const Color(0xFFF5A623),
        padding: const EdgeInsets.symmetric(vertical: _kGrid * 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontFamily: _fontFamily)),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Expanded(
          child: _StatCard(
            label: 'Open Issues',
            value: '12',
            color: Color(0xFF3B82F6),
          ),
        ),
        SizedBox(width: _kGrid),
        Expanded(
          child: _StatCard(
            label: 'Upcoming Events',
            value: '5',
            color: Color(0xFFF5A623),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_kGrid * 2),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 12,
              fontFamily: _fontFamily,
            ),
          ),
          const SizedBox(height: _kGrid),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: _fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF161B22),
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
                active: true,
                onTap: () => onTap(_homeRoute),
              ),
              _NavItem(
                icon: Icons.track_changes_rounded,
                label: 'Track',
                active: false,
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
            decoration: const BoxDecoration(
              color: Color(0xFFF5A623),
              shape: BoxShape.circle,
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
