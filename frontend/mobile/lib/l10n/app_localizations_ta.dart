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
  String get identityScreeningOs => 'அடையாளம் மற்றும் திரையிடல் OS • செயலில்';

  @override
  String get realTimeScreening => 'நிகழ்நேர திரையிடல்';

  @override
  String get heroTitle => 'AI-இயங்கும் அடையாளம் மற்றும் ஆவண திரையிடல்';

  @override
  String get heroSubtitle =>
      'உடனடி பல அடுக்கு நியூரல் ஸ்கேன்: OCR பிரித்தெடுத்தல், சேதப்படுத்துதல் எதிர்ப்பு பகுப்பாய்வு, பயோமெட்ரிக் முகப் பொருத்தம் மற்றும் மோசடி தடுப்பு.';

  @override
  String get startNewScreening => 'புதிய திரையிடலைத் தொடங்குங்கள்';

  @override
  String get systemEngine => 'கணினி இயந்திரம்';

  @override
  String get screeningPipelines => 'திரையிடல் பைப்லைன்கள்';

  @override
  String get pipelinesActive => '4 செயலில்';

  @override
  String get aiModelWeights => 'AI மாதிரி எடைகள்';

  @override
  String get weightsVersion => 'v2.4 நியூரல் கோர்';

  @override
  String get antiTamperShield => 'சேதப்படுத்துதல் தடுப்பு கேடயம்';

  @override
  String get shieldEnabled => 'நேரலை இயக்கப்பட்டது';

  @override
  String get recentVerifications => 'சமீபத்திய சரிபார்ப்புகள்';

  @override
  String get viewAll => 'அனைத்தையும் பார்க்கவும்';

  @override
  String get noScreeningsRecorded =>
      'இதுவரை எந்த திரையிடலும் பதிவு செய்யப்படவில்லை. மேலே புதிய திரையிடலைத் தொடங்கு என்பதைத் தட்டவும்.';

  @override
  String get selectDocument => 'ஆவணத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get issuingCountry => 'வழங்கும் நாடு / அதிகார வரம்பு';

  @override
  String get republicOfIndia => 'இந்திய குடியரசு (Republic of India)';

  @override
  String get activeRegistry => 'செயலில்';

  @override
  String get registryDetails => 'UIDAI • ICAO IND • MoRTH • வருமான வரித்துறை';

  @override
  String get supportedIdentityDocuments => 'ஆதரிக்கப்படும் அடையாள ஆவணங்கள்';

  @override
  String get indianPassport => 'இந்திய கடவுச்சீட்டு (ICAO 9303)';

  @override
  String get indianPassportDesc => 'MRZ குறியீட்டுடன் கூடிய புகைப்படப் பக்கம்';

  @override
  String get aadhaarCard => 'ஆதார் அட்டை (UIDAI)';

  @override
  String get aadhaarCardDesc => 'முன் மற்றும் பின் இருபுறமும் புகைப்படம் தேவை';

  @override
  String get drivingLicense => 'ஓட்டுநர் உரிமம் (MoRTH)';

  @override
  String get drivingLicenseDesc =>
      'முன் மற்றும் பின் இருபுறமும் புகைப்படம் தேவை';

  @override
  String get panCard => 'பான் கார்டு (வருமான வரித்துறை)';

  @override
  String get panCardDesc => 'புகைப்படம் மற்றும் QR குறியீடு சரிபார்ப்பு';

  @override
  String get voterId => 'வாக்காளர் அடையாள அட்டை (ECI)';

  @override
  String get voterIdDesc => 'EPIC தரநிலை சரிபார்ப்பு';

  @override
  String get continueToScan => 'ஆவண ஸ்கேனுக்கு தொடரவும்';

  @override
  String get documentInfoTitle => 'ஆவணம் மற்றும் அடையாள தகவல்';

  @override
  String get genuineVerifiedDoc => 'அசல் மற்றும் சரிபார்க்கப்பட்ட ஆவணம்';

  @override
  String get unverifiedDoc => 'ஆவணம் சரிபார்க்கப்படவில்லை / படிக்க முடியவில்லை';

  @override
  String get genuineSubtitle =>
      'கட்டமைப்பு மற்றும் செக்சம் சரிபார்க்கப்பட்டது • டிஜிலாக்கர் வழங்குநர் API v1.13 அங்கீகரிக்கப்பட்டது';

  @override
  String get unverifiedSubtitle =>
      'மத்திய பதிவேட்டுத் தரங்களின்படி ஆவண விவரங்களை அங்கீகரிக்க முடியவில்லை';

  @override
  String get genuineBadge => 'அசல்';

  @override
  String get flaggedBadge => 'குறியிடப்பட்டது';

  @override
  String get documentType => 'ஆவண வகை';

  @override
  String get dateOfBirth => 'பிறந்த தேதி';

  @override
  String get gender => 'பாலினம்';

  @override
  String get digiLockerId => 'டிஜிலாக்கர் ஐடி';

  @override
  String get cryptographicSignature => 'கிரிப்டோகிராஃபிக் கையொப்பம்';

  @override
  String get validGovtRoot => 'செல்லுபடியாகும் (அரசு ரூட் CA)';

  @override
  String get invalidSignature => 'சரிபார்க்கப்படவில்லை / இல்லை';

  @override
  String get onFileIssuer => 'வழங்குநரின் கோப்பில் உள்ளது';

  @override
  String get specifiedInRegistry => 'பதிவேட்டில் குறிப்பிடப்பட்டுள்ளது';

  @override
  String get crossRegisteredDigiLocker =>
      'டிஜிலாக்கரில் குறுக்கு பதிவு செய்யப்பட்ட ஆவணங்கள்';

  @override
  String get crossRegisteredSubtitle =>
      'இந்த அசல் அட்டைதாரருக்கு அதிகாரப்பூர்வ அரசு பதிவேடுகள் குறுக்கு-குறிப்பு செய்யப்பட்டன:';

  @override
  String get verifiedRatio => '3/3 சரிபார்க்கப்பட்டது';

  @override
  String get matchBadge => 'பொருத்தம்';

  @override
  String get confirmEditManually =>
      'விவரங்களை கைமுறையாக உறுதிப்படுத்தவும் / திருத்தவும்';

  @override
  String get proceedToBiometric => 'பயோமெட்ரிக் செல்ஃபிக்கு தொடரவும்';

  @override
  String get antiTamperingHologram =>
      'சேதப்படுத்துதல் எதிர்ப்பு & ஹோலோகிராம் சரிபார்ப்பு';

  @override
  String get biometricLiveness => 'பயோமெட்ரிக் லைவ்னஸ் மற்றும் முக பொருத்தம்';

  @override
  String get extractedOcrFields => 'பிரித்தெடுக்கப்பட்ட OCR புலங்கள்';

  @override
  String get cameraInitializationFailed => 'கேமராவைத் தொடங்குவதில் தோல்வி';

  @override
  String get retry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get auditHistory => 'தணிக்கை வரலாறு';

  @override
  String get searchHistoryHint => 'வரலாற்றைத் தேடுங்கள்...';

  @override
  String get allStatuses => 'அனைத்து நிலைகளும்';

  @override
  String get passed => 'வெற்றி';

  @override
  String get review => 'மறுஆய்வு';

  @override
  String get rejected => 'நிராகரிக்கப்பட்டது';

  @override
  String get noMatchingRecords => 'பொருந்தும் பதிவுகள் எதுவும் கிடைக்கவில்லை';

  @override
  String get screeningTab => 'திரையிடல்';

  @override
  String get auditHistoryTab => 'தணிக்கை வரலாறு';

  @override
  String get settingsTab => 'அமைப்புகள்';

  @override
  String get systemConfiguration => 'கணினி கட்டமைப்பு';

  @override
  String get appearancePreferences => 'தோற்றம் மற்றும் விருப்பத்தேர்வுகள்';

  @override
  String get darkTheme => 'இருண்ட தீம்';

  @override
  String get darkThemeSubtitle => 'நேர்த்தியான இருண்ட இடைமுகம் செயலில்';

  @override
  String get lightThemeSubtitle => 'அதிக மாறுபட்ட வெளிச்ச இடைமுகம் செயலில்';

  @override
  String get interfaceLanguage => 'இடைமுக மொழி';

  @override
  String get chooseLocale => 'உங்கள் விருப்பமான மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get backendService => 'பின்தளத்தில் AI சேவை';

  @override
  String get metricPassRate => 'தேர்ச்சி விகிதம்';

  @override
  String get metricFraudBlocked => 'மோசடி தடுக்கப்பட்டது';

  @override
  String get metricAvgLatency => 'சராசரி தாமதம்';

  @override
  String get metricTotalScreened => 'மொத்தம் திரையிட்டது';

  @override
  String get applicantDocument => 'விண்ணப்பதாரர் ஆவணம்';

  @override
  String verdict(String status) {
    return '$status';
  }
}
