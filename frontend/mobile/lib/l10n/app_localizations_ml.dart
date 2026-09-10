// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get antiTamperingHologram =>
      'വ്യാജനിർമ്മാണ തടയലും ഹോളോഗ്രാം പരിശോധനയും';

  @override
  String get extractedOcrFields => 'എക്‌സ്‌ട്രാക്‌റ്റ് ചെയ്‌ത OCR ഫീൽഡുകൾ';

  @override
  String get cameraInitializationFailed =>
      'ക്യാമറ ആരംഭിക്കുന്നത് പരാജയപ്പെട്ടു';

  @override
  String get retry => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get auditHistory => 'ഓഡിറ്റ് ചരിത്രം';

  @override
  String get searchHistoryHint => 'ചരിത്രം തിരയുക';

  @override
  String get allStatuses => 'എല്ലാ നിലകളും';

  @override
  String get passed => 'വിജയിച്ചു';

  @override
  String get review => 'പുനരവലോകനം';

  @override
  String get rejected => 'നിരസിച്ചു';

  @override
  String get noMatchingRecords => 'പൊരുത്തപ്പെടുന്ന റെക്കോർഡുകളില്ല';

  @override
  String verdict(String status) {
    return '$status';
  }
}
