// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get antiTamperingHologram => 'છેડછાડ વિરોધી અને હોલોગ્રામ ચકાસણી';

  @override
  String get extractedOcrFields => 'કાઢવામાં આવેલ OCR ફીલ્ડ્સ';

  @override
  String get cameraInitializationFailed => 'કૅમેરા શરૂ કરવામાં નિષ્ફળ';

  @override
  String get retry => 'ફરી પ્રયાસ કરો';

  @override
  String get auditHistory => 'ઓડિટ ઇતિહાસ';

  @override
  String get searchHistoryHint => 'ઇતિહાસ શોધો';

  @override
  String get allStatuses => 'તમામ સ્થિતિઓ';

  @override
  String get passed => 'પાસ થયું';

  @override
  String get review => 'સમીક્ષા';

  @override
  String get rejected => 'અસ્વીકાર્ય';

  @override
  String get noMatchingRecords => 'કોઈ મેળ ખાતા રેકોર્ડ નથી';

  @override
  String verdict(String status) {
    return '$status';
  }
}
