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
  String get antiTamperingHologram => 'হলোগ্রাম ও সুরক্ষা পরীক্ষা';

  @override
  String get extractedOcrFields => 'নিষ্কাশিত বিবরণ';

  @override
  String get cameraInitializationFailed => 'ক্যামেরা আরম্ভ ব্যর্থ হয়েছে';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get auditHistory => 'অডিট ইতিহাস';

  @override
  String get searchHistoryHint => 'ইতিহাস অনুসন্ধান করুন';

  @override
  String get allStatuses => 'সমস্ত অবস্থা';

  @override
  String get passed => 'সফল';

  @override
  String get review => 'পর্যালোচনা';

  @override
  String get rejected => 'প্রত্যাখ্যাত';

  @override
  String get noMatchingRecords => 'কোনো রেকর্ড পাওয়া যায়নি';

  @override
  String get screeningTab => 'স্ক্রিনিং';

  @override
  String get auditHistoryTab => 'অডিট ইতিহাস';

  @override
  String get settingsTab => 'সেটিংস';

  @override
  String get startScreening => 'ডকুমেন্ট স্ক্রিনিং শুরু করুন';

  @override
  String get systemConfiguration => 'সিস্টেম কনফিগারেশন';

  @override
  String get appearancePreferences => 'উপস্থিতি ও পছন্দসমূহ';

  @override
  String get darkTheme => 'ডার্ক থিম';

  @override
  String get darkThemeSubtitle => 'ডার্ক মোড সক্রিয়';

  @override
  String get lightThemeSubtitle => 'লাইট মোড সক্রিয়';

  @override
  String get interfaceLanguage => 'ভাষা';

  @override
  String get chooseLocale => 'আপনার পছন্দের ভাষা নির্বাচন করুন';

  @override
  String get backendService => 'ব্যাকএন্ড এআই পরিষেবা';

  @override
  String get selectDocumentType => 'নথির ধরন নির্বাচন করুন';

  @override
  String get nationalIdAadhaar => 'আধার কার্ড';

  @override
  String get panCard => 'প্যান কার্ড';

  @override
  String get drivingLicense => 'ড্রাইভিং লাইসেন্স';

  @override
  String get passport => 'পাসপোর্ট';

  @override
  String get voterId => 'ভোটার আইডি';

  @override
  String get verifiedCardholder => 'যাচাইকৃত কার্ডধারী';

  @override
  String get unverifiedCardholder => 'অচিহ্নিত কার্ডধারী';

  @override
  String get documentVerified => 'আসল নথি যাচাইকৃত';

  @override
  String get documentUnverified => 'নথি অপাঠ্য / যাচাইহীন';

  @override
  String get editDetailsManually => 'ম্যানুয়ালি বিশদ লিখুন';

  @override
  String get crossRegisteredDocs => 'ডিজিলকারে নিবন্ধিত নথি';

  @override
  String get proceedToBiometrics => 'বায়োমেট্রিক্সে এগিয়ে যান';

  @override
  String get reScanDocument => 'পুনরায় স্ক্যান করুন';

  @override
  String verdict(String status) {
    return '$status';
  }
}
