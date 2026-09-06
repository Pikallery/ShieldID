import '../models/document_model.dart';
import '../models/verification_result.dart';

class MockData {
  static VerificationReport generateMockReport({
    required DocumentType docType,
    VerificationStatus status = VerificationStatus.pass,
  }) {
    switch (status) {
      case VerificationStatus.pass:
        return VerificationReport(
          id: 'SHIELD-8924-A',
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          documentType: docType,
          status: VerificationStatus.pass,
          overallConfidence: 0.982,
          documentData: const ExtractedDocumentData(
            documentNumber: 'P89230491',
            fullName: 'SARAH ELIZABETH JENKINS',
            firstName: 'SARAH ELIZABETH',
            lastName: 'JENKINS',
            dateOfBirth: '1992-04-18',
            dateOfExpiry: '2031-08-22',
            dateOfIssue: '2021-08-23',
            nationality: 'USA',
            issuingCountry: 'United States of America',
            gender: 'F',
            mrzCode: 'P<USAJENKINS<<SARAH<ELIZABETH<<<<<<<<<<<<<<<\nP892304914USA9204185F3108221<<<<<<<<<<<<<<06',
            fieldConfidences: {
              'Document Number': 0.99,
              'Full Name': 0.98,
              'Date of Birth': 0.99,
              'Date of Expiry': 0.97,
              'MRZ Checksum': 1.00,
            },
          ),
          faceMatch: const FaceMatchResult(
            similarityScore: 0.986,
            isMatch: true,
            livenessPassed: true,
            livenessScore: 0.994,
            antiSpoofPassed: true,
            notes: 'High biometric match confidence. Live micro-expressions detected with 0.994 liveness probability.',
          ),
          tampering: TamperingResult.sampleClean(),
          predictiveRisk: const PredictiveRiskResult(
            riskScore: 4.8,
            riskTier: RiskTier.low,
            riskFactors: [
              'Cryptographic signature verified against ICAO PKD',
              'Zero suspicious metadata or photo splicing flags',
              'Biometric facial landmark distance matches document photo',
            ],
            recommendation: 'Auto-Approved: Identity authenticated with high assurance.',
          ),
          securityFeatures: SecurityFeatures.sample(),
        );

      case VerificationStatus.review:
        return VerificationReport(
          id: 'SHIELD-5102-R',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          documentType: docType,
          status: VerificationStatus.review,
          overallConfidence: 0.742,
          documentData: const ExtractedDocumentData(
            documentNumber: 'ID77410928',
            fullName: 'ALEXANDRE DUBOIS',
            firstName: 'ALEXANDRE',
            lastName: 'DUBOIS',
            dateOfBirth: '1987-11-03',
            dateOfExpiry: '2027-03-15',
            dateOfIssue: '2017-03-16',
            nationality: 'FRA',
            issuingCountry: 'France',
            gender: 'M',
            mrzCode: 'IDFRADUBOIS<<ALEXANDRE<<<<<<<<<<<<<<<<<<<<<<\n77410928<4FRA8711036M2703152<<<<<<<<<<<<<<02',
            fieldConfidences: {
              'Document Number': 0.91,
              'Full Name': 0.84,
              'Date of Birth': 0.78,
              'Date of Expiry': 0.85,
            },
          ),
          faceMatch: const FaceMatchResult(
            similarityScore: 0.812,
            isMatch: true,
            livenessPassed: true,
            livenessScore: 0.89,
            antiSpoofPassed: true,
            notes: 'Moderate biometric similarity score. Possible slight age discrepancy between document photo and live selfie.',
          ),
          tampering: const TamperingResult(
            isTampered: false,
            tamperingScore: 0.28,
            edgeIntegrityScore: 0.79,
            fontConsistencyScore: 0.82,
            compressionArtifactScore: 0.75,
            detectedAnomalies: [
              'Minor glare obstruction detected over hologram overlay',
              'Subtle font compression anomaly in date field',
            ],
          ),
          predictiveRisk: const PredictiveRiskResult(
            riskScore: 38.5,
            riskTier: RiskTier.medium,
            riskFactors: [
              'Hologram reflectivity slightly obscured by environmental glare',
              'Secondary visual manual inspection advised',
            ],
            recommendation: 'Routed to Compliance Officer for secondary review.',
          ),
          securityFeatures: const SecurityFeatures(
            hologramDetected: true,
            hologramConfidence: 0.72,
            opticalVariableInkChecked: true,
            microprintValid: true,
            uvPatternVerified: false,
            substrateScore: 0.81,
          ),
        );

      case VerificationStatus.reject:
        return VerificationReport(
          id: 'SHIELD-1049-X',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          documentType: docType,
          status: VerificationStatus.reject,
          overallConfidence: 0.298,
          documentData: const ExtractedDocumentData(
            documentNumber: 'DL99301944',
            fullName: 'MARCUS VANCE',
            firstName: 'MARCUS',
            lastName: 'VANCE',
            dateOfBirth: '1999-01-01',
            dateOfExpiry: '2029-01-01',
            dateOfIssue: '2019-01-01',
            nationality: 'GBR',
            issuingCountry: 'United Kingdom',
            gender: 'M',
            mrzCode: 'DLGBRVANCE<<MARCUS<<<<<<<<<<<<<<<<<<<<<<<<<<\n99301944<1GBR9901014M2901011<<<<<<<<<<<<<<99',
            fieldConfidences: {
              'Document Number': 0.45,
              'Full Name': 0.62,
              'Date of Birth': 0.31,
            },
          ),
          faceMatch: const FaceMatchResult(
            similarityScore: 0.342,
            isMatch: false,
            livenessPassed: false,
            livenessScore: 0.41,
            antiSpoofPassed: false,
            notes: 'Biometric mismatch. Potential presentation attack detected: digital screen replay frequency detected.',
          ),
          tampering: TamperingResult.sampleTampered(),
          predictiveRisk: const PredictiveRiskResult(
            riskScore: 92.4,
            riskTier: RiskTier.high,
            riskFactors: [
              'Document image splicing detected via Error Level Analysis (ELA)',
              'Biometric face does not match embedded portrait',
              'MRZ checksum failed verification equation',
            ],
            recommendation: 'Reject and log security incident. High fraud probability.',
          ),
          securityFeatures: const SecurityFeatures(
            hologramDetected: false,
            hologramConfidence: 0.12,
            opticalVariableInkChecked: false,
            microprintValid: false,
            uvPatternVerified: false,
            substrateScore: 0.22,
          ),
        );
    }
  }

  static List<VerificationReport> getInitialHistory() {
    return [
      generateMockReport(
        docType: DocumentType.passport,
        status: VerificationStatus.pass,
      ),
      generateMockReport(
        docType: DocumentType.nationalId,
        status: VerificationStatus.review,
      ),
      generateMockReport(
        docType: DocumentType.driversLicense,
        status: VerificationStatus.reject,
      ),
    ];
  }
}
