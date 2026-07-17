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
import 'features/report_issue/presentation/screens/report_issue_screen.dart';
import 'features/track_issue/presentation/pages/track_issue_screen.dart';
import 'providers/user_provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'splash_screen.dart';
import 'core/theme/app_theme_manager.dart';
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
  static const String trackStatus = '/track/status';
  static const String profile = '/profile';
}

// Toggle this to force a minimal debug screen at startup for rendering checks.
const bool _forceDebugTest = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _AppBootstrap());
}

class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  late Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _initializeFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Firebase.initializeApp();
    await AppLanguage.instance.load();
    await AppThemeManager.instance.load();
  }

  void _retry() {
    setState(() {
      _initializeFuture = _initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Color(0xFF07090D),
              body: Center(
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: const Color(0xFF07090D),
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 40,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'App initialization failed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: const TextStyle(
                            color: Color(0xFFB9C0CC),
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: _retry,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return const MyLeaderApp();
      },
    );
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
      ],
      child: AnimatedBuilder(
        animation: Listenable.merge([
          AppLanguage.instance,
          AppThemeManager.instance,
        ]),
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'My Leader',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: AppThemeManager.instance.themeMode,
            initialRoute: _forceDebugTest ? AppRoutes.debug : AppRoutes.splash,
            routes: <String, WidgetBuilder>{
              AppRoutes.debug: (_) => const _DebugTestPage(),
              AppRoutes.splash: (_) => const SplashScreen(),
              AppRoutes.home: (_) => const HomePage(),
              AppRoutes.community: (_) => const CommunityPage(),
              AppRoutes.createMenu: (_) => const CreateMenuOverlay(),
              AppRoutes.events: (_) => const EventsScreen(),
              AppRoutes.upcomingMeetings: (_) => const UpcomingMeetingsScreen(),
              AppRoutes.track: (_) => const ReportIssueScreen(),
              AppRoutes.trackStatus: (_) => const TrackIssueScreen(),
              AppRoutes.profile: (_) => const ProfileDashboardGate(),
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
