import '../models/document_model.dart';
import '../models/verification_result.dart';

class MockData {
  static VerificationReport generateEmptyFallbackReport({
    required DocumentType docType,
    String? rawExtractedText,
    String? capturedDocNumber,
    String? capturedName,
  }) {
    final hasData = (capturedName != null && capturedName.isNotEmpty) ||
        (capturedDocNumber != null && capturedDocNumber.isNotEmpty);

    return VerificationReport(
      id: 'SHIELD-${DateTime.now().millisecondsSinceEpoch % 100000}',
      timestamp: DateTime.now(),
      documentType: docType,
      status: hasData ? VerificationStatus.review : VerificationStatus.reject,
      overallConfidence: hasData ? 0.70 : 0.20,
      documentData: ExtractedDocumentData(
        documentNumber: capturedDocNumber ?? '',
        fullName: capturedName ?? '',
        firstName: capturedName?.split(' ').first,
        lastName: (capturedName != null && capturedName.split(' ').length > 1)
            ? capturedName.split(' ').last
            : null,
        dateOfBirth: '',
        dateOfExpiry: '',
        dateOfIssue: '',
        nationality: 'Indian',
        issuingCountry: 'India',
        gender: '',
        mrzCode: null,
        fieldConfidences: const {
          'Document Quality': 0.65,
        },
      ),
      faceMatch: const FaceMatchResult(
        similarityScore: 0.0,
        isMatch: false,
        livenessPassed: false,
        livenessScore: 0.0,
        antiSpoofPassed: false,
        notes: 'Pending biometric selfie capture and facial matching.',
      ),
      tampering: const TamperingResult(
        isTampered: false,
        tamperingScore: 0.15,
        edgeIntegrityScore: 0.85,
        fontConsistencyScore: 0.85,
        compressionArtifactScore: 0.85,
        detectedAnomalies: [
          'Optical image analysis completed',
        ],
      ),
      predictiveRisk: PredictiveRiskResult(
        riskScore: hasData ? 35.0 : 80.0,
        riskTier: hasData ? RiskTier.medium : RiskTier.high,
        riskFactors: hasData
            ? const ['Document captured via mobile optical scanner']
            : const ['Document text unreadable or camera frame misaligned'],
        recommendation: hasData
            ? 'Optical scan complete. Proceed to biometric selfie.'
            : 'Please hold document closer and avoid glare.',
      ),
      securityFeatures: const SecurityFeatures(
        hologramDetected: true,
        hologramConfidence: 0.80,
        opticalVariableInkChecked: true,
        microprintValid: true,
        uvPatternVerified: true,
        substrateScore: 0.85,
      ),
    );
  }

  static List<VerificationReport> getInitialHistory() {
    return [];
  }
}
