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
            documentNumber: 'P84729104',
            fullName: 'PRIYA ANAND SHARMA',
            firstName: 'PRIYA ANAND',
            lastName: 'SHARMA',
            dateOfBirth: '1994-06-15',
            dateOfExpiry: '2034-08-22',
            dateOfIssue: '2024-08-23',
            nationality: 'IND',
            issuingCountry: 'Republic of India',
            gender: 'F',
            mrzCode:
                'P<INDSHARMA<<PRIYA<ANAND<<<<<<<<<<<<<<<<<<<<<<\nP847291044IND9406155F3408221<<<<<<<<<<<<<<04',
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
            notes:
                'High biometric match confidence. Live micro-expressions detected with 0.994 liveness probability.',
          ),
          tampering: TamperingResult.sampleClean(),
          predictiveRisk: const PredictiveRiskResult(
            riskScore: 4.8,
            riskTier: RiskTier.low,
            riskFactors: [
              'Cryptographic signature verified against Indian MEA / ICAO PKD',
              'Zero suspicious metadata or photo splicing flags',
              'Biometric facial landmark distance matches document photo',
            ],
            recommendation:
                'Auto-Approved: Identity authenticated with high assurance.',
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
            documentNumber: '4829 1049 8821',
            fullName: 'RAHUL ADITYA VERMA',
            firstName: 'RAHUL ADITYA',
            lastName: 'VERMA',
            dateOfBirth: '1988-11-03',
            dateOfExpiry: '2028-03-15',
            dateOfIssue: '2018-03-16',
            nationality: 'IND',
            issuingCountry: 'Republic of India',
            gender: 'M',
            mrzCode:
                'IDINDVERMA<<RAHUL<ADITYA<<<<<<<<<<<<<<<<<<<<<\n4829104988215IND8811036M2803152<<<<<<<<<<<<<<02',
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
            notes:
                'Moderate biometric similarity score. Possible slight age discrepancy between document photo and live selfie.',
          ),
          tampering: const TamperingResult(
            isTampered: false,
            tamperingScore: 0.28,
            edgeIntegrityScore: 0.79,
            fontConsistencyScore: 0.82,
            compressionArtifactScore: 0.75,
            detectedAnomalies: [
              'Minor glare obstruction detected over Aadhaar QR hologram overlay',
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
            recommendation:
                'Routed to Compliance Officer for secondary review.',
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
            documentNumber: 'DL-0420220193842',
            fullName: 'VIKRAM SINGH RATHORE',
            firstName: 'VIKRAM SINGH',
            lastName: 'RATHORE',
            dateOfBirth: '1999-01-01',
            dateOfExpiry: '2029-01-01',
            dateOfIssue: '2019-01-01',
            nationality: 'IND',
            issuingCountry: 'Republic of India',
            gender: 'M',
            mrzCode:
                'DLINDRATHORE<<VIKRAM<SINGH<<<<<<<<<<<<<<<<<<<<<\n04202201938424IND9901014M2901011<<<<<<<<<<<<<<99',
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
            notes:
                'Biometric mismatch. Potential presentation attack detected: digital screen replay frequency detected.',
          ),
          tampering: TamperingResult.sampleTampered(),
          predictiveRisk: const PredictiveRiskResult(
            riskScore: 92.4,
            riskTier: RiskTier.high,
            riskFactors: [
              'Document image splicing detected via Error Level Analysis (ELA)',
              'Biometric face does not match embedded portrait',
              'MRZ / DL checksum failed verification equation',
            ],
            recommendation:
                'Reject and log security incident. High fraud probability.',
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
