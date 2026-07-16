import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/localization/app_language.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _loadPreferences();
  }

  static const String _notificationsPreferenceKey =
      'settings_notifications_enabled';
  static const String _languagePreferenceKey = 'selected_language';
  static const String _profileVisibilityKey = 'privacy_profile_public';
  static const String _showPhoneKey = 'privacy_show_phone';
  static const String _showEmailKey = 'privacy_show_email';
  static const String _allowDirectMessagesKey = 'privacy_allow_messages';
  static const String _showActivityStatusKey = 'privacy_show_activity_status';

  static const List<String> supportedLanguages = <String>[
    'English',
    'Telugu',
    'Hindi',
    'Tamil',
    'Malayalam',
    'Kannada',
    'Marathi',
    'Gujarati',
    'Punjabi',
    'Bengali',
  ];

  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  bool _profilePublic = true;
  bool _showPhone = false;
  bool _showEmail = false;
  bool _allowDirectMessages = true;
  bool _showActivityStatus = true;

  bool get notificationsEnabled => _notificationsEnabled;
  String get selectedLanguage => _selectedLanguage;
  bool get profilePublic => _profilePublic;
  bool get showPhone => _showPhone;
  bool get showEmail => _showEmail;
  bool get allowDirectMessages => _allowDirectMessages;
  bool get showActivityStatus => _showActivityStatus;

  Future<void> _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notificationsPreferenceKey) ?? true;
    _profilePublic = prefs.getBool(_profileVisibilityKey) ?? true;
    _showPhone = prefs.getBool(_showPhoneKey) ?? false;
    _showEmail = prefs.getBool(_showEmailKey) ?? false;
    _allowDirectMessages = prefs.getBool(_allowDirectMessagesKey) ?? true;
    _showActivityStatus = prefs.getBool(_showActivityStatusKey) ?? true;

    final String language =
        prefs.getString(_languagePreferenceKey) ??
        AppLanguage.instance.language;
    _selectedLanguage = supportedLanguages.contains(language)
        ? language
        : 'English';

    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsPreferenceKey, _notificationsEnabled);
  }

  Future<void> toggleProfilePublic() async {
    _profilePublic = !_profilePublic;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_profileVisibilityKey, _profilePublic);
  }

  Future<void> toggleShowPhone() async {
    _showPhone = !_showPhone;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showPhoneKey, _showPhone);
  }

  Future<void> toggleShowEmail() async {
    _showEmail = !_showEmail;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showEmailKey, _showEmail);
  }

  Future<void> toggleAllowDirectMessages() async {
    _allowDirectMessages = !_allowDirectMessages;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_allowDirectMessagesKey, _allowDirectMessages);
  }

  Future<void> toggleShowActivityStatus() async {
    _showActivityStatus = !_showActivityStatus;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showActivityStatusKey, _showActivityStatus);
  }

  Future<void> changeLanguage(String language) async {
    if (!supportedLanguages.contains(language) ||
        language == _selectedLanguage) {
      return;
    }

    _selectedLanguage = language;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePreferenceKey, language);
    await AppLanguage.instance.setLanguage(language);
  }
}
