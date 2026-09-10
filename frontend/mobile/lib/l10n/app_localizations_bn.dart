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
  String get antiTamperingHologram => 'ট্যাম্পার-প্রতিরোধী ও হলোগ্রাম যাচাই';

  @override
  String get extractedOcrFields => 'সংগৃহীত OCR ক্ষেত্রসমূহ';

  @override
  String get cameraInitializationFailed => 'ক্যামেরা চালু করতে ব্যর্থ';

  @override
  String get retry => 'পুনরায় চেষ্টা করুন';

  @override
  String get auditHistory => 'অডিট ইতিহাস';

  @override
  String get searchHistoryHint => 'ইতিহাস খুঁজুন';

  @override
  String get allStatuses => 'সমস্ত স্থিতি';

  @override
  String get passed => 'উত্তীর্ণ';

  @override
  String get review => 'পর্যালোচনা';

  @override
  String get rejected => 'প্রত্যাখ্যাত';

  @override
  String get noMatchingRecords => 'কোনো মিল পাওয়া যায়নি';

  @override
  String verdict(String status) {
    return '$status';
  }
}
