// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get antiTamperingHologram => 'Anti-tampering and hologram check';

  @override
  String get extractedOcrFields => 'Extracted OCR fields';

  @override
  String get cameraInitializationFailed => 'Camera initialization failed';

  @override
  String get retry => 'Retry';

  @override
  String get auditHistory => 'Audit history';

  @override
  String get searchHistoryHint => 'Search history';

  @override
  String get allStatuses => 'All statuses';

  @override
  String get passed => 'Passed';

  @override
  String get review => 'Review';

  @override
  String get rejected => 'Rejected';

  @override
  String get noMatchingRecords => 'No matching records';

  @override
  String verdict(String status) {
    return '$status';
  }
}
