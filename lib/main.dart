import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/localization/app_language.dart';
import 'features/community/presentation/pages/community_page.dart';
import 'features/create/presentation/pages/create_menu_overlay.dart';
import 'features/events/screens/events_screen.dart';
import 'features/events/presentation/pages/upcoming_meetings_screen.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/messaging/models/chat_models.dart';
import 'features/messaging/models/public_user_profile.dart';
import 'features/messaging/presentation/pages/chat_list_screen.dart';
import 'features/messaging/presentation/pages/chat_screen.dart';
import 'features/messaging/presentation/pages/public_user_profile_screen.dart';
import 'features/profile/presentation/pages/profile_dashboard_gate.dart';
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
  static const String profile = '/profile';
  static const String publicProfile = '/public-profile';
  static const String inbox = '/messages';
  static const String chat = '/messages/chat';
}

// Toggle this to force a minimal debug screen at startup for rendering checks.
const bool _forceDebugTest = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AppLanguage.instance.load();
  await AppThemeManager.instance.load();
  runApp(const MyLeaderApp());
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
              AppRoutes.track: (_) => const TrackIssueScreen(),
              AppRoutes.profile: (_) => const ProfileDashboardGate(),
              AppRoutes.inbox: (_) => const ChatListScreen(),
            },
            onGenerateRoute: (RouteSettings settings) {
              if (settings.name == AppRoutes.publicProfile) {
                final PublicProfileRouteArgs args =
                    settings.arguments as PublicProfileRouteArgs;
                return MaterialPageRoute<void>(
                  builder: (_) => PublicUserProfileScreen(args: args),
                  settings: settings,
                );
              }

              if (settings.name == AppRoutes.chat) {
                final ChatRouteArgs args = settings.arguments as ChatRouteArgs;
                return MaterialPageRoute<void>(
                  builder: (_) => ChatScreen(args: args),
                  settings: settings,
                );
              }

              return null;
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
