import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/welcome/presentation/pages/choose_role_page.dart';
import 'features/welcome/presentation/pages/login_page.dart';
import 'features/welcome/presentation/pages/welcome_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/create/presentation/pages/create_menu_overlay.dart';
import 'features/events/presentation/pages/events_screen.dart';
import 'features/events/presentation/pages/upcoming_meetings_screen.dart';
import 'features/track_issue/presentation/pages/track_issue_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String home = '/home';
  static const String chooseRole = '/choose-role';
  static const String login = '/login';
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
      title: 'My Leader',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryGold,
          secondary: AppColors.primaryGold,
          surface: AppColors.surface,
        ),
        cardColor: AppColors.surface,
        dividerColor: AppColors.divider,
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
      initialRoute: AppRoutes.welcome,
      routes: <String, WidgetBuilder>{
        AppRoutes.welcome: (_) => const WelcomePage(),
        AppRoutes.home: (_) => const HomePage(),
        AppRoutes.chooseRole: (_) => const ChooseRolePage(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.createMenu: (_) => const CreateMenuOverlay(),
        AppRoutes.events: (_) => const EventsScreen(),
        AppRoutes.upcomingMeetings: (_) => const UpcomingMeetingsScreen(),
        AppRoutes.track: (_) => const TrackIssueScreen(),
      },
    );
  }
}
