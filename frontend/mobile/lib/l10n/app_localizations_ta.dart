// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get antiTamperingHologram =>
      'மோசடி எதிர்ப்பு மற்றும் ஹோலோகிராம் சரிபார்ப்பு';

  @override
  String get extractedOcrFields => 'பிரித்தெடுக்கப்பட்ட OCR புலங்கள்';

  @override
  String get cameraInitializationFailed => 'கேமரா தொடங்குவதில் தோல்வி';

  @override
  String get retry => 'மீண்டும் முயற்சி செய்';

  @override
  String get auditHistory => 'தணிக்கை வரலாறு';

  @override
  String get searchHistoryHint => 'வரலாற்றைத் தேடுக';

  @override
  String get allStatuses => 'அனைத்து நிலைகளும்';

  @override
  String get passed => 'வெற்றி பெற்றது';

  @override
  String get review => 'மதிப்பாய்வு';

  @override
  String get rejected => 'நிராகரிக்கப்பட்டது';

  @override
  String get noMatchingRecords => 'பொருந்தும் பதிவுகள் எதுவும் இல்லை';

  @override
  String verdict(String status) {
    return '$status';
  }
}
