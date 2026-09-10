// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get antiTamperingHologram => 'ਸੁਰੱਖਿਆ ਜਾਂਚ';

  @override
  String get extractedOcrFields => 'ਪ੍ਰਾਪਤ ਕੀਤੇ ਵੇਰਵੇ';

  @override
  String get cameraInitializationFailed => 'ਕੈਮਰਾ ਚਾਲੂ ਕਰਨ ਵਿੱਚ ਅਸਫਲ';

  @override
  String get retry => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get auditHistory => 'ਆਡਿਟ ਇਤਿਹਾਸ';

  @override
  String get searchHistoryHint => 'ਇਤਿਹਾਸ ਖੋਜੋ';

  @override
  String get allStatuses => 'ਸਾਰੀਆਂ ਸਥਿਤੀਆਂ';

  @override
  String get passed => 'ਪਾਸ';

  @override
  String get review => 'ਸਮੀਖਿਆ';

  @override
  String get rejected => 'ਰੱਦ';

  @override
  String get noMatchingRecords => 'ਕੋਈ ਰਿਕਾਰਡ ਨਹੀਂ ਮਿਲਿਆ';

  @override
  String get screeningTab => 'ਸਕ੍ਰੀਨਿੰਗ';

  @override
  String get auditHistoryTab => 'ਆਡਿਟ ਇਤਿਹਾਸ';

  @override
  String get settingsTab => 'ਸੈਟਿੰਗਾਂ';

  @override
  String get startScreening => 'ਦਸਤਾਵੇਜ਼ ਜਾਂਚ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get systemConfiguration => 'ਸਿਸਟਮ ਸੰਰਚਨਾ';

  @override
  String get appearancePreferences => 'ਦਿੱਖ ਅਤੇ ਤਰਜੀਹਾਂ';

  @override
  String get darkTheme => 'ਡਾਰਕ ਥੀਮ';

  @override
  String get darkThemeSubtitle => 'ਡਾਰਕ ਮੋਡ ਸਰਗਰਮ ਹੈ';

  @override
  String get lightThemeSubtitle => 'ਲਾਈਟ ਮੋਡ ਸਰਗਰਮ ਹੈ';

  @override
  String get interfaceLanguage => 'ਭਾਸ਼ਾ';

  @override
  String get chooseLocale => 'ਆਪਣੀ ਪਸੰਦੀਦਾ ਭਾਸ਼ਾ ਚੁਣੋ';

  @override
  String get backendService => 'ਬੈਕਐਂਡ ਏਆਈ ਸੇਵਾ';

  @override
  String get selectDocumentType => 'ਦਸਤਾਵੇਜ਼ ਦੀ ਕਿਸਮ ਚੁਣੋ';

  @override
  String get nationalIdAadhaar => 'ਆਧਾਰ ਕਾਰਡ';

  @override
  String get panCard => 'ਪੈਨ ਕਾਰਡ';

  @override
  String get drivingLicense => 'ਡ੍ਰਾਈਵਿੰਗ ਲਾਇਸੈਂਸ';

  @override
  String get passport => 'ਪਾਸਪੋਰਟ';

  @override
  String get voterId => 'ਵੋਟਰ ਆਈਡੀ';

  @override
  String get verifiedCardholder => 'ਪ੍ਰਮਾਣਿਤ ਕਾਰਡਧਾਰਕ';

  @override
  String get unverifiedCardholder => 'ਅਣਜਾਣ ਕਾਰਡਧਾਰਕ';

  @override
  String get documentVerified => 'ਅਸਲ ਦਸਤਾਵੇਜ਼ ਪ੍ਰਮਾਣਿਤ';

  @override
  String get documentUnverified => 'ਦਸਤਾਵੇਜ਼ ਪੜ੍ਹਿਆ ਨਹੀਂ ਜਾ ਸਕਿਆ';

  @override
  String get editDetailsManually => 'ਵੇਰਵੇ ਖੁਦ ਦਰਜ ਕਰੋ';

  @override
  String get crossRegisteredDocs => 'ਡਿਜੀਲੌਕਰ ਵਿੱਚ ਦਸਤਾਵੇਜ਼';

  @override
  String get proceedToBiometrics => 'ਬਾਇਓਮੈਟ੍ਰਿਕਸ ਲਈ ਅੱਗੇ ਵਧੋ';

  @override
  String get reScanDocument => 'ਦੁਬਾਰਾ ਸਕੈਨ ਕਰੋ';

  @override
  String verdict(String status) {
    return '$status';
  }
}
