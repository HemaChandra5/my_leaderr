import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../providers/user_provider.dart';

import '../../domain/models/citizen_profile.dart';
import 'settings_screen.dart';
import '../widgets/bottom_nav_bar_widget.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_menu_card_widget.dart';
import '../widgets/stats_row_widget.dart';

const String _homeRoute = '/home';
const String _eventsRoute = '/events';
const String _trackRoute = '/track';
const String _communityRoute = '/community';

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

  CitizenProfile _resolvedProfile(UserProvider provider) {
    final user = provider.appUser;

    if (user == null) {
      return const CitizenProfile(
        name: 'Citizen',
        role: 'Citizen',
        location: 'Not set',
        isVerified: true,
        posts: 24,
        issuesReported: 18,
        issuesResolved: 15,
        eventsAttended: 12,
      );
    }

    final city = (user.city ?? '').trim();
    final state = (user.state ?? '').trim();
    final location = city.isNotEmpty && state.isNotEmpty
        ? '$city, $state'
        : (city.isNotEmpty
              ? city
              : (state.isNotEmpty ? state : 'Location not set'));

    return CitizenProfile(
      name: user.name.isNotEmpty ? user.name : 'Citizen',
      role: 'Citizen',
      location: location,
      isVerified: user.verificationStatus == 'verified',
      posts: 24,
      issuesReported: 18,
      issuesResolved: 15,
      eventsAttended: 12,
      profileImage: user.profileImage,
    );
  }

  String get _language => AppLanguage.instance.language;
  String _tr(String key) =>
      AppLocalizations.translate(key, language: _language);

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

  void _handleMenuTap(String itemKey) {
    if (itemKey == 'settings') {
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
      );
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('${_tr(itemKey)} tapped'),
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
      Navigator.of(context).pushReplacementNamed(_communityRoute);
      return;
    }

    if (index == 3) {
      Navigator.of(context).pushReplacementNamed(_eventsRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final profile = _resolvedProfile(provider);
    final minWidth = MediaQuery.sizeOf(context).width < 360
        ? 360.0
        : MediaQuery.sizeOf(context).width;

    return AnimatedBuilder(
      animation: AppLanguage.instance,
      builder: (context, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: const Color(0xFF000000),
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
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                        children: [
                          Row(
                            children: [
                              const Spacer(),
                              Image.asset(
                                'assets/images/logo.png',
                                width: 120,
                                fit: BoxFit.contain,
                              ),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SlideTransition(
                            position: _headerSlide,
                            child: ProfileHeaderWidget(profile: profile),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111111),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0x66F5A623),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _tr('boost_citizen'),
                                  style: const TextStyle(
                                    color: Color(0xFFF5A623),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _tr('unlock_premium_features'),
                                  style: const TextStyle(
                                    color: Color(0xFF8B949E),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          ScaleTransition(
                            scale: _statsScale,
                            child: StatsRowWidget(profile: profile),
                          ),
                          const SizedBox(height: 12),
                          ProfileMenuCardWidget(onItemTap: _handleMenuTap),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: BottomNavBarWidget(
                onTabTap: _onBottomTabTap,
              ),
            ),
          ),
        );
      },
    );
  }
}
