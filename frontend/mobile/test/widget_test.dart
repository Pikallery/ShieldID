// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:shield_id_mobile/main.dart';
import 'package:shield_id_mobile/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('app launches directly to the home screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settingsService = await SettingsService.init();

    await tester.pumpWidget(ShieldIdApp(settingsService: settingsService));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Shield'), findsWidgets);
    expect(find.text('ID'), findsWidgets);
  });
}
