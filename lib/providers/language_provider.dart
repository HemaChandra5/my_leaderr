import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/localization/app_localizations.dart';

class LanguageProvider extends ChangeNotifier {
  static const String languagePreferenceKey = 'selected_language';
  static const List<String> _supportedLanguages = <String>['en'];
  static const Map<String, String> _languageLabels = <String, String>{
    'en': 'English',
  };

  String _selectedLanguage = _supportedLanguages.first;

  String get selectedLanguage => _selectedLanguage;
  List<String> get supportedLanguages => _supportedLanguages;
    String get selectedLanguageLabel =>
      _languageLabels[_selectedLanguage] ?? _selectedLanguage.toUpperCase();

  String t(String key) {
    final dynamic localizations = AppLocalizations;

    try {
      return localizations.text(_selectedLanguage, key) as String;
    } catch (_) {
      try {
        return localizations.translate(_selectedLanguage, key) as String;
      } catch (_) {
        return key;
      }
    }
  }
    String languageLabel(String language) =>
      _languageLabels[language] ?? language.toUpperCase();

  Future<void> loadSavedLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString(languagePreferenceKey);
    if (saved == null || !supportedLanguages.contains(saved)) {
      return;
    }

    _selectedLanguage = saved;
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (!supportedLanguages.contains(language) ||
        language == _selectedLanguage) {
      return;
    }

    _selectedLanguage = language;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(languagePreferenceKey, language);
  }
}
