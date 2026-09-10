// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get antiTamperingHologram => 'छेडछाड विरोधी आणि होलोग्राम पडताळणी';

  @override
  String get extractedOcrFields => 'काढलेले OCR फील्ड';

  @override
  String get cameraInitializationFailed => 'कॅमेरा सुरू करण्यात अयशस्वी';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get auditHistory => 'ऑडिट इतिहास';

  @override
  String get searchHistoryHint => 'इतिहास शोधा';

  @override
  String get allStatuses => 'सर्व स्थिती';

  @override
  String get passed => 'मंजूर';

  @override
  String get review => 'पुनरावलोकन';

  @override
  String get rejected => 'नाकारले';

  @override
  String get noMatchingRecords => 'कोणतीही जुळणी सापडली नाही';

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
