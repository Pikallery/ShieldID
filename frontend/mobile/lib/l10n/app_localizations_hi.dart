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
  String get identityScreeningOs => 'पहचान एवं स्क्रीनिंग ओएस • सक्रिय';

  @override
  String get realTimeScreening => 'रीयल-टाइम स्क्रीनिंग';

  @override
  String get heroTitle => 'एआई-संचालित पहचान एवं दस्तावेज़ स्क्रीनिंग';

  @override
  String get heroSubtitle =>
      'त्वरित बहुस्तरीय न्यूरल स्कैन: ओसीआर निष्कर्षण, छेड़छाड़ विरोधी विश्लेषण, बायोमेट्रिक फेशियल मैचिंग और धोखाधड़ी रोकथाम।';

  @override
  String get startNewScreening => 'नई स्क्रीनिंग शुरू करें';

  @override
  String get systemEngine => 'सिस्टम इंजन';

  @override
  String get screeningPipelines => 'स्क्रीनिंग पाइपलाइन';

  @override
  String get pipelinesActive => '4 सक्रिय';

  @override
  String get aiModelWeights => 'एआई मॉडल वेट्स';

  @override
  String get weightsVersion => 'v2.4 न्यूरल कोर';

  @override
  String get antiTamperShield => 'एंटी-टैम्पर शील्ड';

  @override
  String get shieldEnabled => 'लाइव सक्षम';

  @override
  String get recentVerifications => 'हालिया सत्यापन';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get noScreeningsRecorded =>
      'अभी तक कोई स्क्रीनिंग रिकॉर्ड नहीं हुई है। ऊपर नई स्क्रीनिंग शुरू करें पर टैप करें।';

  @override
  String get selectDocument => 'दस्तावेज़ चुनें';

  @override
  String get issuingCountry => 'जारीकर्ता देश / अधिकार क्षेत्र';

  @override
  String get republicOfIndia => 'भारत गणराज्य (Republic of India)';

  @override
  String get activeRegistry => 'सक्रिय';

  @override
  String get registryDetails => 'UIDAI • ICAO IND • MoRTH • आयकर विभाग';

  @override
  String get supportedIdentityDocuments => 'समर्थित पहचान दस्तावेज़';

  @override
  String get indianPassport => 'भारतीय पासपोर्ट (ICAO 9303)';

  @override
  String get indianPassportDesc => 'MRZ कोड वाला फोटो पेज';

  @override
  String get aadhaarCard => 'आधार कार्ड (UIDAI)';

  @override
  String get aadhaarCardDesc => 'आगे और पीछे दोनों तरफ का कैप्चर आवश्यक';

  @override
  String get drivingLicense => 'ड्राइविंग लाइसेंस (MoRTH)';

  @override
  String get drivingLicenseDesc => 'आगे और पीछे दोनों तरफ का कैप्चर आवश्यक';

  @override
  String get panCard => 'पैन कार्ड (आयकर विभाग)';

  @override
  String get panCardDesc => 'फोटो और क्यूआर कोड सत्यापन';

  @override
  String get voterId => 'वोटर आईडी (ECI)';

  @override
  String get voterIdDesc => 'EPIC मानक सत्यापन';

  @override
  String get continueToScan => 'दस्तावेज़ स्कैन के लिए आगे बढ़ें';

  @override
  String get documentInfoTitle => 'दस्तावेज़ एवं पहचान जानकारी';

  @override
  String get genuineVerifiedDoc => 'प्रमाणित एवं सत्यापित दस्तावेज़';

  @override
  String get unverifiedDoc => 'दस्तावेज़ असत्यापित / पढ़ने योग्य नहीं';

  @override
  String get genuineSubtitle =>
      'संरचना एवं चेकसम सत्यापित • डिजिलॉकर जारीकर्ता एपीआई v1.13 प्रमाणित';

  @override
  String get unverifiedSubtitle =>
      'केंद्रीय रजिस्ट्री मानकों के अनुसार दस्तावेज़ विवरण प्रमाणित नहीं हो सके';

  @override
  String get genuineBadge => 'प्रमाणित';

  @override
  String get flaggedBadge => 'संदिग्ध';

  @override
  String get documentType => 'दस्तावेज़ का प्रकार';

  @override
  String get dateOfBirth => 'जन्म तिथि';

  @override
  String get gender => 'लिंग';

  @override
  String get digiLockerId => 'डिजिलॉकर आईडी';

  @override
  String get cryptographicSignature => 'क्रिप्टोग्राफिक हस्ताक्षर';

  @override
  String get validGovtRoot => 'वैध (सरकारी रूट सीए)';

  @override
  String get invalidSignature => 'असत्यापित / अनुपलब्ध';

  @override
  String get onFileIssuer => 'जारीकर्ता के रिकॉर्ड में उपलब्ध';

  @override
  String get specifiedInRegistry => 'रजिस्ट्री में निर्दिष्ट';

  @override
  String get crossRegisteredDigiLocker =>
      'डिजिलॉकर में क्रॉस-पंजीकृत दस्तावेज़';

  @override
  String get crossRegisteredSubtitle =>
      'इस प्रमाणित कार्डधारक के लिए आधिकारिक सरकारी रजिस्ट्रियां क्रॉस-रेफरेंस की गईं:';

  @override
  String get verifiedRatio => '3/3 सत्यापित';

  @override
  String get matchBadge => 'सत्यापित';

  @override
  String get confirmEditManually =>
      'विवरण मैन्युअल रूप से पुष्टि / संपादित करें';

  @override
  String get proceedToBiometric => 'बायोमेट्रिक सेल्फी के लिए आगे बढ़ें';

  @override
  String get antiTamperingHologram => 'छेड़छाड़ विरोधी और होलोग्राम जांच';

  @override
  String get biometricLiveness => 'बायोमेट्रिक लाइवनेस और फेस मैच';

  @override
  String get extractedOcrFields => 'निकाले गए ओसीआर फ़ील्ड';

  @override
  String get cameraInitializationFailed => 'कैमरा शुरू करने में विफल';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get auditHistory => 'ऑडिट इतिहास';

  @override
  String get searchHistoryHint => 'इतिहास खोजें...';

  @override
  String get allStatuses => 'सभी स्थितियां';

  @override
  String get passed => 'उत्तीर्ण';

  @override
  String get review => 'समीक्षा';

  @override
  String get rejected => 'अस्वीकृत';

  @override
  String get noMatchingRecords => 'कोई मिलान रिकॉर्ड नहीं मिला';

  @override
  String get screeningTab => 'स्क्रीनिंग';

  @override
  String get auditHistoryTab => 'ऑडिट इतिहास';

  @override
  String get settingsTab => 'सेटिंग्स';

  @override
  String get systemConfiguration => 'सिस्टम कॉन्फ़िगरेशन';

  @override
  String get appearancePreferences => 'दिखावट और प्राथमिकताएं';

  @override
  String get darkTheme => 'डार्क थीम';

  @override
  String get darkThemeSubtitle => 'आधुनिक डार्क इंटरफ़ेस सक्रिय';

  @override
  String get lightThemeSubtitle => 'उच्च-विपरीत लाइट इंटरफ़ेस सक्रिय';

  @override
  String get interfaceLanguage => 'इंटरफ़ेस भाषा';

  @override
  String get chooseLocale => 'अपनी पसंदीदा भाषा चुनें';

  @override
  String get backendService => 'बैकएंड एआई सेवा';

  @override
  String get metricPassRate => 'पास दर';

  @override
  String get metricFraudBlocked => 'धोखाधड़ी रोकी';

  @override
  String get metricAvgLatency => 'औसत विलंब';

  @override
  String get metricTotalScreened => 'कुल स्क्रीन';

  @override
  String get applicantDocument => 'आवेदक दस्तावेज़';

  @override
  String verdict(String status) {
    return '$status';
  }
}
