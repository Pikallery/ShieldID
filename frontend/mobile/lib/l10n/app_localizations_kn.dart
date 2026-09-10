// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get antiTamperingHologram => 'ಭದ್ರತಾ ಪರಿಶೀಲನೆ';

  @override
  String get extractedOcrFields => 'ಪಡೆದ ವಿವರಗಳು';

  @override
  String get cameraInitializationFailed => 'ಕ್ಯಾಮರಾ ಆರಂಭಿಸಲು ವಿಫಲವಾಗಿದೆ';

  @override
  String get retry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get auditHistory => 'ಆಡಿಟ್ ಇತಿಹಾಸ';

  @override
  String get searchHistoryHint => 'ಇತಿಹಾಸ ಹುಡುಕಿ';

  @override
  String get allStatuses => 'ಎಲ್ಲಾ ಸ್ಥಿತಿಗಳು';

  @override
  String get passed => 'ಉತ್ತೀರ್ಣ';

  @override
  String get review => 'ಮರುಪರಿಶೀಲನೆ';

  @override
  String get rejected => 'ತಿರಸ್ಕರಿಸಲಾಗಿದೆ';

  @override
  String get noMatchingRecords => 'ಯಾವುದೇ ದಾಖಲೆ ಕಂಡುಬಂದಿಲ್ಲ';

  @override
  String get screeningTab => 'ಪರಿಶೀಲನೆ';

  @override
  String get auditHistoryTab => 'ಆಡಿಟ್ ಇತಿಹಾಸ';

  @override
  String get settingsTab => 'ಸೆಟ್ಟಿಂಗ್ಸ್';

  @override
  String get startScreening => 'ದಾಖಲೆ ಪರಿಶೀಲನೆ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get systemConfiguration => 'ವ್ಯವಸ್ಥೆಯ ಕಾನ್ಫಿಗರೇಶನ್';

  @override
  String get appearancePreferences => 'ಗೋಚರತೆ ಮತ್ತು ಆದ್ಯತೆಗಳು';

  @override
  String get darkTheme => 'ಡಾರ್ಕ್ ಥೀಮ್';

  @override
  String get darkThemeSubtitle => 'ಡಾರ್ಕ್ ಮೋಡ್ ಸಕ್ರಿಯವಾಗಿದೆ';

  @override
  String get lightThemeSubtitle => 'ಲೈಟ್ ಮೋಡ್ ಸಕ್ರಿಯವಾಗಿದೆ';

  @override
  String get interfaceLanguage => 'ಭಾಷೆ';

  @override
  String get chooseLocale => 'ನಿಮ್ಮ ಆದ್ಯತೆಯ ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get backendService => 'ಬ್ಯಾಕೆಂಡ್ AI ಸೇವೆ';

  @override
  String get selectDocumentType => 'ದಾಖಲೆಯ ಪ್ರಕಾರವನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get nationalIdAadhaar => 'ಆಧಾರ್ ಕಾರ್ಡ್';

  @override
  String get panCard => 'ಪ್ಯಾನ್ ಕಾರ್ಡ್';

  @override
  String get drivingLicense => 'ಚಾಲನಾ ಪರವಾನಗಿ';

  @override
  String get passport => 'ಪಾಸ್‌ಪೋರ್ಟ್';

  @override
  String get voterId => 'ಮತದಾರರ ಗುರುತಿನ ಚೀಟಿ';

  @override
  String get verifiedCardholder => 'ದೃಢೀಕೃತ ಕಾರ್ಡ್‌ದಾರ';

  @override
  String get unverifiedCardholder => 'ಗುರುತಿಸಲಾಗದ ಕಾರ್ಡ್‌ದಾರ';

  @override
  String get documentVerified => 'ಅಸಲಿ ದಾಖಲೆ ದೃಢೀಕರಿಸಲಾಗಿದೆ';

  @override
  String get documentUnverified => 'ದಾಖಲೆ ಓದಲು ಸಾಧ್ಯವಾಗಿಲ್ಲ';

  @override
  String get editDetailsManually => 'ವಿವರಗಳನ್ನು ನಮೂದಿಸಿ';

  @override
  String get crossRegisteredDocs => 'ಡಿಜಿಲಾಕರ್‌ನಲ್ಲಿ ನೋಂದಾಯಿಸಲಾದ ದಾಖಲೆಗಳು';

  @override
  String get proceedToBiometrics => 'ಬಯೋಮೆಟ್ರಿಕ್ಸ್‌ಗೆ ಮುಂದುವರಿಯಿರಿ';

  @override
  String get reScanDocument => 'ಮತ್ತೆ ಸ್ಕ್ಯಾನ್ ಮಾಡಿ';

  @override
  String verdict(String status) {
    return '$status';
  }
}
