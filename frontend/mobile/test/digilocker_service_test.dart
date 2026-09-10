import 'package:flutter_test/flutter_test.dart';
import 'package:shield_id_mobile/models/document_model.dart';
import 'package:shield_id_mobile/services/digilocker_service.dart';
import 'package:shield_id_mobile/services/document_parser_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DigiLocker Issuer API v1.13 Verification & Checksum Tests', () {
    late DigiLockerService service;
    late DocumentParserService parser;

    setUp(() {
      service = DigiLockerService();
      parser = DocumentParserService();
    });

    test('Verhoeff Checksum correctly validates genuine 12-digit Aadhaar', () {
      expect(parser.validateAadhaarVerhoeff('234567890124'), isTrue);
      expect(parser.validateAadhaarVerhoeff('234567890129'), isFalse);
    });

    test('PAN format validation verifies 10-char alphanumeric structure', () {
      expect(parser.validatePanFormat('ABCPS1234F'), isTrue);
      expect(parser.validatePanFormat('ABCD1234F'), isFalse);
      expect(parser.validatePanFormat('12345ABCDE'), isFalse);
    });

    test('Fuzzy PAN OCR corrector fixes optical character confusions', () {
      expect(parser.tryFixPanSubstitutions('ABCPS1234F'), 'ABCPS1234F');
      expect(parser.tryFixPanSubstitutions('0BCPSI234F'), 'OBCPS1234F');
    });

    test('Filters out Hindi/English header noise and extracts genuine cardholder name', () {
      const noisyOcr = '''
      y STaE fara HIVA WATE
      INCOME TAX DEPARTMENT
      GOVT. OF INDIA
      SAI PRADYUMNA SAMAL
      BIBHUTI BHUSAN SAMAL
      31/10/2005
      ABCPS1234F
      ''';

      final parsed = parser.parseRawDocumentText(
        docType: DocumentType.residencePermit,
        rawText: noisyOcr,
      );

      expect(parsed.fullName, 'SAI PRADYUMNA SAMAL');
      expect(parsed.documentNumber, 'ABCPS1234F');
      expect(parsed.dateOfBirth, '31/10/2005');
    });

    test('Sanitizes noisy OCR prefix and suffix tags (e.g. A AT SAMAL TGA -> SAMAL)', () {
      const noisyOcr = '''
      INCOME TAX DEPARTMENT
      GOVT OF INDIA
      A AT SAMAL TGA
      01/01/2000
      SFAPS5084D
      ''';

      final parsed = parser.parseRawDocumentText(
        docType: DocumentType.residencePermit,
        rawText: noisyOcr,
      );

      expect(parsed.fullName, 'SAMAL');
      expect(parsed.documentNumber, 'SFAPS5084D');
    });

    test('Rejects OCR fragments like CREE and prevents false name extraction', () {
      const noisyOcr = '''
      INCOME TAX DEPARTMENT
      GOVT OF INDIA
      CREE
      ''';

      final parsed = parser.parseRawDocumentText(
        docType: DocumentType.residencePermit,
        rawText: noisyOcr,
      );

      expect(parsed.fullName, isEmpty);
    });

    test('Rejects Devanagari OCR transliteration noise like LOSRAM ATT', () {
      const noisyOcr = '''
      LOSRAM ATT
      INCOME TAX DEPARTMENT
      GOVT OF INDIA
      ''';

      final parsed = parser.parseRawDocumentText(
        docType: DocumentType.residencePermit,
        rawText: noisyOcr,
      );

      expect(parsed.fullName, isEmpty);
    });

    test('Extracts spaced PAN number SFAPS 5084D and anchors cardholder surname SAMAL', () {
      const noisyOcr = '''
      INCOME TAX DEPARTMENT
      GOVT OF INDIA
      SAI PRADYUMNA SAMAL
      31/10/2005
      SFAPS 5084D
      ''';

      final parsed = parser.parseRawDocumentText(
        docType: DocumentType.residencePermit,
        rawText: noisyOcr,
      );

      expect(parsed.documentNumber, 'SFAPS5084D');
      expect(parsed.fullName, 'SAI PRADYUMNA SAMAL');
    });

    test('Rejects 4-letter token SHAD and correctly extracts multi-word cardholder name', () {
      const noisyOcr = '''
      SHAD
      INCOME TAX DEPARTMENT
      GOVT OF INDIA
      SAI PRADYUMNA SAMAL
      31/10/2005
      SFAPS5084D
      ''';

      final parsed = parser.parseRawDocumentText(
        docType: DocumentType.residencePermit,
        rawText: noisyOcr,
      );

      expect(parsed.documentNumber, 'SFAPS5084D');
      expect(parsed.fullName, 'SAI PRADYUMNA SAMAL');
    });

    test('Single-word candidate starting with S must be >= 5 chars (e.g. SAMAL, not SHAD)', () {
      const noisyOcr = '''
      SHAD
      INCOME TAX DEPARTMENT
      GOVT OF INDIA
      31/10/2005
      SFAPS5084D
      ''';

      final parsed = parser.parseRawDocumentText(
        docType: DocumentType.residencePermit,
        rawText: noisyOcr,
      );

      expect(parsed.documentNumber, 'SFAPS5084D');
      expect(parsed.fullName, isEmpty);
    });

    test('Parses PAN QR code payload accurately', () {
      const qrPayload = '{"qr":"SAI PRADYUMNA SAMAL^BIBHUTI BHUSAN SAMAL^31/10/2005^ABCPS1234F","ocr":""}';

      final parsed = parser.parseRawDocumentText(
        docType: DocumentType.residencePermit,
        rawText: qrPayload,
      );

      expect(parsed.fullName, 'SAI PRADYUMNA SAMAL');
      expect(parsed.documentNumber, 'ABCPS1234F');
      expect(parsed.dateOfBirth, '31/10/2005');
    });

    test('MoRTH Driving License format validation verifies state code and roll', () {
      expect(parser.validateDrivingLicenseFormat('DL-0420180054321'), isTrue);
      expect(parser.validateDrivingLicenseFormat('XX-0000000000000'), isFalse);
    });

    test('Authentic extracted document produces Valid Genuine Document with Green Tick', () async {
      const extracted = ExtractedDocumentData(
        documentNumber: '2345 6789 0124',
        fullName: 'Rajesh K. Patel',
        dateOfBirth: '12/05/1988',
        dateOfExpiry: '',
        dateOfIssue: '01/01/2016',
        nationality: 'Indian',
        issuingCountry: 'India',
        gender: 'Male',
      );

      final result = await service.verifyDocumentAndPullRecords(
        docType: DocumentType.nationalId,
        extractedData: extracted,
        imagePath: 'test_image.jpg',
      );

      expect(result.isValidPerson, isTrue);
      expect(result.responseStatus, '1');
      expect(result.personName, 'Rajesh K. Patel');
      expect(result.primaryDocNumber, '2345 6789 0124');
      expect(result.digitalSignatureValid, isTrue);
      expect(result.identityMatchConfidence, greaterThan(0.95));
      expect(result.rawXmlPayload, contains('PullURIResponse'));
    });

    test('Unreadable or missing document number produces Unverified status with Red Cross', () async {
      const extracted = ExtractedDocumentData(
        documentNumber: '',
        fullName: '',
        dateOfBirth: '',
        dateOfExpiry: '',
        dateOfIssue: '',
        nationality: 'Indian',
        issuingCountry: 'India',
        gender: '',
      );

      final result = await service.verifyDocumentAndPullRecords(
        docType: DocumentType.nationalId,
        extractedData: extracted,
        imagePath: 'blurry_image.jpg',
      );

      expect(result.isValidPerson, isFalse);
      expect(result.responseStatus, '0');
      expect(result.verificationAnomalies, isNotEmpty);
    });
  });
}
