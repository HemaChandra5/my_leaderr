import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _loadTheme();
  }

  static const String _themePreferenceKey = 'theme_mode';

  bool _isDark = true;

  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> _loadTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedMode = prefs.getString(_themePreferenceKey);

    if (savedMode == null) {
      return;
    }

    _isDark = savedMode != 'light';
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    if (_isDark == value) {
      return;
    }

    _isDark = value;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, _isDark ? 'dark' : 'light');
  }
}
