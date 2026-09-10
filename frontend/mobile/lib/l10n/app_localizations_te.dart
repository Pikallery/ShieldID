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
  String get antiTamperingHologram => 'భద్రతా తనిఖీ';

  @override
  String get extractedOcrFields => 'గుర్తించిన వివరాలు';

  @override
  String get cameraInitializationFailed => 'కెమెరా ప్రారంభం కాలేదు';

  @override
  String get retry => 'మళ్ళీ ప్రయత్నించండి';

  @override
  String get auditHistory => 'ఆడిట్ చరిత్ర';

  @override
  String get searchHistoryHint => 'చరిత్రను శోధించండి';

  @override
  String get allStatuses => 'అన్ని స్థితులు';

  @override
  String get passed => 'సఫలం';

  @override
  String get review => 'సమీక్ష';

  @override
  String get rejected => 'తిరస్కరించబడింది';

  @override
  String get noMatchingRecords => 'ఎలాంటి రికార్డులు కనుగొనబడలేదు';

  @override
  String get screeningTab => 'స్క్రీనింగ్';

  @override
  String get auditHistoryTab => 'ఆడిట్ చరిత్ర';

  @override
  String get settingsTab => 'సెట్టింగ్‌లు';

  @override
  String get startScreening => 'పత్రాల పరిశీలన ప్రారంభించండి';

  @override
  String get systemConfiguration => 'సిస్టమ్ అమరికలు';

  @override
  String get appearancePreferences => 'రూపం మరియు ప్రాధాన్యతలు';

  @override
  String get darkTheme => 'డార్క్ థీమ్';

  @override
  String get darkThemeSubtitle => 'డార్క్ మోడ్ సక్రియంగా ఉంది';

  @override
  String get lightThemeSubtitle => 'లైట్ మోడ్ సక్రియంగా ఉంది';

  @override
  String get interfaceLanguage => 'భాష';

  @override
  String get chooseLocale => 'మీ ప్రాధాన్య భాషను ఎంచుకోండి';

  @override
  String get backendService => 'బ్యాకెండ్ AI సేవ';

  @override
  String get selectDocumentType => 'పత్రం రకాన్ని ఎంచుకోండి';

  @override
  String get nationalIdAadhaar => 'ఆధార్ కార్డు';

  @override
  String get panCard => 'పాన్ కార్డు';

  @override
  String get drivingLicense => 'డ్రైవింగ్ లైసెన్స్';

  @override
  String get passport => 'పాస్‌పోర్ట్';

  @override
  String get voterId => 'ఓటర్ ఐడీ';

  @override
  String get verifiedCardholder => 'ధృవీకరించబడిన కార్డుదారు';

  @override
  String get unverifiedCardholder => 'గుర్తించబడని కార్డుదారు';

  @override
  String get documentVerified => 'అసలు పత్రం ధృవీకరించబడింది';

  @override
  String get documentUnverified => 'పత్రం చదవలేకపోయాము';

  @override
  String get editDetailsManually => 'వివరాలను మాన్యువల్‌గా నమోదు చేయండి';

  @override
  String get crossRegisteredDocs => 'డిజిలాకర్‌లో నమోదు చేసిన పత్రాలు';

  @override
  String get proceedToBiometrics => 'బయోమెట్రిక్స్‌కు కొనసాగండి';

  @override
  String get reScanDocument => 'మళ్ళీ స్కాన్ చేయండి';

  @override
  String verdict(String status) {
    return '$status';
  }
}
