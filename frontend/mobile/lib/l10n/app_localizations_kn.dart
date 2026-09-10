// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get antiTamperingHologram =>
      'ಟ್ಯಾಂಪರಿಂಗ್ ವಿರೋಧಿ ಮತ್ತು ಹೊಲೊಗ್ರಾಮ್ ಪರಿಶೀಲನೆ';

  @override
  String get extractedOcrFields => 'ತೆಗೆದ OCR ಕ್ಷೇತ್ರಗಳು';

  @override
  String get cameraInitializationFailed => 'ಕ್ಯಾಮೆರಾ ಪ್ರಾರಂಭ ವಿಫಲವಾಗಿದೆ';

  @override
  String get retry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get auditHistory => 'ಆಡಿಟ್ ಇತಿಹಾಸ';

  @override
  String get searchHistoryHint => 'ಇತಿಹಾಸವನ್ನು ಹುಡುಕಿ';

  @override
  String get allStatuses => 'ಎಲ್ಲಾ ಸ್ಥಿತಿಗಳು';

  @override
  String get passed => 'ಉತ್ತೀರ್ಣ';

  @override
  String get review => 'ಪರಿಶೀಲನೆ';

  @override
  String get rejected => 'ತಿರಸ್ಕರಿಸಲಾಗಿದೆ';

  @override
  String get noMatchingRecords => 'ಯಾವುದೇ ದಾಖಲೆಗಳು ಕಂಡುಬಂದಿಲ್ಲ';

  @override
  String verdict(String status) {
    return '$status';
  }
}
