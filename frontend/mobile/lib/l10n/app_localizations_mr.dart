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
  String get antiTamperingHologram => 'छेडछाड विरोधी आणि होलोग्राम पडताळणी';

  @override
  String get extractedOcrFields => 'काढलेले OCR फील्ड';

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
  String verdict(String status) {
    return '$status';
  }
}
