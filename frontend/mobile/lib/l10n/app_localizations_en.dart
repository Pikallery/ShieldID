// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get antiTamperingHologram => 'Anti-tampering and hologram check';

  @override
  String get extractedOcrFields => 'Extracted OCR fields';

  @override
  String get cameraInitializationFailed => 'Camera initialization failed';

  @override
  String get retry => 'Retry';

  @override
  String get auditHistory => 'Audit history';

  @override
  String get searchHistoryHint => 'Search history';

  @override
  String get allStatuses => 'All statuses';

  @override
  String get passed => 'Passed';

  @override
  String get review => 'Review';

  @override
  String get rejected => 'Rejected';

  @override
  String get noMatchingRecords => 'No matching records';

  @override
  String get screeningTab => 'Screening';

  @override
  String get auditHistoryTab => 'Audit History';

  @override
  String get settingsTab => 'Settings';

  @override
  String get startScreening => 'Start Document Screening';

  @override
  String get systemConfiguration => 'System Configuration';

  @override
  String get appearancePreferences => 'Appearance & Preferences';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get darkThemeSubtitle => 'Sleek dark interface active';

  @override
  String get lightThemeSubtitle => 'High-contrast light interface active';

  @override
  String get interfaceLanguage => 'Interface Language';

  @override
  String get chooseLocale => 'Choose your preferred locale';

  @override
  String get backendService => 'Backend AI Service';

  @override
  String get selectDocumentType => 'Select Document Type';

  @override
  String get nationalIdAadhaar => 'Aadhaar Card';

  @override
  String get panCard => 'PAN Card';

  @override
  String get drivingLicense => 'Driving License';

  @override
  String get passport => 'Passport';

  @override
  String get voterId => 'Voter ID';

  @override
  String get verifiedCardholder => 'Authenticated Cardholder';

  @override
  String get unverifiedCardholder => 'Unidentified Cardholder';

  @override
  String get documentVerified => 'GENUINE DOCUMENT VERIFIED';

  @override
  String get documentUnverified => 'DOCUMENT UNVERIFIED / UNREADABLE';

  @override
  String get editDetailsManually => 'Edit / Enter Details Manually';

  @override
  String get crossRegisteredDocs => 'Cross-Registered Documents in DigiLocker';

  @override
  String get proceedToBiometrics => 'Proceed to Biometrics';

  @override
  String get reScanDocument => 'Re-Scan Document';

  @override
  String verdict(String status) {
    return '$status';
  }
}
