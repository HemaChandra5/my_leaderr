import 'package:flutter/material.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/create/presentation/pages/create_menu_overlay.dart';
import 'features/events/presentation/pages/events_screen.dart';
import 'features/events/presentation/pages/upcoming_meetings_screen.dart';
import 'features/track_issue/presentation/pages/track_issue_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String createMenu = '/create-menu';
  static const String events = '/events';
  static const String home = '/home';
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
    const surface = Color(0xFF111214);
    const background = Color(0xFF090A0B);
    const primary = Color(0xFFF5A623);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Leader',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: primary,
          surface: surface,
        ),
        cardColor: surface,
        dividerColor: const Color(0xFF25272B),
        splashFactory: InkSparkle.splashFactory,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, height: 1.45),
          bodyMedium: TextStyle(color: Colors.white, height: 1.45),
          titleMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      routes: <String, WidgetBuilder>{
        AppRoutes.home: (_) => const HomePage(),
        AppRoutes.createMenu: (_) => const CreateMenuOverlay(),
        AppRoutes.events: (_) => const EventsScreen(),
        AppRoutes.home: (_) => const EventsScreen(),
        AppRoutes.upcomingMeetings: (_) => const UpcomingMeetingsScreen(),
        AppRoutes.track: (_) => const TrackIssueScreen(),
      },
    );
  }
}
