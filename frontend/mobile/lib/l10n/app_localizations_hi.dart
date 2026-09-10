// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get antiTamperingHologram => 'होलोग्राम और सुरक्षा जांच';

  @override
  String get extractedOcrFields => 'दस्तावेज़ से निकाला गया विवरण';

  @override
  String get cameraInitializationFailed => 'कैमरा शुरू करने में विफल';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get auditHistory => 'सत्यापन इतिहास';

  @override
  String get searchHistoryHint => 'इतिहास खोजें';

  @override
  String get allStatuses => 'सभी स्थितियां';

  @override
  String get passed => 'सफल';

  @override
  String get review => 'समीक्षा';

  @override
  String get rejected => 'अस्वीकृत';

  @override
  String get noMatchingRecords => 'कोई मेल नहीं मिला';

  @override
  String get screeningTab => 'सत्यापन';

  @override
  String get auditHistoryTab => 'सत्यापन इतिहास';

  @override
  String get settingsTab => 'सेटिंग्स';

  @override
  String get startScreening => 'दस्तावेज़ सत्यापन शुरू करें';

  @override
  String get systemConfiguration => 'सिस्टम सेटिंग्स';

  @override
  String get appearancePreferences => 'दिखावट और प्राथमिकताएं';

  @override
  String get darkTheme => 'डार्क थीम';

  @override
  String get darkThemeSubtitle => 'डार्क मोड सक्रिय है';

  @override
  String get lightThemeSubtitle => 'लाइट मोड सक्रिय है';

  @override
  String get interfaceLanguage => 'भाषा';

  @override
  String get chooseLocale => 'अपनी पसंदीदा भाषा चुनें';

  @override
  String get backendService => 'बैकएंड एआई सेवा';

  @override
  String get selectDocumentType => 'दस्तावेज़ का प्रकार चुनें';

  @override
  String get nationalIdAadhaar => 'आधार कार्ड';

  @override
  String get panCard => 'पैन कार्ड';

  @override
  String get drivingLicense => 'ड्राइविंग लाइसेंस';

  @override
  String get passport => 'पासपोर्ट';

  @override
  String get voterId => 'वोटर आईडी';

  @override
  String get verifiedCardholder => 'प्रमाणित दस्तावेज़ धारक';

  @override
  String get unverifiedCardholder => 'अज्ञात दस्तावेज़ धारक';

  @override
  String get documentVerified => 'असली दस्तावेज़ प्रमाणित';

  @override
  String get documentUnverified => 'दस्तावेज़ अपठनीय / अप्रमाणित';

  @override
  String get editDetailsManually => 'विवरण स्वयं दर्ज करें';

  @override
  String get crossRegisteredDocs => 'डिजिलॉकर में पंजीकृत दस्तावेज़';

  @override
  String get proceedToBiometrics => 'बायोमेट्रिक्स के लिए आगे बढ़ें';

  @override
  String get reScanDocument => 'दस्तावेज़ पुनः स्कैन करें';

  @override
  String verdict(String status) {
    return '$status';
  }
}
