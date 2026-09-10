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
      notes:
          'Biometric landmarks match with 98.4% confidence. No replay, mask or digital presentation attack detected.',
    );
  }

  factory FaceMatchResult.fromJson(Map<String, dynamic> json) =>
      FaceMatchResult(
        similarityScore: (json['similarity_score'] as num).toDouble(),
        isMatch: json['is_match'] as bool,
        livenessPassed: json['liveness_passed'] as bool,
        livenessScore: (json['liveness_score'] as num).toDouble(),
        antiSpoofPassed: json['anti_spoof_passed'] as bool,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'similarity_score': similarityScore,
        'is_match': isMatch,
        'liveness_passed': livenessPassed,
        'liveness_score': livenessScore,
        'anti_spoof_passed': antiSpoofPassed,
        'notes': notes,
      };
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

  factory TamperingResult.fromJson(Map<String, dynamic> json) =>
      TamperingResult(
        isTampered: json['is_tampered'] as bool,
        tamperingScore: (json['tampering_score'] as num).toDouble(),
        edgeIntegrityScore: (json['edge_integrity_score'] as num).toDouble(),
        fontConsistencyScore:
            (json['font_consistency_score'] as num).toDouble(),
        compressionArtifactScore:
            (json['compression_artifact_score'] as num).toDouble(),
        detectedAnomalies:
            List<String>.from(json['detected_anomalies'] as List),
      );

  Map<String, dynamic> toJson() => {
        'is_tampered': isTampered,
        'tampering_score': tamperingScore,
        'edge_integrity_score': edgeIntegrityScore,
        'font_consistency_score': fontConsistencyScore,
        'compression_artifact_score': compressionArtifactScore,
        'detected_anomalies': detectedAnomalies,
      };
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

  factory PredictiveRiskResult.fromJson(Map<String, dynamic> json) =>
      PredictiveRiskResult(
        riskScore: (json['risk_score'] as num).toDouble(),
        riskTier: RiskTier.values.byName(json['risk_tier'] as String),
        riskFactors: List<String>.from(json['risk_factors'] as List),
        recommendation: json['recommendation'] as String,
      );

  Map<String, dynamic> toJson() => {
        'risk_score': riskScore,
        'risk_tier': riskTier.name,
        'risk_factors': riskFactors,
        'recommendation': recommendation,
      };
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

  factory VerificationReport.fromJson(Map<String, dynamic> json) =>
      VerificationReport(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        documentType:
            DocumentType.values.byName(json['document_type'] as String),
        documentData: ExtractedDocumentData.fromJson(
          Map<String, dynamic>.from(json['document_data'] as Map),
        ),
        faceMatch: FaceMatchResult.fromJson(
          Map<String, dynamic>.from(json['face_match'] as Map),
        ),
        tampering: TamperingResult.fromJson(
          Map<String, dynamic>.from(json['tampering'] as Map),
        ),
        predictiveRisk: PredictiveRiskResult.fromJson(
          Map<String, dynamic>.from(json['predictive_risk'] as Map),
        ),
        securityFeatures: SecurityFeatures.fromJson(
          Map<String, dynamic>.from(json['security_features'] as Map),
        ),
        status: VerificationStatus.values.byName(json['status'] as String),
        overallConfidence: (json['overall_confidence'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'document_type': documentType.name,
        'document_data': documentData.toJson(),
        'face_match': faceMatch.toJson(),
        'tampering': tampering.toJson(),
        'predictive_risk': predictiveRisk.toJson(),
        'security_features': securityFeatures.toJson(),
        'status': status.name,
        'overall_confidence': overallConfidence,
      };
}
