import 'package:flutter/material.dart';

enum DocumentType {
  passport,
  nationalId,
  driversLicense,
  residencePermit;

  String get displayName {
    switch (this) {
      case DocumentType.passport:
        return 'Passport (ICAO 9303)';
      case DocumentType.nationalId:
        return 'National Identity Card';
      case DocumentType.driversLicense:
        return "Driver's License";
      case DocumentType.residencePermit:
        return 'Residence Permit';
    }
  }

  String get shortName {
    switch (this) {
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.nationalId:
        return 'National ID';
      case DocumentType.driversLicense:
        return "Driver's License";
      case DocumentType.residencePermit:
        return 'Residence Permit';
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
        return 'Open your passport photo page and align it within the frame. Ensure the two-line MRZ at the bottom is clear.';
      case DocumentType.nationalId:
        return 'Place your national ID on a flat, dark surface with minimal light reflection.';
      case DocumentType.driversLicense:
        return "Align both edges of your driver's license inside the viewfinder borders.";
      case DocumentType.residencePermit:
        return 'Position the front of your residence card squarely in the frame.';
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
}
