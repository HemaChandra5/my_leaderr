import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/citizen_profile.dart';
import '../widgets/bottom_nav_bar_widget.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_menu_card_widget.dart';
import '../widgets/stats_row_widget.dart';

const String _homeRoute = '/home';
const String _eventsRoute = '/events';
const String _trackRoute = '/track';
const String _createMenuRoute = '/create-menu';

class CitizenProfileDashboard extends StatefulWidget {
  const CitizenProfileDashboard({super.key});

  @override
  State<CitizenProfileDashboard> createState() =>
      _CitizenProfileDashboardState();
}

class _CitizenProfileDashboardState extends State<CitizenProfileDashboard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _screenAnimationController;
  late final Animation<double> _screenFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _statsScale;

  final CitizenProfile _profile = const CitizenProfile(
    name: 'Priya Sharma',
    role: 'Citizen',
    location: 'Kukatpally',
    isVerified: true,
    posts: 24,
    issuesReported: 18,
    issuesResolved: 15,
    eventsAttended: 12,
  );

  @override
  void initState() {
    super.initState();
    _screenAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _screenFade = CurvedAnimation(
      parent: _screenAnimationController,
      curve: Curves.easeOut,
    );

    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.04), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _screenAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _statsScale = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(
        parent: _screenAnimationController,
        curve: const Interval(0.2, 1, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void dispose() {
    _screenAnimationController.dispose();
    super.dispose();
  }

  void _handleMenuTap(String item) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('$item tapped'),
        ),
      );
  }

  void _onBottomTabTap(int index) {
    if (index == 4) {
      return;
    }

    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(_homeRoute);
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(_trackRoute);
      return;
    }

    if (index == 2) {
      Navigator.of(context).pushNamed(_createMenuRoute);
      return;
    }

    if (index == 3) {
      Navigator.of(context).pushReplacementNamed(_eventsRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final minWidth = MediaQuery.sizeOf(context).width < 360
        ? 360.0
        : MediaQuery.sizeOf(context).width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFF000000),
          appBar: AppBar(
            backgroundColor: const Color(0xFF000000),
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _handleMenuTap('Settings'),
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Color(0xFF8B949E),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: FadeTransition(
              opacity: _screenFade,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                    maxWidth: 640,
                  ),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    children: [
                      SlideTransition(
                        position: _headerSlide,
                        child: ProfileHeaderWidget(profile: _profile),
                      ),
                      const SizedBox(height: 16),
                      ScaleTransition(
                        scale: _statsScale,
                        child: StatsRowWidget(profile: _profile),
                      ),
                      const SizedBox(height: 16),
                      ProfileMenuCardWidget(onItemTap: _handleMenuTap),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomNavBarWidget(onTabTap: _onBottomTabTap),
        ),
      ),
    );
  }
}
