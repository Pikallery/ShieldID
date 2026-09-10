import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum DocumentType {
  passport,
  nationalId,
  driversLicense,
  residencePermit;

  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case DocumentType.passport:
        return l10n.indianPassport;
      case DocumentType.nationalId:
        return l10n.aadhaarCard;
      case DocumentType.driversLicense:
        return l10n.drivingLicense;
      case DocumentType.residencePermit:
        return l10n.panCard;
    }
  }

  String localizedDesc(AppLocalizations l10n) {
    switch (this) {
      case DocumentType.passport:
        return l10n.indianPassportDesc;
      case DocumentType.nationalId:
        return l10n.aadhaarCardDesc;
      case DocumentType.driversLicense:
        return l10n.drivingLicenseDesc;
      case DocumentType.residencePermit:
        return l10n.panCardDesc;
    }
  }

  String get displayName {
    switch (this) {
      case DocumentType.passport:
        return 'Indian Passport (ICAO 9303)';
      case DocumentType.nationalId:
        return 'Aadhaar Card (UIDAI)';
      case DocumentType.driversLicense:
        return "Driver's License (MoRTH)";
      case DocumentType.residencePermit:
        return 'PAN Card / Voter ID (Income Tax / ECI)';
    }
  }

  String get shortName {
    switch (this) {
      case DocumentType.passport:
        return 'Indian Passport';
      case DocumentType.nationalId:
        return 'Aadhaar Card';
      case DocumentType.driversLicense:
        return "Driver's License";
      case DocumentType.residencePermit:
        return 'PAN Card';
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentType.passport:
        return Icons.menu_book_rounded;
      case DocumentType.nationalId:
        return Icons.badge_outlined;
      case DocumentType.driversLicense:
        return Icons.credit_card_outlined;
      case DocumentType.residencePermit:
        return Icons.contact_mail_outlined;
    }
  }

  bool get requiresBackSide {
    switch (this) {
      case DocumentType.passport:
        return false;
      case DocumentType.nationalId:
      case DocumentType.driversLicense:
      case DocumentType.residencePermit:
        return true;
    }
  }

  String get guidanceText {
    switch (this) {
      case DocumentType.passport:
        return 'Open your Indian passport photo page and align it within the frame. Ensure the two-line MRZ (P<IND...) is clear.';
      case DocumentType.nationalId:
        return 'Place your Aadhaar card on a flat surface with minimal glare. Ensure 12-digit UID & QR code are visible.';
      case DocumentType.driversLicense:
        return "Align both edges of your Indian Driver's License inside the viewfinder borders.";
      case DocumentType.residencePermit:
        return 'Position your PAN Card or Voter ID squarely in the frame with clear PAN / EPIC number.';
    }
  }
}

class ExtractedDocumentData {
  final String documentNumber;
  final String fullName;
  final String? firstName;
  final String? lastName;
  final String dateOfBirth;
  final String dateOfExpiry;
  final String dateOfIssue;
  final String nationality;
  final String issuingCountry;
  final String gender;
  final String? mrzCode;
  final Map<String, double> fieldConfidences;

  const ExtractedDocumentData({
    required this.documentNumber,
    required this.fullName,
    this.firstName,
    this.lastName,
    required this.dateOfBirth,
    required this.dateOfExpiry,
    required this.dateOfIssue,
    required this.nationality,
    required this.issuingCountry,
    required this.gender,
    this.mrzCode,
    this.fieldConfidences = const {},
  });

  double get averageConfidence {
    if (fieldConfidences.isEmpty) return 0.95;
    final sum = fieldConfidences.values.reduce((a, b) => a + b);
    return sum / fieldConfidences.length;
  }

  factory ExtractedDocumentData.fromJson(Map<String, dynamic> json) {
    return ExtractedDocumentData(
      documentNumber: json['document_number'] ?? '',
      fullName: json['full_name'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      dateOfBirth: json['date_of_birth'] ?? '',
      dateOfExpiry: json['date_of_expiry'] ?? '',
      dateOfIssue: json['date_of_issue'] ?? '',
      nationality: json['nationality'] ?? '',
      issuingCountry: json['issuing_country'] ?? '',
      gender: json['gender'] ?? '',
      mrzCode: json['mrz_code'],
      fieldConfidences: (json['confidences'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
        'document_number': documentNumber,
        'full_name': fullName,
        'first_name': firstName,
        'last_name': lastName,
        'date_of_birth': dateOfBirth,
        'date_of_expiry': dateOfExpiry,
        'date_of_issue': dateOfIssue,
        'nationality': nationality,
        'issuing_country': issuingCountry,
        'gender': gender,
        'mrz_code': mrzCode,
        'confidences': fieldConfidences,
      };
}

class SecurityFeatures {
  final bool hologramDetected;
  final double hologramConfidence;
  final bool opticalVariableInkChecked;
  final bool microprintValid;
  final bool uvPatternVerified;
  final double substrateScore;

  const SecurityFeatures({
    required this.hologramDetected,
    required this.hologramConfidence,
    required this.opticalVariableInkChecked,
    required this.microprintValid,
    required this.uvPatternVerified,
    required this.substrateScore,
  });

  factory SecurityFeatures.sample() {
    return const SecurityFeatures(
      hologramDetected: true,
      hologramConfidence: 0.96,
      opticalVariableInkChecked: true,
      microprintValid: true,
      uvPatternVerified: true,
      substrateScore: 0.94,
    );
  }

  factory SecurityFeatures.fromJson(Map<String, dynamic> json) =>
      SecurityFeatures(
        hologramDetected: json['hologram_detected'] as bool,
        hologramConfidence: (json['hologram_confidence'] as num).toDouble(),
        opticalVariableInkChecked: json['optical_variable_ink_checked'] as bool,
        microprintValid: json['microprint_valid'] as bool,
        uvPatternVerified: json['uv_pattern_verified'] as bool,
        substrateScore: (json['substrate_score'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'hologram_detected': hologramDetected,
        'hologram_confidence': hologramConfidence,
        'optical_variable_ink_checked': opticalVariableInkChecked,
        'microprint_valid': microprintValid,
        'uv_pattern_verified': uvPatternVerified,
        'substrate_score': substrateScore,
      };
}
