// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ShieldID';

  @override
  String get identityScreeningOs => 'Identity & Screening OS • Active';

  @override
  String get realTimeScreening => 'REAL-TIME SCREENING';

  @override
  String get heroTitle => 'AI-Powered Identity & Document Screening';

  @override
  String get heroSubtitle =>
      'Instant multi-layer neural scan: OCR extraction, anti-tampering analysis, biometric facial matching, and predictive fraud prevention.';

  @override
  String get startNewScreening => 'START NEW SCREENING';

  @override
  String get systemEngine => 'SYSTEM ENGINE';

  @override
  String get screeningPipelines => 'Screening Pipelines';

  @override
  String get pipelinesActive => '4 Active';

  @override
  String get aiModelWeights => 'AI Model Weights';

  @override
  String get weightsVersion => 'v2.4 Neural Core';

  @override
  String get antiTamperShield => 'Anti-Tamper Shield';

  @override
  String get shieldEnabled => 'Live Enabled';

  @override
  String get recentVerifications => 'Recent Verifications';

  @override
  String get viewAll => 'View All';

  @override
  String get noScreeningsRecorded =>
      'No screenings recorded yet. Tap Start New Screening above.';

  @override
  String get selectDocument => 'Select Document';

  @override
  String get issuingCountry => 'Issuing Country / Jurisdiction';

  @override
  String get republicOfIndia => 'Republic of India (भारत)';

  @override
  String get activeRegistry => 'ACTIVE';

  @override
  String get registryDetails => 'UIDAI • ICAO IND • MoRTH • Income Tax Dept';

  @override
  String get supportedIdentityDocuments => 'Supported Identity Documents';

  @override
  String get indianPassport => 'Indian Passport (ICAO 9303)';

  @override
  String get indianPassportDesc => 'Photo page with MRZ code';

  @override
  String get aadhaarCard => 'Aadhaar Card (UIDAI)';

  @override
  String get aadhaarCardDesc => 'Front & back capture required';

  @override
  String get drivingLicense => 'Driver\'s License (MoRTH)';

  @override
  String get drivingLicenseDesc => 'Front & back capture required';

  @override
  String get panCard => 'PAN Card (Income Tax Dept)';

  @override
  String get panCardDesc => 'Photo & QR code verification';

  @override
  String get voterId => 'Voter ID (ECI)';

  @override
  String get voterIdDesc => 'EPIC standard verification';

  @override
  String get continueToScan => 'CONTINUE TO DOCUMENT SCAN';

  @override
  String get documentInfoTitle => 'Document & Identity Information';

  @override
  String get genuineVerifiedDoc => 'GENUINE & VERIFIED DOCUMENT';

  @override
  String get unverifiedDoc => 'DOCUMENT UNVERIFIED / UNREADABLE';

  @override
  String get genuineSubtitle =>
      'Structure & Checksums Verified • DigiLocker Issuer API v1.13 Authenticated';

  @override
  String get unverifiedSubtitle =>
      'Document details could not be authenticated against Central Registry standards';

  @override
  String get genuineBadge => 'GENUINE';

  @override
  String get flaggedBadge => 'FLAGGED';

  @override
  String get documentType => 'Document Type';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get gender => 'Gender';

  @override
  String get digiLockerId => 'DigiLocker ID';

  @override
  String get cryptographicSignature => 'Cryptographic Signature';

  @override
  String get validGovtRoot => 'VALID (Govt Root CA)';

  @override
  String get invalidSignature => 'UNVERIFIED / MISSING';

  @override
  String get onFileIssuer => 'On File with Issuer';

  @override
  String get specifiedInRegistry => 'Specified in Registry';

  @override
  String get crossRegisteredDigiLocker =>
      'Cross-Registered Documents in DigiLocker';

  @override
  String get crossRegisteredSubtitle =>
      'Official government registries cross-referenced for this genuine cardholder:';

  @override
  String get verifiedRatio => '3/3 VERIFIED';

  @override
  String get matchBadge => 'MATCH';

  @override
  String get confirmEditManually => 'CONFIRM / EDIT DETAILS MANUALLY';

  @override
  String get proceedToBiometric => 'PROCEED TO BIOMETRIC SELFIE';

  @override
  String get antiTamperingHologram => 'Anti-Tampering & Hologram Check';

  @override
  String get biometricLiveness => 'Biometric Liveness & Face Match';

  @override
  String get extractedOcrFields => 'Extracted OCR Fields';

  @override
  String get cameraInitializationFailed => 'Camera initialization failed';

  @override
  String get retry => 'Retry';

  @override
  String get auditHistory => 'Audit History';

  @override
  String get searchHistoryHint => 'Search history...';

  @override
  String get allStatuses => 'All Statuses';

  @override
  String get passed => 'Passed';

  @override
  String get review => 'Review';

  @override
  String get rejected => 'Rejected';

  @override
  String get noMatchingRecords => 'No matching records';

  @override
  String get screeningTab => 'Screening';

  @override
  String get auditHistoryTab => 'Audit History';

  @override
  String get settingsTab => 'Settings';

  @override
  String get systemConfiguration => 'System Configuration';

  @override
  String get appearancePreferences => 'Appearance & Preferences';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get darkThemeSubtitle => 'Sleek dark interface active';

  @override
  String get lightThemeSubtitle => 'High-contrast light interface active';

  @override
  String get interfaceLanguage => 'Interface Language';

  @override
  String get chooseLocale => 'Choose your preferred locale';

  @override
  String get backendService => 'Backend AI Service';

  @override
  String verdict(String status) {
    return '$status';
  }
}
