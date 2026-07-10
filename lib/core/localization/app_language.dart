import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  AppLanguage._();

  static final AppLanguage instance = AppLanguage._();

  String _language = 'English';

  String get language => _language;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString('selected_language') ?? 'English';
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (_language == language) {
      return;
    }

    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);
    notifyListeners();
  }
}
