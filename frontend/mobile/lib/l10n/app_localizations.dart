import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

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

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('or'),
    Locale('pa'),
    Locale('ta'),
    Locale('te')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ShieldID'**
  String get appTitle;

  /// No description provided for @identityScreeningOs.
  ///
  /// In en, this message translates to:
  /// **'Identity & Screening OS • Active'**
  String get identityScreeningOs;

  /// No description provided for @realTimeScreening.
  ///
  /// In en, this message translates to:
  /// **'REAL-TIME SCREENING'**
  String get realTimeScreening;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Identity & Document Screening'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Instant multi-layer neural scan: OCR extraction, anti-tampering analysis, biometric facial matching, and predictive fraud prevention.'**
  String get heroSubtitle;

  /// No description provided for @startNewScreening.
  ///
  /// In en, this message translates to:
  /// **'START NEW SCREENING'**
  String get startNewScreening;

  /// No description provided for @systemEngine.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM ENGINE'**
  String get systemEngine;

  /// No description provided for @screeningPipelines.
  ///
  /// In en, this message translates to:
  /// **'Screening Pipelines'**
  String get screeningPipelines;

  /// No description provided for @pipelinesActive.
  ///
  /// In en, this message translates to:
  /// **'4 Active'**
  String get pipelinesActive;

  /// No description provided for @aiModelWeights.
  ///
  /// In en, this message translates to:
  /// **'AI Model Weights'**
  String get aiModelWeights;

  /// No description provided for @weightsVersion.
  ///
  /// In en, this message translates to:
  /// **'v2.4 Neural Core'**
  String get weightsVersion;

  /// No description provided for @antiTamperShield.
  ///
  /// In en, this message translates to:
  /// **'Anti-Tamper Shield'**
  String get antiTamperShield;

  /// No description provided for @shieldEnabled.
  ///
  /// In en, this message translates to:
  /// **'Live Enabled'**
  String get shieldEnabled;

  /// No description provided for @recentVerifications.
  ///
  /// In en, this message translates to:
  /// **'Recent Verifications'**
  String get recentVerifications;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noScreeningsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No screenings recorded yet. Tap Start New Screening above.'**
  String get noScreeningsRecorded;

  /// No description provided for @selectDocument.
  ///
  /// In en, this message translates to:
  /// **'Select Document'**
  String get selectDocument;

  /// No description provided for @issuingCountry.
  ///
  /// In en, this message translates to:
  /// **'Issuing Country / Jurisdiction'**
  String get issuingCountry;

  /// No description provided for @republicOfIndia.
  ///
  /// In en, this message translates to:
  /// **'Republic of India (भारत)'**
  String get republicOfIndia;

  /// No description provided for @activeRegistry.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeRegistry;

  /// No description provided for @registryDetails.
  ///
  /// In en, this message translates to:
  /// **'UIDAI • ICAO IND • MoRTH • Income Tax Dept'**
  String get registryDetails;

  /// No description provided for @supportedIdentityDocuments.
  ///
  /// In en, this message translates to:
  /// **'Supported Identity Documents'**
  String get supportedIdentityDocuments;

  /// No description provided for @indianPassport.
  ///
  /// In en, this message translates to:
  /// **'Indian Passport (ICAO 9303)'**
  String get indianPassport;

  /// No description provided for @indianPassportDesc.
  ///
  /// In en, this message translates to:
  /// **'Photo page with MRZ code'**
  String get indianPassportDesc;

  /// No description provided for @aadhaarCard.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar Card (UIDAI)'**
  String get aadhaarCard;

  /// No description provided for @aadhaarCardDesc.
  ///
  /// In en, this message translates to:
  /// **'Front & back capture required'**
  String get aadhaarCardDesc;

  /// No description provided for @drivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s License (MoRTH)'**
  String get drivingLicense;

  /// No description provided for @drivingLicenseDesc.
  ///
  /// In en, this message translates to:
  /// **'Front & back capture required'**
  String get drivingLicenseDesc;

  /// No description provided for @panCard.
  ///
  /// In en, this message translates to:
  /// **'PAN Card (Income Tax Dept)'**
  String get panCard;

  /// No description provided for @panCardDesc.
  ///
  /// In en, this message translates to:
  /// **'Photo & QR code verification'**
  String get panCardDesc;

  /// No description provided for @voterId.
  ///
  /// In en, this message translates to:
  /// **'Voter ID (ECI)'**
  String get voterId;

  /// No description provided for @voterIdDesc.
  ///
  /// In en, this message translates to:
  /// **'EPIC standard verification'**
  String get voterIdDesc;

  /// No description provided for @continueToScan.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE TO DOCUMENT SCAN'**
  String get continueToScan;

  /// No description provided for @documentInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Document & Identity Information'**
  String get documentInfoTitle;

  /// No description provided for @genuineVerifiedDoc.
  ///
  /// In en, this message translates to:
  /// **'GENUINE & VERIFIED DOCUMENT'**
  String get genuineVerifiedDoc;

  /// No description provided for @unverifiedDoc.
  ///
  /// In en, this message translates to:
  /// **'DOCUMENT UNVERIFIED / UNREADABLE'**
  String get unverifiedDoc;

  /// No description provided for @genuineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Structure & Checksums Verified • DigiLocker Issuer API v1.13 Authenticated'**
  String get genuineSubtitle;

  /// No description provided for @unverifiedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Document details could not be authenticated against Central Registry standards'**
  String get unverifiedSubtitle;

  /// No description provided for @genuineBadge.
  ///
  /// In en, this message translates to:
  /// **'GENUINE'**
  String get genuineBadge;

  /// No description provided for @flaggedBadge.
  ///
  /// In en, this message translates to:
  /// **'FLAGGED'**
  String get flaggedBadge;

  /// No description provided for @documentType.
  ///
  /// In en, this message translates to:
  /// **'Document Type'**
  String get documentType;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @digiLockerId.
  ///
  /// In en, this message translates to:
  /// **'DigiLocker ID'**
  String get digiLockerId;

  /// No description provided for @cryptographicSignature.
  ///
  /// In en, this message translates to:
  /// **'Cryptographic Signature'**
  String get cryptographicSignature;

  /// No description provided for @validGovtRoot.
  ///
  /// In en, this message translates to:
  /// **'VALID (Govt Root CA)'**
  String get validGovtRoot;

  /// No description provided for @invalidSignature.
  ///
  /// In en, this message translates to:
  /// **'UNVERIFIED / MISSING'**
  String get invalidSignature;

  /// No description provided for @onFileIssuer.
  ///
  /// In en, this message translates to:
  /// **'On File with Issuer'**
  String get onFileIssuer;

  /// No description provided for @specifiedInRegistry.
  ///
  /// In en, this message translates to:
  /// **'Specified in Registry'**
  String get specifiedInRegistry;

  /// No description provided for @crossRegisteredDigiLocker.
  ///
  /// In en, this message translates to:
  /// **'Cross-Registered Documents in DigiLocker'**
  String get crossRegisteredDigiLocker;

  /// No description provided for @crossRegisteredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Official government registries cross-referenced for this genuine cardholder:'**
  String get crossRegisteredSubtitle;

  /// No description provided for @verifiedRatio.
  ///
  /// In en, this message translates to:
  /// **'3/3 VERIFIED'**
  String get verifiedRatio;

  /// No description provided for @matchBadge.
  ///
  /// In en, this message translates to:
  /// **'MATCH'**
  String get matchBadge;

  /// No description provided for @confirmEditManually.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM / EDIT DETAILS MANUALLY'**
  String get confirmEditManually;

  /// No description provided for @proceedToBiometric.
  ///
  /// In en, this message translates to:
  /// **'PROCEED TO BIOMETRIC SELFIE'**
  String get proceedToBiometric;

  /// No description provided for @antiTamperingHologram.
  ///
  /// In en, this message translates to:
  /// **'Anti-Tampering & Hologram Check'**
  String get antiTamperingHologram;

  /// No description provided for @biometricLiveness.
  ///
  /// In en, this message translates to:
  /// **'Biometric Liveness & Face Match'**
  String get biometricLiveness;

  /// No description provided for @extractedOcrFields.
  ///
  /// In en, this message translates to:
  /// **'Extracted OCR Fields'**
  String get extractedOcrFields;

  /// No description provided for @cameraInitializationFailed.
  ///
  /// In en, this message translates to:
  /// **'Camera initialization failed'**
  String get cameraInitializationFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @auditHistory.
  ///
  /// In en, this message translates to:
  /// **'Audit History'**
  String get auditHistory;

  /// No description provided for @searchHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Search history...'**
  String get searchHistoryHint;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatuses;

  /// No description provided for @passed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get passed;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @noMatchingRecords.
  ///
  /// In en, this message translates to:
  /// **'No matching records'**
  String get noMatchingRecords;

  /// No description provided for @screeningTab.
  ///
  /// In en, this message translates to:
  /// **'Screening'**
  String get screeningTab;

  /// No description provided for @auditHistoryTab.
  ///
  /// In en, this message translates to:
  /// **'Audit History'**
  String get auditHistoryTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @systemConfiguration.
  ///
  /// In en, this message translates to:
  /// **'System Configuration'**
  String get systemConfiguration;

  /// No description provided for @appearancePreferences.
  ///
  /// In en, this message translates to:
  /// **'Appearance & Preferences'**
  String get appearancePreferences;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @darkThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sleek dark interface active'**
  String get darkThemeSubtitle;

  /// No description provided for @lightThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'High-contrast light interface active'**
  String get lightThemeSubtitle;

  /// No description provided for @interfaceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Interface Language'**
  String get interfaceLanguage;

  /// No description provided for @chooseLocale.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred locale'**
  String get chooseLocale;

  /// No description provided for @backendService.
  ///
  /// In en, this message translates to:
  /// **'Backend AI Service'**
  String get backendService;

  /// No description provided for @metricPassRate.
  ///
  /// In en, this message translates to:
  /// **'Pass Rate'**
  String get metricPassRate;

  /// No description provided for @metricFraudBlocked.
  ///
  /// In en, this message translates to:
  /// **'Fraud Blocked'**
  String get metricFraudBlocked;

  /// No description provided for @metricAvgLatency.
  ///
  /// In en, this message translates to:
  /// **'Avg Latency'**
  String get metricAvgLatency;

  /// No description provided for @metricTotalScreened.
  ///
  /// In en, this message translates to:
  /// **'Total Screened'**
  String get metricTotalScreened;

  /// No description provided for @applicantDocument.
  ///
  /// In en, this message translates to:
  /// **'Applicant Document'**
  String get applicantDocument;

  /// No description provided for @verdict.
  ///
  /// In en, this message translates to:
  /// **'{status}'**
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
        'bn',
        'en',
        'gu',
        'hi',
        'kn',
        'ml',
        'mr',
        'or',
        'pa',
        'ta',
        'te'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
