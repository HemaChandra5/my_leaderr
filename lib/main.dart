import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/localization/app_language.dart';
import 'features/community/presentation/pages/community_page.dart';
import 'features/create/presentation/pages/create_menu_overlay.dart';
import 'features/events/presentation/pages/events_screen.dart';
import 'features/events/presentation/pages/upcoming_meetings_screen.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/profile_dashboard_gate.dart';
import 'features/track_issue/presentation/pages/track_issue_screen.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'splash_screen.dart';
import 'theme.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String debug = '/debug-test';
  static const String home = '/home';
  static const String community = '/community';
  static const String createMenu = '/create-menu';
  static const String events = '/events';
  static const String upcomingMeetings = '/events/upcoming';
  static const String track = '/track';
  static const String profile = '/profile';
}

// Toggle this to force a minimal debug screen at startup for rendering checks.
const bool _forceDebugTest = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await AppLanguage.instance.load();
    runApp(const MyLeaderApp(firebaseReady: true));
  } catch (e) {
    runApp(MyLeaderApp(firebaseReady: false, firebaseError: e.toString()));
  }
}

class MyLeaderApp extends StatelessWidget {
  const MyLeaderApp({super.key, this.firebaseReady = true, this.firebaseError});

  final bool firebaseReady;
  final String? firebaseError;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(
            authService: AuthService(),
            firestoreService: FirestoreService(),
          ),
        ),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: AnimatedBuilder(
        animation: AppLanguage.instance,
        builder: (context, _) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, __) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'My Leader',
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeProvider.themeMode,
                home: firebaseReady
                    ? null
                    : _StartupErrorPage(
                        error: firebaseError ?? 'Unknown startup error',
                      ),
                initialRoute: firebaseReady
                    ? (_forceDebugTest ? AppRoutes.debug : AppRoutes.splash)
                    : null,
                routes: <String, WidgetBuilder>{
                  AppRoutes.debug: (_) => const _DebugTestPage(),
                  AppRoutes.splash: (_) => const SplashScreen(),
                  AppRoutes.home: (_) => const HomePage(),
                  AppRoutes.community: (_) => const CommunityPage(),
                  AppRoutes.createMenu: (_) => const CreateMenuOverlay(),
                  AppRoutes.events: (_) => const EventsScreen(),
                  AppRoutes.upcomingMeetings: (_) =>
                      const UpcomingMeetingsScreen(),
                  AppRoutes.track: (_) => const TrackIssueScreen(),
                  AppRoutes.profile: (_) => const ProfileDashboardGate(),
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _DebugTestPage extends StatelessWidget {
  const _DebugTestPage();

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Colors.blueAccent,
      child: SafeArea(
        child: Center(
          child: Text(
            'DEBUG RENDER: VISIBLE',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}

class _StartupErrorPage extends StatelessWidget {
  const _StartupErrorPage({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Startup Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'The app could not finish initialization. Check the error below.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.amberAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
