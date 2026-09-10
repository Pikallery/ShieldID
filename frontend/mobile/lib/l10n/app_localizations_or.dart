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
  String verdict(String status) {
    return '$status';
  }
}
