import 'package:flutter/material.dart';

import '../core/theme/app_theme_manager.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    AppThemeManager.instance.addListener(_onThemeChanged);
    AppThemeManager.instance.load();
  }

  bool get isDark => AppThemeManager.instance.isDarkMode;

  ThemeMode get themeMode => AppThemeManager.instance.themeMode;

  void _onThemeChanged() {
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    await AppThemeManager.instance.setThemeMode(
      value ? ThemeMode.dark : ThemeMode.light,
    );
  }

  @override
  void dispose() {
    AppThemeManager.instance.removeListener(_onThemeChanged);
    super.dispose();
  }
}
