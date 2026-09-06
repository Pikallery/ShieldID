import 'package:flutter/material.dart';
import '../constants/theme.dart';
import 'document_model.dart';

enum VerificationStatus {
  pass,
  review,
  reject;

  String get label {
    switch (this) {
      case VerificationStatus.pass:
        return 'PASSED';
      case VerificationStatus.review:
        return 'MANUAL REVIEW';
      case VerificationStatus.reject:
        return 'REJECTED / FRAUD';
    }
  }

  Color get color {
    switch (this) {
      case VerificationStatus.pass:
        return AppTheme.passGreen;
      case VerificationStatus.review:
        return AppTheme.reviewAmber;
      case VerificationStatus.reject:
        return AppTheme.rejectRed;
    }
  }

  IconData get icon {
    switch (this) {
      case VerificationStatus.pass:
        return Icons.verified_user_rounded;
      case VerificationStatus.review:
        return Icons.warning_amber_rounded;
      case VerificationStatus.reject:
        return Icons.gpp_bad_rounded;
    }
  }
}

enum RiskTier {
  low,
  medium,
  high;

  String get label => name.toUpperCase();

  Color get color {
    switch (this) {
      case RiskTier.low:
        return AppTheme.passGreen;
      case RiskTier.medium:
        return AppTheme.reviewAmber;
      case RiskTier.high:
        return AppTheme.rejectRed;
    }
  }
}

class FaceMatchResult {
  final double similarityScore; // 0.0 - 1.0
  final bool isMatch;
  final bool livenessPassed;
  final double livenessScore; // 0.0 - 1.0
  final bool antiSpoofPassed;
  final String? notes;

  const FaceMatchResult({
    required this.similarityScore,
    required this.isMatch,
    required this.livenessPassed,
    required this.livenessScore,
    required this.antiSpoofPassed,
    this.notes,
  });

  factory FaceMatchResult.sample() {
    return const FaceMatchResult(
      similarityScore: 0.984,
      isMatch: true,
      livenessPassed: true,
      livenessScore: 0.992,
      antiSpoofPassed: true,
      notes: 'Biometric landmarks match with 98.4% confidence. No replay, mask or digital presentation attack detected.',
    );
  }
}

class TamperingResult {
  final bool isTampered;
  final double tamperingScore; // 0.0 - 1.0 (higher = more likely tampered)
  final double edgeIntegrityScore;
  final double fontConsistencyScore;
  final double compressionArtifactScore;
  final List<String> detectedAnomalies;

  const TamperingResult({
    required this.isTampered,
    required this.tamperingScore,
    required this.edgeIntegrityScore,
    required this.fontConsistencyScore,
    required this.compressionArtifactScore,
    required this.detectedAnomalies,
  });

  factory TamperingResult.sampleClean() {
    return const TamperingResult(
      isTampered: false,
      tamperingScore: 0.04,
      edgeIntegrityScore: 0.98,
      fontConsistencyScore: 0.97,
      compressionArtifactScore: 0.96,
      detectedAnomalies: [
        'Document border geometry: Continuous and authentic',
        'Font kerning & pixel grid: Uniform alignment',
        'Copy-move forgery check: Passed (No cloned zones)',
        'Error Level Analysis (ELA): Normal compression distribution',
      ],
    );
  }

  factory TamperingResult.sampleTampered() {
    return const TamperingResult(
      isTampered: true,
      tamperingScore: 0.88,
      edgeIntegrityScore: 0.42,
      fontConsistencyScore: 0.35,
      compressionArtifactScore: 0.28,
      detectedAnomalies: [
        'Digital splicing detected around Date of Birth',
        'Inconsistent font weight and resolution in Document Number',
        'Error Level Analysis highlighted pixel artifact disparity',
      ],
    );
  }
}

class PredictiveRiskResult {
  final double riskScore; // 0 - 100
  final RiskTier riskTier;
  final List<String> riskFactors;
  final String recommendation;

  const PredictiveRiskResult({
    required this.riskScore,
    required this.riskTier,
    required this.riskFactors,
    required this.recommendation,
  });

  factory PredictiveRiskResult.sampleLow() {
    return const PredictiveRiskResult(
      riskScore: 6.2,
      riskTier: RiskTier.low,
      riskFactors: [
        'Issuing authority certificate valid',
        'No matching entries in global watchlist',
        'Biometric distance within high-security tolerance',
      ],
      recommendation: 'Automated approval recommended. Identity authenticated.',
    );
  }
}

class VerificationReport {
  final String id;
  final DateTime timestamp;
  final DocumentType documentType;
  final ExtractedDocumentData documentData;
  final FaceMatchResult faceMatch;
  final TamperingResult tampering;
  final PredictiveRiskResult predictiveRisk;
  final SecurityFeatures securityFeatures;
  final VerificationStatus status;
  final double overallConfidence;

  const VerificationReport({
    required this.id,
    required this.timestamp,
    required this.documentType,
    required this.documentData,
    required this.faceMatch,
    required this.tampering,
    required this.predictiveRisk,
    required this.securityFeatures,
    required this.status,
    required this.overallConfidence,
  });
}
