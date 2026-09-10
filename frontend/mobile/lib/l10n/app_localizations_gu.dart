// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get identityScreeningOs => 'ઓળખ અને સ્ક્રીનીંગ OS • સક્રિય';

  @override
  String get realTimeScreening => 'રીઅલ-ટાઇમ સ્ક્રીનીંગ';

  @override
  String get heroTitle => 'AI-સંચાલિત ઓળખ અને દસ્તાવેજ સ્ક્રીનીંગ';

  @override
  String get heroSubtitle =>
      'ત્વરિત મલ્ટી-લેયર ન્યુરલ સ્કેન: OCR નિષ્કર્ષણ, છેડછાડ વિરોધી વિશ્લેષણ, બાયોમેટ્રિક ફેશિયલ મેચિંગ અને છેતરપિંડી નિવારણ.';

  @override
  String get startNewScreening => 'નવું સ્ક્રીનીંગ શરૂ કરો';

  @override
  String get systemEngine => 'સિસ્ટમ એન્જિન';

  @override
  String get screeningPipelines => 'સ્ક્રીનીંગ પાઇપલાઇન્સ';

  @override
  String get pipelinesActive => '૪ સક્રિય';

  @override
  String get aiModelWeights => 'AI મોડેલ વેટ્સ';

  @override
  String get weightsVersion => 'v2.4 ન્યુરલ કોર';

  @override
  String get antiTamperShield => 'એન્ટિ-ટેમ્પર શિલ્ડ';

  @override
  String get shieldEnabled => 'લાઇવ સક્ષમ';

  @override
  String get recentVerifications => 'તાજેતરના ચકાસણીઓ';

  @override
  String get viewAll => 'બધા જુઓ';

  @override
  String get noScreeningsRecorded =>
      'હજી સુધી કોઈ સ્ક્રીનીંગ રેકોર્ડ નથી. ઉપર નવું સ્ક્રીનીંગ શરૂ કરો પર ટેપ કરો.';

  @override
  String get selectDocument => 'દસ્તાવેજ પસંદ કરો';

  @override
  String get issuingCountry => 'ઇશ્યુ કરનાર દેશ / અધિકારક્ષેત્ર';

  @override
  String get republicOfIndia => 'ભારત ગણરાજ્ય (Republic of India)';

  @override
  String get activeRegistry => 'સક્રિય';

  @override
  String get registryDetails => 'UIDAI • ICAO IND • MoRTH • આવકવેરા વિભાગ';

  @override
  String get supportedIdentityDocuments => 'સમર્થિત ઓળખ દસ્તાવેજો';

  @override
  String get indianPassport => 'ભારતીય પાસપોર્ટ (ICAO 9303)';

  @override
  String get indianPassportDesc => 'MRZ કોડ સાથેનો ફોટો પેજ';

  @override
  String get aadhaarCard => 'આધાર કાર્ડ (UIDAI)';

  @override
  String get aadhaarCardDesc => 'આગળ અને પાછળ બંને બાજુ કેપ્ચર જરૂરી';

  @override
  String get drivingLicense => 'ડ્રાઇવિંગ લાઇસન્સ (MoRTH)';

  @override
  String get drivingLicenseDesc => 'આગળ અને પાછળ બંને બાજુ કેપ્ચર જરૂરી';

  @override
  String get panCard => 'પાન કાર્ડ (આવકવેરા વિભાગ)';

  @override
  String get panCardDesc => 'ફોટો અને QR કોડ ચકાસણી';

  @override
  String get voterId => 'મતદાર ઓળખપત્ર (ECI)';

  @override
  String get voterIdDesc => 'EPIC પ્રમાણભૂત ચકાસણી';

  @override
  String get continueToScan => 'દસ્તાવેજ સ્કેન માટે આગળ વધો';

  @override
  String get documentInfoTitle => 'દસ્તાવેજ અને ઓળખ માહિતી';

  @override
  String get genuineVerifiedDoc => 'અસલી અને ચકાસાયેલ દસ્તાવેજ';

  @override
  String get unverifiedDoc => 'અચકાસાયેલ / વાંચી ન શકાય તેવો દસ્તાવેજ';

  @override
  String get genuineSubtitle =>
      'માળખું અને ચેકસમ ચકાસાયેલ • ડિજીલોકર ઇશ્યુઅર API v1.13 પ્રમાણિત';

  @override
  String get unverifiedSubtitle =>
      'કેન્દ્રીય રજિસ્ટ્રી ધોરણો મુજબ દસ્તાવેજ વિગતો પ્રમાણિત કરી શકાઈ નથી';

  @override
  String get genuineBadge => 'અસલી';

  @override
  String get flaggedBadge => 'ચિહ્નિત';

  @override
  String get documentType => 'દસ્તાવેજ પ્રકાર';

  @override
  String get dateOfBirth => 'જન્મ તારીખ';

  @override
  String get gender => 'જાતિ';

  @override
  String get digiLockerId => 'ડિજીલોકર ID';

  @override
  String get cryptographicSignature => 'ક્રિપ્ટોગ્રાફિક સહી';

  @override
  String get validGovtRoot => 'માન્ય (સરકારી રૂટ CA)';

  @override
  String get invalidSignature => 'અચકાસાયેલ / ગેરહાજર';

  @override
  String get onFileIssuer => 'ઇશ્યુઅર પાસે ફાઇલ પર';

  @override
  String get specifiedInRegistry => 'રજિસ્ટ્રીમાં ઉલ્લેખિત';

  @override
  String get crossRegisteredDigiLocker =>
      'ડિજીલોકરમાં ક્રોસ-નોંધાયેલ દસ્તાવેજો';

  @override
  String get crossRegisteredSubtitle =>
      'આ અસલી કાર્ડધારક માટે સત્તાવાર સરકારી રજિસ્ટ્રી ક્રોસ-રેફરન્સ કરવામાં આવી:';

  @override
  String get verifiedRatio => '૩/૩ ચકાસાયેલ';

  @override
  String get matchBadge => 'મેચ';

  @override
  String get confirmEditManually => 'વિગતો જાતે પુષ્ટિ / સંપાદિત કરો';

  @override
  String get proceedToBiometric => 'બાયોમેટ્રિક સેલ્ફી માટે આગળ વધો';

  @override
  String get antiTamperingHologram => 'છેડછાડ વિરોધી અને હોલોગ્રામ ચકાસણી';

  @override
  String get biometricLiveness => 'બાયોમેટ્રિક લાઇવનેસ અને ફેસ મેચ';

  @override
  String get extractedOcrFields => 'કાઢવામાં આવેલ OCR ફીલ્ડ્સ';

  @override
  String get cameraInitializationFailed => 'કેમેરા શરૂ કરવામાં નિષ્ફળ';

  @override
  String get retry => 'ફરી પ્રયાસ કરો';

  @override
  String get auditHistory => 'ઓડિટ ઇતિહાસ';

  @override
  String get searchHistoryHint => 'ઇતિહાસ શોધો...';

  @override
  String get allStatuses => 'બધી સ્થિતિઓ';

  @override
  String get passed => 'પાસ';

  @override
  String get review => 'સમીક્ષા';

  @override
  String get rejected => 'નકારાયેલ';

  @override
  String get noMatchingRecords => 'કોઈ મેળ ખાતા રેકોર્ડ મળ્યા નથી';

  @override
  String get screeningTab => 'સ્ક્રીનીંગ';

  @override
  String get auditHistoryTab => 'ઓડિટ ઇતિહાસ';

  @override
  String get settingsTab => 'સેટિંગ્સ';

  @override
  String get systemConfiguration => 'સિસ્ટમ રૂપરેખાંકન';

  @override
  String get appearancePreferences => 'દેખાવ અને પસંદગીઓ';

  @override
  String get darkTheme => 'ડાર્ક થીમ';

  @override
  String get darkThemeSubtitle => 'સ્લીક ડાર્ક ઇન્ટરફેસ સક્રિય';

  @override
  String get lightThemeSubtitle => 'હાઇ-કોન્ટ્રાસ્ટ લાઇટ ઇન્ટરફેસ સક્રિય';

  @override
  String get interfaceLanguage => 'ઇન્ટરફેસ ભાષા';

  @override
  String get chooseLocale => 'તમારી પસંદગીની ભાષા પસંદ કરો';

  @override
  String get backendService => 'બેકએન્ડ AI સેવા';

  @override
  String get metricPassRate => 'પાસ રેટ';

  @override
  String get metricFraudBlocked => 'છળ અટકાવ્યું';

  @override
  String get metricAvgLatency => 'સરેરાશ વિલંબ';

  @override
  String get metricTotalScreened => 'કુલ સ્ક્રિન';

  @override
  String get applicantDocument => 'અરજદાર દસ્તાવેજ';

  @override
  String verdict(String status) {
    return '$status';
  }
}
