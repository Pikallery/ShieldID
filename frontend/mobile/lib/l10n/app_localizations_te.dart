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
  String get identityScreeningOs =>
      'గుర్తింపు మరియు స్క్రీనింగ్ OS • క్రియాశీలం';

  @override
  String get realTimeScreening => 'రియల్-టైమ్ స్క్రీనింగ్';

  @override
  String get heroTitle => 'AI-ఆధారిత గుర్తింపు & పత్రాల స్క్రీనింగ్';

  @override
  String get heroSubtitle =>
      'తక్షణ బహుళ-పొరల న్యూరల్ స్కాన్: OCR వెలికితీత, ట్యాంపరింగ్ వ్యతిరేక విశ్లేషణ, బయోమెట్రిక్ ముఖ సరిపోలిక మరియు మోసం నివారణ.';

  @override
  String get startNewScreening => 'కొత్త స్క్రీనింగ్ ప్రారంభించండి';

  @override
  String get systemEngine => 'సిస్టమ్ ఇంజిన్';

  @override
  String get screeningPipelines => 'స్క్రీనింగ్ పైప్‌లైన్లు';

  @override
  String get pipelinesActive => '4 క్రియాశీలం';

  @override
  String get aiModelWeights => 'AI మోడల్ వెయిట్స్';

  @override
  String get weightsVersion => 'v2.4 న్యూరల్ కోర్';

  @override
  String get antiTamperShield => 'యాంటీ-ట్యాంపర్ షీల్డ్';

  @override
  String get shieldEnabled => 'లైవ్ ప్రారంభించబడింది';

  @override
  String get recentVerifications => 'ఇటీవలి ధృవీకరణలు';

  @override
  String get viewAll => 'అన్నీ చూడండి';

  @override
  String get noScreeningsRecorded =>
      'ఇంకా స్క్రీనింగ్‌లు నమోదు కాలేదు. పైన కొత్త స్క్రీనింగ్ ప్రారంభించండి నొక్కండి.';

  @override
  String get selectDocument => 'పత్రాన్ని ఎంచుకోండి';

  @override
  String get issuingCountry => 'జారీ చేసిన దేశం / అధికార పరిధి';

  @override
  String get republicOfIndia => 'భారత గణతంత్రం (Republic of India)';

  @override
  String get activeRegistry => 'క్రియాశీలం';

  @override
  String get registryDetails => 'UIDAI • ICAO IND • MoRTH • ఆదాయపు పన్ను శాఖ';

  @override
  String get supportedIdentityDocuments => 'మద్దతు ఉన్న గుర్తింపు పత్రాలు';

  @override
  String get indianPassport => 'భారతీయ పాస్‌పోర్ట్ (ICAO 9303)';

  @override
  String get indianPassportDesc => 'MRZ కోడ్‌తో ఫోటో పేజీ';

  @override
  String get aadhaarCard => 'ఆధార్ కార్డ్ (UIDAI)';

  @override
  String get aadhaarCardDesc =>
      'ముందు మరియు వెనుక రెండు వైపులా క్యాప్చర్ అవసరం';

  @override
  String get drivingLicense => 'డ్రైవింగ్ లైసెన్స్ (MoRTH)';

  @override
  String get drivingLicenseDesc =>
      'ముందు మరియు వెనుక రెండు వైపులా క్యాప్చర్ అవసరం';

  @override
  String get panCard => 'పాన్ కార్డ్ (ఆదాయపు పన్ను శాఖ)';

  @override
  String get panCardDesc => 'ఫోటో మరియు QR కోడ్ ధృవీకరణ';

  @override
  String get voterId => 'ఓటరు ఐడి (ECI)';

  @override
  String get voterIdDesc => 'EPIC ప్రామాణిక ధృవీకరణ';

  @override
  String get continueToScan => 'పత్రం స్కాన్ చేయడానికి కొనసాగండి';

  @override
  String get documentInfoTitle => 'పత్రం మరియు గుర్తింపు సమాచారం';

  @override
  String get genuineVerifiedDoc => 'అసలైన & ధృవీకరించబడిన పత్రం';

  @override
  String get unverifiedDoc => 'పత్రం ధృవీకరించబడలేదు / చదవలేము';

  @override
  String get genuineSubtitle =>
      'నిర్మాణం మరియు చెక్‌సమ్ ధృవీకరించబడింది • డిజిలాకర్ జారీదారు API v1.13 ప్రామాణీకరించబడింది';

  @override
  String get unverifiedSubtitle =>
      'కేంద్ర రిజిస్ట్రీ ప్రమాణాలకు అనుగుణంగా పత్ర వివరాలు ప్రామాణీకరించబడలేదు';

  @override
  String get genuineBadge => 'అసలైనది';

  @override
  String get flaggedBadge => 'ఫ్లాగ్ చేయబడింది';

  @override
  String get documentType => 'పత్రం రకం';

  @override
  String get dateOfBirth => 'పుట్టిన తేదీ';

  @override
  String get gender => 'లింగం';

  @override
  String get digiLockerId => 'డిజిలాకర్ ఐడి';

  @override
  String get cryptographicSignature => 'క్రిప్టోగ్రాఫిక్ సంతకం';

  @override
  String get validGovtRoot => 'చెల్లుబాటు అయ్యేది (ప్రభుత్వ రూట్ CA)';

  @override
  String get invalidSignature => 'ధృవీకరించబడలేదు / అందుబాటులో లేదు';

  @override
  String get onFileIssuer => 'జారీదారు రికార్డులలో ఉంది';

  @override
  String get specifiedInRegistry => 'రిజిస్ట్రీలో పేర్కొనబడింది';

  @override
  String get crossRegisteredDigiLocker =>
      'డిజిలాకర్‌లో క్రాస్-రిజిస్టర్ చేయబడిన పత్రాలు';

  @override
  String get crossRegisteredSubtitle =>
      'ఈ అసలైన కార్డ్ హోల్డర్ కోసం అధికారిక ప్రభుత్వ రిజిస్ట్రీలు సరిపోల్చబడ్డాయి:';

  @override
  String get verifiedRatio => '3/3 ధృవీకరించబడింది';

  @override
  String get matchBadge => 'సరిపోలింది';

  @override
  String get confirmEditManually =>
      'వివరాలను మాన్యువల్‌గా నిర్ధారించండి / సవరించండి';

  @override
  String get proceedToBiometric => 'బయోమెట్రిక్ సెల్ఫీకి వెళ్లండి';

  @override
  String get antiTamperingHologram => 'ట్యాంపరింగ్ వ్యతిరేక & హోలోగ్రామ్ తనిఖీ';

  @override
  String get biometricLiveness => 'బయోమెట్రిక్ లైవ్‌నెస్ మరియు ఫేస్ మ్యాచ్';

  @override
  String get extractedOcrFields => 'వెలికితీసిన OCR ఫీల్డ్‌లు';

  @override
  String get cameraInitializationFailed => 'కెమెరా ప్రారంభం విఫలమైంది';

  @override
  String get retry => 'మళ్ళీ ప్రయత్నించండి';

  @override
  String get auditHistory => 'ఆడిట్ చరిత్ర';

  @override
  String get searchHistoryHint => 'చరిత్రను శోధించండి...';

  @override
  String get allStatuses => 'అన్ని స్థితులు';

  @override
  String get passed => 'ఆమోదించబడింది';

  @override
  String get review => 'సమీక్ష';

  @override
  String get rejected => 'తిరస్కరించబడింది';

  @override
  String get noMatchingRecords => 'సరిపోలే రికార్డులు కనుగొనబడలేదు';

  @override
  String get screeningTab => 'స్క్రీనింగ్';

  @override
  String get auditHistoryTab => 'ఆడిట్ చరిత్ర';

  @override
  String get settingsTab => 'సెట్టింగ్‌లు';

  @override
  String get systemConfiguration => 'సిస్టమ్ కాన్ఫిగరేషన్';

  @override
  String get appearancePreferences => 'రూపం మరియు ప్రాధాన్యతలు';

  @override
  String get darkTheme => 'డార్క్ థీమ్';

  @override
  String get darkThemeSubtitle => 'ఆధునిక డార్క్ ఇంటర్‌ఫేస్ క్రియాశీలం';

  @override
  String get lightThemeSubtitle => 'హై-కాంట్రాస్ట్ లైట్ ఇంటర్‌ఫేస్ క్రియాశీలం';

  @override
  String get interfaceLanguage => 'ఇంటర్‌ఫేస్ భాష';

  @override
  String get chooseLocale => 'మీకు నచ్చిన భాషను ఎంచుకోండి';

  @override
  String get backendService => 'బ్యాకెండ్ AI సేవ';

  @override
  String get metricPassRate => 'పాస్ రేటు';

  @override
  String get metricFraudBlocked => 'మోసం నిలిపివేశారు';

  @override
  String get metricAvgLatency => 'సగటు ఆలస్యం';

  @override
  String get metricTotalScreened => 'మొత్తం స్క్రీన్';

  @override
  String get applicantDocument => 'దరఖాస్తుదారు పత్రం';

  @override
  String verdict(String status) {
    return '$status';
  }
}
