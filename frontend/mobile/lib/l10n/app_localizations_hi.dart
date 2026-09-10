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
  String get antiTamperingHologram => 'छेड़छाड़-रोधी और होलोग्राम सत्यापन';

  @override
  String get extractedOcrFields => 'निकाले गए OCR फ़ील्ड';

  @override
  String get cameraInitializationFailed => 'कैमरा शुरू करने में विफल';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get auditHistory => 'ऑडिट इतिहास';

  @override
  String get searchHistoryHint => 'इतिहास खोजें';

  @override
  String get allStatuses => 'सभी स्थितियाँ';

  @override
  String get passed => 'उत्तीर्ण';

  @override
  String get review => 'समीक्षा';

  @override
  String get rejected => 'अस्वीकृत';

  @override
  String get noMatchingRecords => 'कोई रिकॉर्ड नहीं मिला';

  @override
  String verdict(String status) {
    return '$status';
  }
}
