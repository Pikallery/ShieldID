import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('bn'),
    Locale('te'),
    Locale('ta'),
    Locale('mr'),
    Locale('gu'),
    Locale('kn'),
    Locale('ml'),
    Locale('pa'),
    Locale('or'),
  ];

  String get appTitle;
  String get antiTamperingHologram;
  String get extractedOcrFields;
  String get cameraInitializationFailed;
  String get retry;
  String get auditHistory;
  String get searchHistoryHint;
  String get allStatuses;
  String get passed;
  String get review;
  String get rejected;
  String get noMatchingRecords;
  String verdict(String status);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'hi',
        'bn',
        'te',
        'ta',
        'mr',
        'gu',
        'kn',
        'ml',
        'pa',
        'or',
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([super.locale = 'hi']);
  @override
  String get appTitle => 'ShieldID';
  @override
  String get antiTamperingHologram => 'एंटी-छेड़छाड़ और होलोग्राम जांच';
  @override
  String get extractedOcrFields => 'निकाले गए ओसीआर फ़ील्ड';
  @override
  String get cameraInitializationFailed => 'कैमरा प्रारंभ विफल';
  @override
  String get retry => 'पुनः प्रयास करें';
  @override
  String get auditHistory => 'ऑडिट इतिहास';
  @override
  String get searchHistoryHint => 'इतिहास खोजें';
  @override
  String get allStatuses => 'सभी स्थितियाँ';
  @override
  String get passed => 'उत्तीर्ण';
  @override
  String get review => 'समीक्षा';
  @override
  String get rejected => 'अस्वीकृत';
  @override
  String get noMatchingRecords => 'कोई मेल खाने वाला रिकॉर्ड नहीं';
  @override
  String verdict(String status) => status;
}

class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([super.locale = 'bn']);
  @override
  String get appTitle => 'ShieldID';
  @override
  String get antiTamperingHologram => 'অ্যান্টি-টেম্পারিং ও হোলোগ্রাম যাচাই';
  @override
  String get extractedOcrFields => 'নিষ্কাশিত ওসিআর ক্ষেত্র';
  @override
  String get cameraInitializationFailed => 'ক্যামেরা চালু করতে ব্যর্থ হয়েছে';
  @override
  String get retry => 'পুনরায় চেষ্টা করুন';
  @override
  String get auditHistory => 'অডিট ইতিহাস';
  @override
  String get searchHistoryHint => 'ইতিহাস অনুসন্ধান';
  @override
  String get allStatuses => 'সমস্ত স্ট্যাটাস';
  @override
  String get passed => 'উত্তীর্ণ';
  @override
  String get review => 'পর্যালোচনা';
  @override
  String get rejected => 'প্রত্যাখ্যাত';
  @override
  String get noMatchingRecords => 'কোনো রেকর্ড পাওয়া যায়নি';
  @override
  String verdict(String status) => status;
}

class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([super.locale = 'te']);
  @override
  String get appTitle => 'ShieldID';
  @override
  String get antiTamperingHologram => 'యాంటీ-టాంపరింగ్ మరియు హోలోగ్రామ్ తనిఖీ';
  @override
  String get extractedOcrFields => 'సంగ్రహించిన OCR ఫీల్డ్‌లు';
  @override
  String get cameraInitializationFailed => 'కెమెరా ప్రారంభం విఫలమైంది';
  @override
  String get retry => 'మళ్లీ ప్రయత్నించండి';
  @override
  String get auditHistory => 'ఆడిట్ చరిత్ర';
  @override
  String get searchHistoryHint => 'చరిత్రను శోధించండి';
  @override
  String get allStatuses => 'అన్ని స్థితులు';
  @override
  String get passed => 'పాస్ అయింది';
  @override
  String get review => 'సమీక్ష';
  @override
  String get rejected => 'తిరస్కరించబడింది';
  @override
  String get noMatchingRecords => 'సరిపోలే రికార్డులు లేవు';
  @override
  String verdict(String status) => status;
}

class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([super.locale = 'ta']);
  @override
  String get appTitle => 'ShieldID';
  @override
  String get antiTamperingHologram => 'மோசடி தடுப்பு மற்றும் ஹோலோகிராம் சரிபார்ப்பு';
  @override
  String get extractedOcrFields => 'பிரித்தெடுக்கப்பட்ட OCR புலங்கள்';
  @override
  String get cameraInitializationFailed => 'கேமரா துவக்கம் தோல்வியடைந்தது';
  @override
  String get retry => 'மீண்டும் முயற்சிக்கவும்';
  @override
  String get auditHistory => 'தணிக்கை வரலாறு';
  @override
  String get searchHistoryHint => 'வரலாற்றைத் தேடுக';
  @override
  String get allStatuses => 'அனைத்து நிலைகளும்';
  @override
  String get passed => 'வெற்றி';
  @override
  String get review => 'மறுஆய்வு';
  @override
  String get rejected => 'நிராகரிக்கப்பட்டது';
  @override
  String get noMatchingRecords => 'பொருந்தும் பதிவுகள் இல்லை';
  @override
  String verdict(String status) => status;
}

class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([super.locale = 'mr']);
  @override
  String get appTitle => 'ShieldID';
  @override
  String get antiTamperingHologram => 'अँटी-टॅम्परिंग आणि होलोग्राम तपासणी';
  @override
  String get extractedOcrFields => 'काढलेले OCR फील्ड्स';
  @override
  String get cameraInitializationFailed => 'कॅमेरा सुरू करण्यात अयशस्वी';
  @override
  String get retry => 'पुन्हा प्रयत्न करा';
  @override
  String get auditHistory => 'ऑडिट इतिहास';
  @override
  String get searchHistoryHint => 'इतिहास शोधा';
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
  String verdict(String status) => status;
}

class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([super.locale = 'gu']);
  @override
  String get appTitle => 'ShieldID';
  @override
  String get antiTamperingHologram => 'છેડછાડ વિરોધી અને હોલોગ્રામ ચકાસણી';
  @override
  String get extractedOcrFields => 'કાઢવામાં આવેલ OCR ફીલ્ડ્સ';
  @override
  String get cameraInitializationFailed => 'કૅમેરા શરૂ કરવામાં નિષ્ફળ';
  @override
  String get retry => 'ફરી પ્રયાસ કરો';
  @override
  String get auditHistory => 'ઓડિટ ઇતિહાસ';
  @override
  String get searchHistoryHint => 'ઇતિહાસ શોધો';
  @override
  String get allStatuses => 'તમામ સ્થિતિઓ';
  @override
  String get passed => 'પાસ થયું';
  @override
  String get review => 'સમીક્ષા';
  @override
  String get rejected => 'અસ્વીકાર્ય';
  @override
  String get noMatchingRecords => 'કોઈ મેળ ખાતા રેકોર્ડ નથી';
  @override
  String verdict(String status) => status;
}

class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([super.locale = 'kn']);
  @override
  String get appTitle => 'ShieldID';
  @override
  String get antiTamperingHologram => 'ಟ್ಯಾಂಪರಿಂಗ್ ವಿರೋಧಿ ಮತ್ತು ಹೊಲೊಗ್ರಾಮ್ ಪರಿಶೀಲನೆ';
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
  String verdict(String status) => status;
}

class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([super.locale = 'ml']);
  @override
  String get appTitle => 'ShieldID';
  @override
  String get antiTamperingHologram => 'വ്യാജനിർമ്മാണ തടയലും ഹോളോഗ്രാം പരിശോധനയും';
  @override
  String get extractedOcrFields => 'എക്‌സ്‌ട്രാക്‌റ്റ് ചെയ്‌ത OCR ഫീൽഡുകൾ';
  @override
  String get cameraInitializationFailed => 'ക്യാമറ ആരംഭിക്കുന്നത് പരാജയപ്പെട്ടു';
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
  String get review => 'പുനരവലോകനം';
  @override
  String get rejected => 'നിരസിച്ചു';
  @override
  String get noMatchingRecords => 'പൊരുത്തപ്പെടുന്ന റെക്കോർഡുകളില്ല';
  @override
  String verdict(String status) => status;
}

class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([super.locale = 'pa']);
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
  String verdict(String status) => status;
}

class AppLocalizationsOr extends AppLocalizations {
  AppLocalizationsOr([super.locale = 'or']);
  @override
  String get appTitle => 'ShieldID';
  @override
  String get antiTamperingHologram => 'ଟ୍ୟାମ୍ପରିଂ ବିରୋଧୀ ଏବଂ ହୋଲୋଗ୍ରାମ ଯାଞ୍ଚ';
  @override
  String get extractedOcrFields => 'ନିଷ୍କାସିତ OCR କ୍ଷେତ୍ର';
  @override
  String get cameraInitializationFailed => 'କ୍ୟାମେରା ଆରମ୍ଭ ବିଫଳ ହେଲା';
  @override
  String get retry => 'ପୁନଃ ଚେଷ୍ଟା କରନ୍ତୁ';
  @override
  String get auditHistory => 'ଅଡିଟ୍ ଇତିହାସ';
  @override
  String get searchHistoryHint => 'ଇତିହାସ ଖୋଜନ୍ତୁ';
  @override
  String get allStatuses => 'ସମସ୍ତ ସ୍ଥିତି';
  @override
  String get passed => 'ପାସ୍ ହୋଇଛି';
  @override
  String get review => 'ସମୀକ୍ଷା';
  @override
  String get rejected => 'ପ୍ରତ୍ୟାଖ୍ୟାନ';
  @override
  String get noMatchingRecords => 'କୌଣସି ରେକର୍ଡ ମିଳିଲା ନାହିଁ';
  @override
  String verdict(String status) => status;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'bn':
      return AppLocalizationsBn();
    case 'te':
      return AppLocalizationsTe();
    case 'ta':
      return AppLocalizationsTa();
    case 'mr':
      return AppLocalizationsMr();
    case 'gu':
      return AppLocalizationsGu();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'pa':
      return AppLocalizationsPa();
    case 'or':
      return AppLocalizationsOr();
    default:
      return AppLocalizationsEn();
  }
}
