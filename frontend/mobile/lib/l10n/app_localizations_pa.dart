// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get antiTamperingHologram => 'ਛੇੜਛਾੜ ਵਿਰੋਧੀ ਅਤੇ ਹੋਲੋਗ੍ਰਾਮ ਜਾਂਚ';

  @override
  String get extractedOcrFields => 'ਕੱਢੇ ਗਏ OCR ਖੇਤਰ';

  @override
  String get cameraInitializationFailed => 'ਕੈਮਰਾ ਸ਼ੁਰੂ ਕਰਨ ਵਿੱਚ ਅਸਫਲ';

  @override
  String get retry => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get auditHistory => 'ਆਡਿਟ ਇਤਿਹਾਸ';

  @override
  String get searchHistoryHint => 'ਇਤਿਹਾਸ ਖੋਜੋ';

  @override
  String get allStatuses => 'ਸਾਰੀਆਂ ਸਥਿਤੀਆਂ';

  @override
  String get passed => 'ਪਾਸ ਕੀਤਾ';

  @override
  String get review => 'ਸਮੀਖਿਆ';

  @override
  String get rejected => 'ਰੱਦ ਕੀਤਾ ਗਿਆ';

  @override
  String get noMatchingRecords => 'ਕੋਈ ਮੇਲ ਖਾਂਦਾ ਰਿਕਾਰਡ ਨਹੀਂ ਮਿਲਿਆ';

  @override
  String verdict(String status) {
    return '$status';
  }
}
