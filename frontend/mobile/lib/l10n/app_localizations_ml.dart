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
  String get antiTamperingHologram => 'സുരക്ഷാ പരിശോധന';

  @override
  String get extractedOcrFields => 'തിരിച്ചറിഞ്ഞ വിവരങ്ങൾ';

  @override
  String get cameraInitializationFailed => 'ക്യാമറ ആരംഭിക്കാൻ കഴിഞ്ഞില്ല';

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
  String get review => 'പരിശോധന';

  @override
  String get rejected => 'നിരസിച്ചു';

  @override
  String get noMatchingRecords => 'രേഖകൾ ഒന്നും കണ്ടെത്തിയില്ല';

  @override
  String get screeningTab => 'സ്ക്രീനിംഗ്';

  @override
  String get auditHistoryTab => 'ഓഡിറ്റ് ചരിത്രം';

  @override
  String get settingsTab => 'ക്രമീകരണങ്ങൾ';

  @override
  String get startScreening => 'രേഖ പരിശോധന ആരംഭിക്കുക';

  @override
  String get systemConfiguration => 'സിസ്റ്റം ക്രമീകരണം';

  @override
  String get appearancePreferences => 'രൂപവും മുൻഗണനകളും';

  @override
  String get darkTheme => 'ഡാർക്ക് തീം';

  @override
  String get darkThemeSubtitle => 'ഡാർക്ക് മോഡ് സജീവമാണ്';

  @override
  String get lightThemeSubtitle => 'ലൈറ്റ് മോഡ് സജീവമാണ്';

  @override
  String get interfaceLanguage => 'ഭാഷ';

  @override
  String get chooseLocale => 'നിങ്ങളുടെ മുൻഗണനാ ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get backendService => 'ബാക്കെൻഡ് AI സേവനം';

  @override
  String get selectDocumentType => 'രേഖയുടെ തരം തിരഞ്ഞെടുക്കുക';

  @override
  String get nationalIdAadhaar => 'ആധാർ കാർഡ്';

  @override
  String get panCard => 'പാൻ കാർഡ്';

  @override
  String get drivingLicense => 'ഡ്രൈവിംഗ് ലൈസൻസ്';

  @override
  String get passport => 'പാസ്പോർട്ട്';

  @override
  String get voterId => 'വോട്ടർ ഐഡി';

  @override
  String get verifiedCardholder => 'സ്ഥിരീകരിച്ച കാർഡുടമ';

  @override
  String get unverifiedCardholder => 'തിരിച്ചറിയാത്ത കാർഡുടമ';

  @override
  String get documentVerified => 'യഥാർത്ഥ രേഖ സ്ഥിരീകരിച്ചു';

  @override
  String get documentUnverified => 'രേഖ വായിക്കാൻ കഴിഞ്ഞില്ല';

  @override
  String get editDetailsManually => 'വിവരങ്ങൾ സ്വയം നൽകുക';

  @override
  String get crossRegisteredDocs => 'ഡിജിലോക്കറിലെ രേഖകൾ';

  @override
  String get proceedToBiometrics => 'ബയോമെട്രിക്സിലേക്ക് തുടരുക';

  @override
  String get reScanDocument => 'വീണ്ടും സ്കാൻ ചെയ്യുക';

  @override
  String verdict(String status) {
    return '$status';
  }
}
