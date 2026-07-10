import 'package:flutter/material.dart';

import '../../../../core/localization/app_language.dart';
import '../../../home/presentation/widgets/bottom_navigation.dart';

const String _eventsRoute = '/events';
const String _trackRoute = '/track';
const String _createMenuRoute = '/create-menu';
const String _homeRoute = '/home';
const String _profileRoute = '/profile';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  void _handleBottomNavSelection(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(_homeRoute);
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(_trackRoute);
      return;
    }

    if (index == 2) {
      return;
    }

    if (index == 3) {
      Navigator.of(context).pushReplacementNamed(_eventsRoute);
      return;
    }

    Navigator.of(context).pushReplacementNamed(_profileRoute);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLanguage.instance,
      builder: (context, _) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: const SizedBox.expand(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).pushNamed(_createMenuRoute),
            backgroundColor: const Color(0xFFF5A623),
            foregroundColor: isDark ? Colors.black : const Color(0xFF111827),
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 30),
          ),
          bottomNavigationBar: BottomNavigation(
            currentIndex: 2,
            onItemSelected: _handleBottomNavSelection,
          ),
        );
      },
    );
  }
}
