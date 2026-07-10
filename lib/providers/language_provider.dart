import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/localization/app_localizations.dart';

class LanguageProvider extends ChangeNotifier {
  static const String languagePreferenceKey = 'selected_language';

  String _selectedLanguage = AppLocalizations.fallbackLanguage;

  String get selectedLanguage => _selectedLanguage;
  List<String> get supportedLanguages => AppLocalizations.supportedLanguages;
  String get selectedLanguageLabel =>
      AppLocalizations.languageLabel(_selectedLanguage);

  String t(String key) => AppLocalizations.text(_selectedLanguage, key);
  String languageLabel(String language) =>
      AppLocalizations.languageLabel(language);

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
