// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get identityScreeningOs => 'পরিচয় ও স্ক্রীনিং ওএস • সক্রিয়';

  @override
  String get realTimeScreening => 'রিয়েল-টাইম স্ক্রীনিং';

  @override
  String get heroTitle => 'এআই-চালিত পরিচয় ও নথি স্ক্রীনিং';

  @override
  String get heroSubtitle =>
      'তাত্ক্ষণিক বহুস্তরীয় নিউরাল স্ক্যান: ওসিআর নিষ্কাশন, বিকৃতি বিরোধী বিশ্লেষণ, বায়োমেট্রিক মুখের মিল এবং জালিয়াতি প্রতিরোধ।';

  @override
  String get startNewScreening => 'নতুন স্ক্রীনিং শুরু করুন';

  @override
  String get systemEngine => 'সিস্টেম ইঞ্জিন';

  @override
  String get screeningPipelines => 'স্ক্রীনিং পাইপলাইন';

  @override
  String get pipelinesActive => '৪টি সক্রিয়';

  @override
  String get aiModelWeights => 'এআই মডেল ওয়েটস';

  @override
  String get weightsVersion => 'v2.4 নিউরাল কোর';

  @override
  String get antiTamperShield => 'অ্যান্টি-ট্যাম্পার শিল্ড';

  @override
  String get shieldEnabled => 'লাইভ সক্রিয়';

  @override
  String get recentVerifications => 'সাম্প্রতিক যাচাইকরণ';

  @override
  String get viewAll => 'সব দেখুন';

  @override
  String get noScreeningsRecorded =>
      'এখনও কোনো স্ক্রীনিং রেকর্ড নেই। উপরে নতুন স্ক্রীনিং শুরু করুন এ আলতো চাপুন।';

  @override
  String get selectDocument => 'নথি নির্বাচন করুন';

  @override
  String get issuingCountry => 'ইস্যুকারী দেশ / এখতিয়ার';

  @override
  String get republicOfIndia => 'ভারত প্রজাতন্ত্র (Republic of India)';

  @override
  String get activeRegistry => 'সক্রিয়';

  @override
  String get registryDetails => 'UIDAI • ICAO IND • MoRTH • আয়কর বিভাগ';

  @override
  String get supportedIdentityDocuments => 'সমর্থিত পরিচয় নথি';

  @override
  String get indianPassport => 'ভারতীয় পাসপোর্ট (ICAO 9303)';

  @override
  String get indianPassportDesc => 'MRZ কোড সহ ফটো পৃষ্ঠা';

  @override
  String get aadhaarCard => 'আধার কার্ড (UIDAI)';

  @override
  String get aadhaarCardDesc => 'সামনে এবং পিছনে উভয় দিক ক্যাপচার প্রয়োজন';

  @override
  String get drivingLicense => 'ড্রাইভিং লাইসেন্স (MoRTH)';

  @override
  String get drivingLicenseDesc => 'সামনে এবং পিছনে উভয় দিক ক্যাপচার প্রয়োজন';

  @override
  String get panCard => 'প্যান কার্ড (আয়কর বিভাগ)';

  @override
  String get panCardDesc => 'ছবি ও কিউআর কোড যাচাইকরণ';

  @override
  String get voterId => 'ভোটার আইডি (ECI)';

  @override
  String get voterIdDesc => 'EPIC মানক যাচাইকরণ';

  @override
  String get continueToScan => 'নথি স্ক্যান করতে এগিয়ে যান';

  @override
  String get documentInfoTitle => 'নথি ও পরিচয় তথ্য';

  @override
  String get genuineVerifiedDoc => 'আসল ও যাচাইকৃত নথি';

  @override
  String get unverifiedDoc => 'নথি যাচাই করা যায়নি / অপাঠ্য';

  @override
  String get genuineSubtitle =>
      'গঠন এবং চেকসাম যাচাইকৃত • ডিজিলকার ইস্যুকারী এপিআই v1.13 প্রমাণীকৃত';

  @override
  String get unverifiedSubtitle =>
      'কেন্দ্রীয় রেজিস্ট্রি মান অনুযায়ী নথির বিবরণ প্রমাণীকরণ করা সম্ভব হয়নি';

  @override
  String get genuineBadge => 'আসল';

  @override
  String get flaggedBadge => 'চিহ্নিত';

  @override
  String get documentType => 'নথির ধরন';

  @override
  String get dateOfBirth => 'জন্ম তারিখ';

  @override
  String get gender => 'লিঙ্গ';

  @override
  String get digiLockerId => 'ডিজিলকার আইডি';

  @override
  String get cryptographicSignature => 'ক্রিপ্টোগ্রাফিক স্বাক্ষর';

  @override
  String get validGovtRoot => 'বৈধ (সরকারি রুট সিএ)';

  @override
  String get invalidSignature => 'অযাচাইকৃত / অনুপস্থিত';

  @override
  String get onFileIssuer => 'ইস্যুকারীর রেকর্ডে রয়েছে';

  @override
  String get specifiedInRegistry => 'রেজিস্ট্রিতে উল্লিখিত';

  @override
  String get crossRegisteredDigiLocker => 'ডিজিলকারে ক্রস-নিবন্ধিত নথি';

  @override
  String get crossRegisteredSubtitle =>
      'এই আসল কার্ডধারীর জন্য সরকারি রেজিস্ট্রিগুলি ক্রস-রেফারেন্স করা হয়েছে:';

  @override
  String get verifiedRatio => '৩/৩ যাচাইকৃত';

  @override
  String get matchBadge => 'মিল';

  @override
  String get confirmEditManually => 'ম্যানুয়ালি বিবরণ নিশ্চিত / সম্পাদনা করুন';

  @override
  String get proceedToBiometric => 'বায়োমেট্রিক সেলফির জন্য এগিয়ে যান';

  @override
  String get antiTamperingHologram => 'বিকৃতি বিরোধী এবং হলোগ্রাম যাচাই';

  @override
  String get biometricLiveness => 'বায়োমেট্রিক লাইভনেস ও ফেস ম্যাচ';

  @override
  String get extractedOcrFields => 'নিষ্কাশিত OCR ক্ষেত্র';

  @override
  String get cameraInitializationFailed => 'ক্যামেরা শুরু করতে ব্যর্থ হয়েছে';

  @override
  String get retry => 'পুনরায় চেষ্টা করুন';

  @override
  String get auditHistory => 'অডিট ইতিহাস';

  @override
  String get searchHistoryHint => 'ইতিহাস অনুসন্ধান করুন...';

  @override
  String get allStatuses => 'সমস্ত অবস্থা';

  @override
  String get passed => 'পাস';

  @override
  String get review => 'পর্যালোচনা';

  @override
  String get rejected => 'প্রত্যাখ্যাত';

  @override
  String get noMatchingRecords => 'কোনো রেকর্ড পাওয়া যায়নি';

  @override
  String get screeningTab => 'স্ক্রীনিং';

  @override
  String get auditHistoryTab => 'অডিট ইতিহাস';

  @override
  String get settingsTab => 'সেটিংস';

  @override
  String get systemConfiguration => 'সিস্টেম কনফিগারেশন';

  @override
  String get appearancePreferences => 'উপস্থিতি ও পছন্দ';

  @override
  String get darkTheme => 'ডার্ক থিম';

  @override
  String get darkThemeSubtitle => 'আধুনিক ডার্ক ইন্টারফেস সক্রিয়';

  @override
  String get lightThemeSubtitle => 'উচ্চ-কন্ট্রাস্ট লাইট ইন্টারফেস সক্রিয়';

  @override
  String get interfaceLanguage => 'ইন্টারফেস ভাষা';

  @override
  String get chooseLocale => 'আপনার পছন্দের ভাষা নির্বাচন করুন';

  @override
  String get backendService => 'ব্যাকএন্ড এআই পরিষেবা';

  @override
  String get metricPassRate => 'পাস হার';

  @override
  String get metricFraudBlocked => 'জালিয়াতি বন্ধ';

  @override
  String get metricAvgLatency => 'গড় বিলম্ব';

  @override
  String get metricTotalScreened => 'মোট স্ক্যান';

  @override
  String get applicantDocument => 'আবেদনকারী দলিল';

  @override
  String verdict(String status) {
    return '$status';
  }
}
