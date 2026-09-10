import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const _themeKey = 'shield_id_theme_mode';
  static const _languageKey = 'shield_id_language';

  static const supportedLanguages = {
    'en': 'English',
    'es': 'Español (Spanish)',
    'fr': 'Français (French)',
  };

  final SharedPreferences _preferences;
  ThemeMode _themeMode;
  String _language;

  SettingsService._(
    this._preferences, {
    required ThemeMode themeMode,
    required String language,
  })  : _themeMode = themeMode,
        _language = language;

  static Future<SettingsService> init() async {
    final preferences = await SharedPreferences.getInstance();
    final theme = preferences.getString(_themeKey) == 'light'
        ? ThemeMode.light
        : ThemeMode.dark;
    final language = supportedLanguages.containsKey(
      preferences.getString(_languageKey),
    )
        ? preferences.getString(_languageKey)!
        : 'en';
    return SettingsService._(
      preferences,
      themeMode: theme,
      language: language,
    );
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get language => _language;
  String get currentLanguageLabel => supportedLanguages[_language]!;

  Future<void> toggleTheme(bool dark) async {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    await _preferences.setString(_themeKey, dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (!supportedLanguages.containsKey(language)) return;
    _language = language;
    await _preferences.setString(_languageKey, language);
    notifyListeners();
  }
}
