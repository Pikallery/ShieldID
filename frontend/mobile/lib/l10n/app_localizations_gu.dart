// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get antiTamperingHologram => 'સુરક્ષા અને હોલોગ્રામ ચકાસણી';

  @override
  String get extractedOcrFields => 'કાઢવામાં આવેલી વિગતો';

  @override
  String get cameraInitializationFailed => 'કેમેરા શરૂ કરવામાં નિષ્ફળ';

  @override
  String get retry => 'ફરી પ્રયાસ કરો';

  @override
  String get auditHistory => 'ઓડિટ ઇતિહાસ';

  @override
  String get searchHistoryHint => 'ઇતિહાસ શોધો';

  @override
  String get allStatuses => 'તમામ સ્થિતિઓ';

  @override
  String get passed => 'પાસ';

  @override
  String get review => 'પુનરાવર્તન';

  @override
  String get rejected => 'અસ્વીકૃત';

  @override
  String get noMatchingRecords => 'કોઈ રેકોર્ડ મળ્યો નથી';

  @override
  String get screeningTab => 'ચકાસણી';

  @override
  String get auditHistoryTab => 'ઓડિટ ઇતિહાસ';

  @override
  String get settingsTab => 'સેટિંગ્સ';

  @override
  String get startScreening => 'દસ્તાવેજ ચકાસણી શરૂ કરો';

  @override
  String get systemConfiguration => 'સિસ્ટમ રૂપરેખાંકન';

  @override
  String get appearancePreferences => 'દેખાવ અને પસંદગીઓ';

  @override
  String get darkTheme => 'ડાર્ક થીમ';

  @override
  String get darkThemeSubtitle => 'ડાર્ક મોડ સક્રિય છે';

  @override
  String get lightThemeSubtitle => 'લાઇટ મોડ સક્રિય છે';

  @override
  String get interfaceLanguage => 'ભાષા';

  @override
  String get chooseLocale => 'તમારી પસંદગીની ભાષા પસંદ કરો';

  @override
  String get backendService => 'બેકએન્ડ એઆઈ સેવા';

  @override
  String get selectDocumentType => 'દસ્તાવેજનો પ્રકાર પસંદ કરો';

  @override
  String get nationalIdAadhaar => 'આધાર કાર્ડ';

  @override
  String get panCard => 'પાન કાર્ડ';

  @override
  String get drivingLicense => 'ડ્રાઇવિંગ લાયસન્સ';

  @override
  String get passport => 'પાસપોર્ટ';

  @override
  String get voterId => 'મતદાર કાર્ડ';

  @override
  String get verifiedCardholder => 'પ્રમાણિત કાર્ડધારક';

  @override
  String get unverifiedCardholder => 'અજ્ઞાત કાર્ડધારક';

  @override
  String get documentVerified => 'સાચો દસ્તાવેજ પ્રમાણિત';

  @override
  String get documentUnverified => 'દસ્તાવેજ વાંચી શકાયો નથી';

  @override
  String get editDetailsManually => 'વિગતો જાતે દાખલ કરો';

  @override
  String get crossRegisteredDocs => 'ડિજીલોકરમાં નોંધાયેલા દસ્તાવેજો';

  @override
  String get proceedToBiometrics => 'બાયોમેટ્રિક્સ તરફ આગળ વધો';

  @override
  String get reScanDocument => 'ફરીથી સ્કેન કરો';

  @override
  String verdict(String status) {
    return '$status';
  }
}
