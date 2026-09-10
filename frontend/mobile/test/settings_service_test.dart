import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shield_id_mobile/constants/theme.dart';
import 'package:shield_id_mobile/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService Unit & Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes with default dark theme and english language', () async {
      final service = await SettingsService.init();

      expect(service.themeMode, ThemeMode.dark);
      expect(service.isDarkMode, isTrue);
      expect(service.language, 'en');
      expect(service.currentLanguageLabel, 'English (India)');
    });

    test('Toggling theme updates state, notifies listeners, and persists',
        () async {
      final service = await SettingsService.init();
      bool listenerNotified = false;
      service.addListener(() => listenerNotified = true);

      // Switch to light mode
      await service.toggleTheme(false);
      expect(service.themeMode, ThemeMode.light);
      expect(service.isDarkMode, isFalse);
      expect(listenerNotified, isTrue);

      // Verify persistence in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('shield_id_theme_mode'), 'light');

      // Switch back to dark mode
      listenerNotified = false;
      await service.toggleTheme(true);
      expect(service.themeMode, ThemeMode.dark);
      expect(service.isDarkMode, isTrue);
      expect(listenerNotified, isTrue);
      expect(prefs.getString('shield_id_theme_mode'), 'dark');
    });

    test('Changing language updates state, notifies listeners, and persists',
        () async {
      final service = await SettingsService.init();
      bool listenerNotified = false;
      service.addListener(() => listenerNotified = true);

      await service.setLanguage('hi');
      expect(service.language, 'hi');
      expect(service.currentLanguageLabel, 'हिन्दी (Hindi)');
      expect(listenerNotified, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('shield_id_language'), 'hi');
    });

    test('Pre-existing preferences are restored upon initialization', () async {
      SharedPreferences.setMockInitialValues({
        'shield_id_theme_mode': 'light',
        'shield_id_language': 'or',
      });

      final service = await SettingsService.init();
      expect(service.themeMode, ThemeMode.light);
      expect(service.isDarkMode, isFalse);
      expect(service.language, 'or');
      expect(service.currentLanguageLabel, 'ଓଡ଼ିଆ (Odia)');
    });
  });

  group('MaterialApp ThemeMode Reactivity Test', () {
    testWidgets('MaterialApp themeMode reacts to SettingsService change',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final service = await SettingsService.init();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: service,
          child: Consumer<SettingsService>(
            builder: (context, settings, _) {
              return MaterialApp(
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: settings.themeMode,
                home: Scaffold(
                  body: Text(
                    settings.isDarkMode ? 'Dark UI' : 'Light UI',
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Dark UI'), findsOneWidget);
      MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);

      // Toggle to light mode
      await service.toggleTheme(false);
      await tester.pumpAndSettle();

      expect(find.text('Light UI'), findsOneWidget);
      app = tester.widget(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.light);
    });
  });
}
