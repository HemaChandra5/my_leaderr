import 'package:flutter/material.dart';
import 'features/home/presentation/pages/home_page.dart';

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
      home: const HomePage(),
    );
  }
}
