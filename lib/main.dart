import 'package:flutter/material.dart';

import 'features/create/presentation/pages/create_menu_overlay.dart';
import 'features/events/presentation/pages/events_screen.dart';
import 'features/events/presentation/pages/upcoming_meetings_screen.dart';
import 'features/track_issue/presentation/pages/track_issue_screen.dart';

class AppRoutes {
  static const String createMenu = '/create-menu';
  static const String events = '/events';
  static const String upcomingMeetings = '/events/upcoming';
  static const String track = '/track';
}

void main() {
  runApp(const MyLeaderApp());
}

class MyLeaderApp extends StatelessWidget {
  const MyLeaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MY LEADER',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.events,
      routes: <String, WidgetBuilder>{
        AppRoutes.createMenu: (_) => const CreateMenuOverlay(),
        AppRoutes.events: (_) => const EventsScreen(),
        AppRoutes.upcomingMeetings: (_) => const UpcomingMeetingsScreen(),
        AppRoutes.track: (_) => const TrackIssueScreen(),
      },
    );
  }
}
