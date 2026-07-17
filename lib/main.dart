import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/localization/app_language.dart';
import 'features/community/presentation/pages/community_page.dart';
import 'features/community/presentation/pages/actions/ask_question_screen.dart';
import 'features/community/presentation/pages/actions/create_event_screen.dart';
import 'features/community/presentation/pages/actions/create_poll_screen.dart';
import 'features/community/presentation/pages/actions/create_post_screen.dart';
import 'features/community/presentation/pages/actions/discussion_screen.dart';
import 'features/community/presentation/pages/actions/leader_announcement_screen.dart';
import 'features/community/presentation/pages/actions/share_location_screen.dart';
import 'features/community/presentation/pages/actions/upload_photos_screen.dart';
import 'features/community/presentation/pages/actions/upload_video_screen.dart';
import 'features/community/presentation/pages/quick_actions_hub_page.dart';
import 'features/community/navigation/community_action_routes.dart';
import 'features/community/state/community_hub_controller.dart';
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
import 'providers/settings_provider.dart';
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
  static const String publicProfile = '/profile/public';
  static const String inbox = '/messages';
  static const String chat = '/messages/chat';
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
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProvider<CommunityHubController>(
          create: (_) => CommunityHubController(),
        ),
      ],
      child: AnimatedBuilder(
        animation: AppLanguage.instance,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'My Leader',
            theme: AppTheme.dark,
            themeMode: ThemeMode.dark,
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
              AppRoutes.upcomingMeetings: (_) => const UpcomingMeetingsScreen(),
              AppRoutes.track: (_) => const TrackIssueScreen(),
              AppRoutes.profile: (_) => const ProfileDashboardGate(),
            },
            onGenerateRoute: (RouteSettings settings) {
              final String? name = settings.name;
              if (name == CommunityActionRoutes.quickActionsHub) {
                return _buildActionRoute(const QuickActionsHubPage(), settings);
              }
              if (name == CommunityActionRoutes.createPost) {
                return _buildActionRoute(const CreatePostScreen(), settings);
              }
              if (name == CommunityActionRoutes.uploadVideo) {
                return _buildActionRoute(const UploadVideoScreen(), settings);
              }
              if (name == CommunityActionRoutes.uploadPhotos) {
                return _buildActionRoute(const UploadPhotosScreen(), settings);
              }
              if (name == CommunityActionRoutes.createPoll) {
                return _buildActionRoute(const CreatePollScreen(), settings);
              }
              if (name == CommunityActionRoutes.askQuestion) {
                return _buildActionRoute(const AskQuestionScreen(), settings);
              }
              if (name == CommunityActionRoutes.createEvent) {
                return _buildActionRoute(const CreateEventScreen(), settings);
              }
              if (name == CommunityActionRoutes.leaderAnnouncement) {
                return _buildActionRoute(const LeaderAnnouncementScreen(), settings);
              }
              if (name == CommunityActionRoutes.shareLocation) {
                return _buildActionRoute(const ShareLocationScreen(), settings);
              }
              if (name == CommunityActionRoutes.discussion) {
                return _buildActionRoute(const DiscussionScreen(), settings);
              }

              if (settings.name == AppRoutes.publicProfile) {
                final Object? args = settings.arguments;
                if (args is PublicProfileRouteArgs) {
                  return MaterialPageRoute<void>(
                    builder: (_) => PublicUserProfileScreen(args: args),
                    settings: settings,
                  );
                }

                return MaterialPageRoute<void>(
                  builder: (_) => const _RouteArgumentErrorPage(
                    routeName: AppRoutes.publicProfile,
                    expectedType: 'PublicProfileRouteArgs',
                  ),
                  settings: settings,
                );
              }

              if (settings.name == AppRoutes.inbox) {
                return MaterialPageRoute<void>(
                  builder: (_) => const ChatListScreen(),
                  settings: settings,
                );
              }

              if (settings.name == AppRoutes.chat) {
                final Object? args = settings.arguments;
                if (args is ChatRouteArgs) {
                  return MaterialPageRoute<void>(
                    builder: (_) => ChatScreen(args: args),
                    settings: settings,
                  );
                }

                return MaterialPageRoute<void>(
                  builder: (_) => const _RouteArgumentErrorPage(
                    routeName: AppRoutes.chat,
                    expectedType: 'ChatRouteArgs',
                  ),
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

Route<T> _buildActionRoute<T>(Widget page, RouteSettings settings) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 340),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, Animation<double> animation, _) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: page,
      );
    },
    transitionsBuilder: (
      _,
      Animation<double> animation,
      _,
      Widget child,
    ) {
      final Animation<Offset> slide = Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: slide, child: child);
    },
  );
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

class _RouteArgumentErrorPage extends StatelessWidget {
  const _RouteArgumentErrorPage({
    required this.routeName,
    required this.expectedType,
  });

  final String routeName;
  final String expectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Invalid arguments for $routeName. Expected $expectedType.',
        ),
      ),
    );
  }
}
