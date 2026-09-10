// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get antiTamperingHologram => 'பாதுகாப்பு சரிபார்ப்பு';

  @override
  String get extractedOcrFields => 'பிரித்தெடுக்கப்பட்ட விவரங்கள்';

  @override
  String get cameraInitializationFailed => 'கேமரா தொடங்குவதில் தோல்வி';

  @override
  String get retry => 'மீண்டும் முயற்சி செய்';

  @override
  String get auditHistory => 'தணிக்கை வரலாறு';

  @override
  String get searchHistoryHint => 'வரலாற்றைத் தேடுக';

  @override
  String get allStatuses => 'அனைத்து நிலைகளும்';

  @override
  String get passed => 'வெற்றி';

  @override
  String get review => 'மறுஆய்வு';

  @override
  String get rejected => 'நிராகரிக்கப்பட்டது';

  @override
  String get noMatchingRecords => 'பதிவுகள் எதுவும் கிடைக்கவில்லை';

  @override
  String get screeningTab => 'சரிபார்ப்பு';

  @override
  String get auditHistoryTab => 'தணிக்கை வரலாறு';

  @override
  String get settingsTab => 'அமைப்புகள்';

  @override
  String get startScreening => 'ஆவண சரிபார்ப்பைத் தொடங்கு';

  @override
  String get systemConfiguration => 'அமைப்பு கட்டமைப்பு';

  @override
  String get appearancePreferences => 'தோற்றம் மற்றும் விருப்பத்தேர்வுகள்';

  @override
  String get darkTheme => 'டார்க் தீம்';

  @override
  String get darkThemeSubtitle => 'டார்க் பயன்முறை செயலில் உள்ளது';

  @override
  String get lightThemeSubtitle => 'லைட் பயன்முறை செயலில் உள்ளது';

  @override
  String get interfaceLanguage => 'மொழி';

  @override
  String get chooseLocale => 'விருப்பமான மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get backendService => 'பின்புல AI சேவை';

  @override
  String get selectDocumentType => 'ஆவண வகையைத் தேர்ந்தெடுக்கவும்';

  @override
  String get nationalIdAadhaar => 'ஆதார் அட்டை';

  @override
  String get panCard => 'பான் அட்டை';

  @override
  String get drivingLicense => 'ஓட்டுநர் உரிமம்';

  @override
  String get passport => 'பாஸ்போர்ட்';

  @override
  String get voterId => 'வாக்காளர் அடையாள அட்டை';

  @override
  String get verifiedCardholder => 'சரிபார்க்கப்பட்ட அட்டைதாரர்';

  @override
  String get unverifiedCardholder => 'அடையாளம் காணப்படாத அட்டைதாரர்';

  @override
  String get documentVerified => 'உண்மையான ஆவணம் சரிபார்க்கப்பட்டது';

  @override
  String get documentUnverified => 'ஆவணம் படிக்க முடியவில்லை';

  @override
  String get editDetailsManually => 'விவரங்களை உள்ளிடவும்';

  @override
  String get crossRegisteredDocs => 'டிஜிலாக்கரில் உள்ள ஆவணங்கள்';

  @override
  String get proceedToBiometrics => 'பயோமெட்ரிக்ஸுக்கு செல்லவும்';

  @override
  String get reScanDocument => 'மீண்டும் ஸ்கேன் செய்';

  @override
  String verdict(String status) {
    return '$status';
  }
}
