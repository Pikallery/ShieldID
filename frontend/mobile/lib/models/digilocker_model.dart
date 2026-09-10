import 'package:flutter/material.dart';
import '../constants/theme.dart';

/// Represents a linked government document record fetched via DigiLocker Pull URI API (v1.13)
class DigiLockerLinkedDocument {
  final String docType; // ADHAR, PANCR, DRVLC, PASPR, VOTER
  final String docName;
  final String issuerName; // UIDAI, Income Tax Dept, MoRTH, MEA, ECI
  final String documentNumber;
  final String uri;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final bool isValid;
  final bool isDigitallySigned;
  final String statusDescription;

  const DigiLockerLinkedDocument({
    required this.docType,
    required this.docName,
    required this.issuerName,
    required this.documentNumber,
    required this.uri,
    required this.issueDate,
    this.expiryDate,
    required this.isValid,
    required this.isDigitallySigned,
    required this.statusDescription,
  });

  IconData get icon {
    switch (docType.toUpperCase()) {
      case 'ADHAR':
        return Icons.fingerprint_rounded;
      case 'PANCR':
        return Icons.credit_card_rounded;
      case 'DRVLC':
        return Icons.drive_eta_rounded;
      case 'PASPR':
        return Icons.flight_takeoff_rounded;
      case 'VOTER':
        return Icons.how_to_vote_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  Color get statusColor => isValid ? AppTheme.passGreen : AppTheme.rejectRed;
}

/// Result of DigiLocker Issuer API v1.13 Cross-Verification
class DigiLockerVerificationResult {
  final bool isValidPerson;
  final String responseStatus; // "1" = Success, "0" = Failure / Invalid, "9" = Pending
  final String personName;
  final String nativeName;
  final String dateOfBirth;
  final String gender;
  final String primaryDocNumber;
  final String primaryDocType;
  final String address;
  final String photoUrl;
  final String digiLockerId;
  final String issuerOrgId;
  final bool digitalSignatureValid;
  final double identityMatchConfidence; // 0.0 - 1.0
  final List<DigiLockerLinkedDocument> registeredDocuments;
  final List<String> verificationAnomalies;
  final String rawXmlPayload;

  const DigiLockerVerificationResult({
    required this.isValidPerson,
    required this.responseStatus,
    required this.personName,
    required this.nativeName,
    required this.dateOfBirth,
    required this.gender,
    required this.primaryDocNumber,
    required this.primaryDocType,
    required this.address,
    required this.photoUrl,
    required this.digiLockerId,
    required this.issuerOrgId,
    required this.digitalSignatureValid,
    required this.identityMatchConfidence,
    required this.registeredDocuments,
    this.verificationAnomalies = const [],
    required this.rawXmlPayload,
  });

  int get totalLinkedDocuments => registeredDocuments.length;
  int get activeVerifiedDocuments =>
      registeredDocuments.where((d) => d.isValid).length;
}
