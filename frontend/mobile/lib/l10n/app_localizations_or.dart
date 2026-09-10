// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oriya (`or`).
class AppLocalizationsOr extends AppLocalizations {
  AppLocalizationsOr([String locale = 'or']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get antiTamperingHologram => 'ହୋଲୋଗ୍ରାମ ଏବଂ ସୁରକ୍ଷା ଯାଞ୍ଚ';

  @override
  String get extractedOcrFields => 'ନଥିପତ୍ରରୁ ବାହାର କରାଯାଇଥିବା ତଥ୍ୟ';

  @override
  String get cameraInitializationFailed => 'କ୍ୟାମେରା ଆରମ୍ଭ ବିଫଳ';

  @override
  String get retry => 'ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get auditHistory => 'ଅଡିଟ୍ ଇତିହାସ';

  @override
  String get searchHistoryHint => 'ଇତିହାସ ଖୋଜନ୍ତୁ';

  @override
  String get allStatuses => 'ସମସ୍ତ ସ୍ଥିତି';

  @override
  String get passed => 'ସଫଳ';

  @override
  String get review => 'ପୁନର୍ବିଚାର';

  @override
  String get rejected => 'ଅସ୍ୱୀକୃତ';

  @override
  String get noMatchingRecords => 'କୌଣସି ରେକର୍ଡ ମିଳିଲା ନାହିଁ';

  @override
  String get screeningTab => 'ସ୍କ୍ରିନିଂ';

  @override
  String get auditHistoryTab => 'ଅଡିଟ୍ ଇତିହାସ';

  @override
  String get settingsTab => 'ସେଟିଂସ୍';

  @override
  String get startScreening => 'ଡକ୍ୟୁମେଣ୍ଟ ଯାଞ୍ଚ ଆରମ୍ଭ କରନ୍ତୁ';

  @override
  String get systemConfiguration => 'ସିଷ୍ଟମ ସେଟିଂସ୍';

  @override
  String get appearancePreferences => 'ରୂପ ଏବଂ ପସନ୍ଦ';

  @override
  String get darkTheme => 'ଡାର୍କ ଥିମ୍';

  @override
  String get darkThemeSubtitle => 'ଡାର୍କ ମୋଡ୍ ସକ୍ରିୟ ଅଛି';

  @override
  String get lightThemeSubtitle => 'ଲାଇଟ୍ ମୋଡ୍ ସକ୍ରିୟ ଅଛି';

  @override
  String get interfaceLanguage => 'ଭାଷା';

  @override
  String get chooseLocale => 'ଆପଣଙ୍କ ପସନ୍ଦର ଭାଷା ବାଛନ୍ତୁ';

  @override
  String get backendService => 'ବ୍ୟାକଏଣ୍ଡ୍ ଏଆଇ ସେବା';

  @override
  String get selectDocumentType => 'ଡକ୍ୟୁମେଣ୍ଟ ପ୍ରକାର ଚୟନ କରନ୍ତୁ';

  @override
  String get nationalIdAadhaar => 'ଆଧାର କାର୍ଡ';

  @override
  String get panCard => 'ପାନ କାର୍ଡ';

  @override
  String get drivingLicense => 'ଡ୍ରାଇଭିଂ ଲାଇସେନ୍ସ';

  @override
  String get passport => 'ପାସପୋର୍ଟ';

  @override
  String get voterId => 'ଭୋଟର ଆଇଡି';

  @override
  String get verifiedCardholder => 'ପ୍ରମାଣିତ କାର୍ଡଧାରକ';

  @override
  String get unverifiedCardholder => 'ଅପରିଚିତ କାର୍ଡଧାରକ';

  @override
  String get documentVerified => 'ସତ୍ୟ ପ୍ରମାଣିତ ଡକ୍ୟୁମେଣ୍ଟ';

  @override
  String get documentUnverified => 'ଡକ୍ୟୁମେଣ୍ଟ ଅପଠନୀୟ / ଅପ୍ରମାଣିତ';

  @override
  String get editDetailsManually => 'ନିଜେ ବିବରଣୀ ଲେଖନ୍ତୁ';

  @override
  String get crossRegisteredDocs => 'ଡିଜିଲକରରେ ପଞ୍ଜୀକୃତ ଡକ୍ୟୁମେଣ୍ଟ';

  @override
  String get proceedToBiometrics => 'ବାୟୋମେଟ୍ରିକ୍ସକୁ ଆଗକୁ ବଢ଼ନ୍ତୁ';

  @override
  String get reScanDocument => 'ପୁନର୍ବାର ସ୍କାନ କରନ୍ତୁ';

  @override
  String verdict(String status) {
    return '$status';
  }
}
