import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/language_provider.dart';
import 'providers/user_provider.dart';
import 'splash_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

class AppRoutes {
  static const String home = '/home';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseReady = false;
  String? firebaseError;

  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e) {
    firebaseError = e.toString();
  }

  runApp(
    MyLeaderApp(firebaseReady: firebaseReady, firebaseError: firebaseError),
  );
}

class MyLeaderApp extends StatelessWidget {
  const MyLeaderApp({super.key, this.firebaseReady = true, this.firebaseError});

  final bool firebaseReady;
  final String? firebaseError;

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Leader',
        theme: ThemeData.dark(useMaterial3: true),
        home: _FirebaseSetupScreen(error: firebaseError),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>(
          create: (_) => LanguageProvider()..loadSavedLanguage(),
        ),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(
            authService: context.read<AuthService>(),
            firestoreService: context.read<FirestoreService>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Leader',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF000000),
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFF5A623),
            secondary: Color(0xFFF5A623),
            surface: Color(0xFF121212),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF101010),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5A623),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        routes: <String, WidgetBuilder>{
          AppRoutes.home: (_) => const SplashScreen(),
        },
        home: const SplashScreen(),
      ),
    );
  }
}

class _FirebaseSetupScreen extends StatelessWidget {
  const _FirebaseSetupScreen({required this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xFFF5A623),
                size: 56,
              ),
              const SizedBox(height: 12),
              const Text(
                'Firebase is not configured',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add google-services.json and finish FlutterFire setup to enable auth and onboarding.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFD0D0D0)),
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
