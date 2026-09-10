// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get identityScreeningOs => 'ओळख आणि स्क्रीनिंग ओएस • सक्रिय';

  @override
  String get realTimeScreening => 'रिअल-टाइम स्क्रीनिंग';

  @override
  String get heroTitle => 'एआय-चालित ओळख आणि दस्तऐवज स्क्रीनिंग';

  @override
  String get heroSubtitle =>
      'त्वरित बहुस्तरीय न्यूरल स्कॅन: ओसीआर निष्कर्षण, छेडछाड विरोधी विश्लेषण, बायोमेट्रिक फेशिअल मॅचिंग आणि फसवणूक प्रतिबंध.';

  @override
  String get startNewScreening => 'नवीन स्क्रीनिंग सुरू करा';

  @override
  String get systemEngine => 'सिस्टम इंजिन';

  @override
  String get screeningPipelines => 'स्क्रीनिंग पाइपलाइन';

  @override
  String get pipelinesActive => '४ सक्रिय';

  @override
  String get aiModelWeights => 'एआय मॉडेल वेट्स';

  @override
  String get weightsVersion => 'v2.4 न्यूरल कोर';

  @override
  String get antiTamperShield => 'अँटी-टॅम्पर शील्ड';

  @override
  String get shieldEnabled => 'थेट सक्षम';

  @override
  String get recentVerifications => 'अलीकडील पडताळणी';

  @override
  String get viewAll => 'सर्व पहा';

  @override
  String get noScreeningsRecorded =>
      'अद्याप कोणतीही स्क्रीनिंग नोंदवलेली नाही. वर नवीन स्क्रीनिंग सुरू करा वर टॅप करा.';

  @override
  String get selectDocument => 'दस्तऐवज निवडा';

  @override
  String get issuingCountry => 'जारी करणारा देश / अधिकारक्षेत्र';

  @override
  String get republicOfIndia => 'भारत प्रजासत्ताक (Republic of India)';

  @override
  String get activeRegistry => 'सक्रिय';

  @override
  String get registryDetails => 'UIDAI • ICAO IND • MoRTH • आयकर विभाग';

  @override
  String get supportedIdentityDocuments => 'समर्थित ओळख दस्तऐवज';

  @override
  String get indianPassport => 'भारतीय पासपोर्ट (ICAO 9303)';

  @override
  String get indianPassportDesc => 'MRZ कोड असलेले फोटो पृष्ठ';

  @override
  String get aadhaarCard => 'आधार कार्ड (UIDAI)';

  @override
  String get aadhaarCardDesc =>
      'पुढील आणि मागील दोन्ही बाजू कॅप्चर करणे आवश्यक';

  @override
  String get drivingLicense => 'वाहन चालक परवाना (MoRTH)';

  @override
  String get drivingLicenseDesc =>
      'पुढील आणि मागील दोन्ही बाजू कॅप्चर करणे आवश्यक';

  @override
  String get panCard => 'पॅन कार्ड (आयकर विभाग)';

  @override
  String get panCardDesc => 'फोटो आणि क्यूआर कोड पडताळणी';

  @override
  String get voterId => 'मतदार ओळखपत्र (ECI)';

  @override
  String get voterIdDesc => 'EPIC मानक पडताळणी';

  @override
  String get continueToScan => 'दस्तऐवज स्कॅन करण्यासाठी पुढे जा';

  @override
  String get documentInfoTitle => 'दस्तऐवज आणि ओळख माहिती';

  @override
  String get genuineVerifiedDoc => 'अस्सल आणि पडताळलेले दस्तऐवज';

  @override
  String get unverifiedDoc => 'दस्तऐवज अपडताळलेले / वाचता येत नाही';

  @override
  String get genuineSubtitle =>
      'रचना आणि चेकसम पडताळले • डिजिलॉकर जारीकर्ता एपीआय v1.13 प्रमाणीकृत';

  @override
  String get unverifiedSubtitle =>
      'केंद्रीय रजिस्ट्री मानकांनुसार दस्तऐवज तपशील प्रमाणीकृत केले जाऊ शकले नाहीत';

  @override
  String get genuineBadge => 'अस्सल';

  @override
  String get flaggedBadge => 'चिन्हांकित';

  @override
  String get documentType => 'दस्तऐवज प्रकार';

  @override
  String get dateOfBirth => 'जन्मतारीख';

  @override
  String get gender => 'लिंग';

  @override
  String get digiLockerId => 'डिजिलॉकर आयडी';

  @override
  String get cryptographicSignature => 'क्रिप्टोग्राफिक स्वाक्षरी';

  @override
  String get validGovtRoot => 'वैध (शासकीय रूट सीए)';

  @override
  String get invalidSignature => 'अपडताळलेले / अनुपलब्ध';

  @override
  String get onFileIssuer => 'जारीकर्त्याच्या रेकॉर्डमध्ये उपलब्ध';

  @override
  String get specifiedInRegistry => 'रजिस्ट्रीमध्ये निर्दिष्ट';

  @override
  String get crossRegisteredDigiLocker =>
      'डिजिलॉकरमधील क्रॉस-नोंदणीकृत दस्तऐवज';

  @override
  String get crossRegisteredSubtitle =>
      'या अस्सल कार्डधारकासाठी अधिकृत सरकारी नोंदणी क्रॉस-संदर्भित केली गेली:';

  @override
  String get verifiedRatio => '३/३ पडताळले';

  @override
  String get matchBadge => 'जुळले';

  @override
  String get confirmEditManually => 'तपशील मॅन्युअली पुष्टी / संपादित करा';

  @override
  String get proceedToBiometric => 'बायोमेट्रिक सेल्फीसाठी पुढे जा';

  @override
  String get antiTamperingHologram => 'छेडछाड विरोधी आणि होलोग्राम पडताळणी';

  @override
  String get biometricLiveness => 'बायोमेट्रिक लाइव्हनेस आणि फेस मॅच';

  @override
  String get extractedOcrFields => 'काढलेले OCR फील्ड';

  @override
  String get cameraInitializationFailed => 'कॅमेरा सुरू करण्यात अयशस्वी';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get auditHistory => 'ऑडिट इतिहास';

  @override
  String get searchHistoryHint => 'इतिहास शोधा...';

  @override
  String get allStatuses => 'सर्व स्थिती';

  @override
  String get passed => 'मंजूर';

  @override
  String get review => 'पुनरावलोकन';

  @override
  String get rejected => 'नाकारले';

  @override
  String get noMatchingRecords => 'कोणतीही जुळणी सापडली नाही';

  @override
  String get screeningTab => 'स्क्रीनिंग';

  @override
  String get auditHistoryTab => 'ऑडिट इतिहास';

  @override
  String get settingsTab => 'सेटिंग्ज';

  @override
  String get systemConfiguration => 'सिस्टम कॉन्फिगरेशन';

  @override
  String get appearancePreferences => 'स्वरूप आणि प्राधान्ये';

  @override
  String get darkTheme => 'डार्क थीम';

  @override
  String get darkThemeSubtitle => 'आधुनिक डार्क इंटरफेस सक्रिय';

  @override
  String get lightThemeSubtitle => 'हाय-कॉन्ट्रास्ट लाइट इंटरफेस सक्रिय';

  @override
  String get interfaceLanguage => 'इंटरफेस भाषा';

  @override
  String get chooseLocale => 'तुमची पसंतीची भाषा निवडा';

  @override
  String get backendService => 'बॅकएंड एआय सेवा';

  @override
  String get metricPassRate => 'उत्तीर्ण दर';

  @override
  String get metricFraudBlocked => 'फसवणूक थांबवली';

  @override
  String get metricAvgLatency => 'सरासरी विलंब';

  @override
  String get metricTotalScreened => 'एकूण तपासणी';

  @override
  String get applicantDocument => 'अर्जदार दस्तावेज';

  @override
  String verdict(String status) {
    return '$status';
  }
}
