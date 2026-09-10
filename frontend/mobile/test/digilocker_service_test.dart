import 'package:flutter_test/flutter_test.dart';
import 'package:shield_id_mobile/models/document_model.dart';
import 'package:shield_id_mobile/services/digilocker_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DigiLocker Issuer API v1.13 Verification Tests', () {
    late DigiLockerService service;

    setUp(() {
      service = DigiLockerService();
    });

    test('Authentic document verification produces Valid Person with Green Tick data', () async {
      final result = await service.verifyDocumentAndPullRecords(
        docType: DocumentType.nationalId,
        rawScannedData: 'SAMPLE_UIDAI_QR',
        simulateFakeOrExpired: false,
      );

      expect(result.isValidPerson, isTrue);
      expect(result.responseStatus, '1');
      expect(result.personName, 'Aarav Sharma');
      expect(result.nativeName, 'आरव शर्मा');
      expect(result.digitalSignatureValid, isTrue);
      expect(result.identityMatchConfidence, greaterThan(0.95));
      expect(result.registeredDocuments.length, greaterThanOrEqualTo(4));
      expect(result.rawXmlPayload, contains('PullURIResponse'));
      expect(result.rawXmlPayload, contains('VERIFIED_GOV_ROOT_CA'));
    });

    test('Fake or expired document verification produces Invalid Person with Red Cross and anomalies', () async {
      final result = await service.verifyDocumentAndPullRecords(
        docType: DocumentType.driversLicense,
        rawScannedData: 'SAMPLE_TAMPERED_QR',
        simulateFakeOrExpired: true,
      );

      expect(result.isValidPerson, isFalse);
      expect(result.responseStatus, '0');
      expect(result.digitalSignatureValid, isFalse);
      expect(result.identityMatchConfidence, lessThan(0.5));
      expect(result.verificationAnomalies, isNotEmpty);
      expect(result.rawXmlPayload, contains('DL_404_NOT_FOUND'));
    });
  });
}
