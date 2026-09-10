// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get antiTamperingHologram => 'యాంటీ ట్యాంపరింగ్ & హోలోగ్రామ్ ధృవీకరణ';

  @override
  String get extractedOcrFields => 'వెలికితీసిన OCR ఫీల్డ్‌లు';

  @override
  String get cameraInitializationFailed => 'కెమెరా ప్రారంభం విఫలమైంది';

  @override
  String get retry => 'మళ్ళీ ప్రయత్నించండి';

  @override
  String get auditHistory => 'ఆడిట్ చరిత్ర';

  @override
  String get searchHistoryHint => 'చరిత్రను శోధించండి';

  @override
  String get allStatuses => 'అన్ని స్థితులు';

  @override
  String get passed => 'ఉత్తీర్ణం';

  @override
  String get review => 'సమీక్ష';

  @override
  String get rejected => 'తిరస్కరించబడింది';

  @override
  String get noMatchingRecords => 'సరిపోలే రికార్డులు లేవు';

  @override
  String verdict(String status) {
    return '$status';
  }
}
