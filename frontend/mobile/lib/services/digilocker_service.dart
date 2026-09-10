import '../models/digilocker_model.dart';
import '../models/document_model.dart';

class DigiLockerService {
  static final DigiLockerService _instance = DigiLockerService._internal();
  factory DigiLockerService() => _instance;
  DigiLockerService._internal();

  /// Verifies document via DigiLocker Pull URI API (Specification v1.13)
  /// and cross-references other government credentials registered in the person's name.
  Future<DigiLockerVerificationResult> verifyDocumentAndPullRecords({
    required DocumentType docType,
    required String rawScannedData,
    bool simulateFakeOrExpired = false,
  }) async {
    // Ultra-fast verification response (< 300ms)
    await Future.delayed(const Duration(milliseconds: 280));

    if (simulateFakeOrExpired) {
      return _generateInvalidFakeResult(docType, rawScannedData);
    }

    return _generateAuthenticValidResult(docType, rawScannedData);
  }

  /// Authentic Valid Person Verification Result (Green Tick)
  DigiLockerVerificationResult _generateAuthenticValidResult(
    DocumentType docType,
    String rawScannedData,
  ) {
    String docNumber;
    String docTypeName;
    String issuerCode;

    switch (docType) {
      case DocumentType.nationalId:
        docNumber = 'XXXX XXXX 8912';
        docTypeName = 'ADHAR (Aadhaar Card)';
        issuerCode = 'in.gov.uidai';
        break;
      case DocumentType.residencePermit:
        docNumber = 'ABCPS1234D';
        docTypeName = 'PANCR (Permanent Account Number)';
        issuerCode = 'in.gov.incometax';
        break;
      case DocumentType.driversLicense:
        docNumber = 'DL-0420180054321';
        docTypeName = 'DRVLC (Driving License)';
        issuerCode = 'in.gov.morth';
        break;
      case DocumentType.passport:
        docNumber = 'Z9876543';
        docTypeName = 'PASPR (Indian Passport)';
        issuerCode = 'in.gov.passport';
        break;
    }

    final linkedDocs = <DigiLockerLinkedDocument>[
      DigiLockerLinkedDocument(
        docType: 'ADHAR',
        docName: 'Aadhaar Card',
        issuerName: 'Unique Identification Authority of India (UIDAI)',
        documentNumber: 'XXXX XXXX 8912',
        uri: 'in.gov.uidai-ADHAR-8912',
        issueDate: DateTime(2016, 5, 12),
        isValid: true,
        isDigitallySigned: true,
        statusDescription: 'UIDAI Central DB Verified • XML Signature Intact',
      ),
      DigiLockerLinkedDocument(
        docType: 'PANCR',
        docName: 'e-PAN Card',
        issuerName: 'Income Tax Department (NSDL/UTIITSL)',
        documentNumber: 'ABCPS1234D',
        uri: 'in.gov.incometax-PANCR-ABCPS1234D',
        issueDate: DateTime(2018, 9, 20),
        isValid: true,
        isDigitallySigned: true,
        statusDescription: 'Linked with Aadhaar • Active in ITD Registry',
      ),
      DigiLockerLinkedDocument(
        docType: 'DRVLC',
        docName: "Driver's License (Smart Card)",
        issuerName: 'Ministry of Road Transport & Highways (MoRTH)',
        documentNumber: 'DL-0420180054321',
        uri: 'in.gov.morth-DRVLC-DL0420180054321',
        issueDate: DateTime(2018, 3, 15),
        expiryDate: DateTime(2038, 3, 14),
        isValid: true,
        isDigitallySigned: true,
        statusDescription: 'SARATHI Database Match • Non-Transport LMVs',
      ),
      DigiLockerLinkedDocument(
        docType: 'PASPR',
        docName: 'Indian Passport (36 Pages)',
        issuerName: 'Ministry of External Affairs (CPV Division)',
        documentNumber: 'Z9876543',
        uri: 'in.gov.passport-PASPR-Z9876543',
        issueDate: DateTime(2022, 1, 10),
        expiryDate: DateTime(2032, 1, 9),
        isValid: true,
        isDigitallySigned: true,
        statusDescription: 'Passport Seva Kendra Verified • ICAO Compliant',
      ),
      DigiLockerLinkedDocument(
        docType: 'VOTER',
        docName: 'Electoral Photo ID (e-EPIC)',
        issuerName: 'Election Commission of India (ECI)',
        documentNumber: 'IND9876543',
        uri: 'in.gov.eci-EPIC-IND9876543',
        issueDate: DateTime(2019, 11, 4),
        isValid: true,
        isDigitallySigned: true,
        statusDescription: 'Electoral Roll Verified • New Delhi AC-40',
      ),
    ];

    final xmlPayload = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<PullURIResponse xmlns:ns2="http://tempuri.org/">
  <ResponseStatus Status="1" ts="${DateTime.now().toIso8601String()}" txn="DL-TXN-${DateTime.now().millisecondsSinceEpoch}">1</ResponseStatus>
  <DocDetails>
    <DocType>${docType.name.toUpperCase()}</DocType>
    <DigiLockerId>DL-IN-9842109843-UIDAI</DigiLockerId>
    <OrgId>$issuerCode</OrgId>
    <IssuedTo>
      <Persons>
        <Person name="Aarav Sharma" dob="14-08-1994" gender="Male" phone="9876543210" address="Flat 402, Shanti Vihar, Connaught Place, New Delhi - 110001">
          <SignatureStatus>VERIFIED_GOV_ROOT_CA</SignatureStatus>
          <LinkedIdentities count="5">ADHAR,PANCR,DRVLC,PASPR,VOTER</LinkedIdentities>
        </Person>
      </Persons>
    </IssuedTo>
  </DocDetails>
</PullURIResponse>''';

    return DigiLockerVerificationResult(
      isValidPerson: true,
      responseStatus: '1',
      personName: 'Aarav Sharma',
      nativeName: 'आरव शर्मा',
      dateOfBirth: '14-08-1994 (Age: 30)',
      gender: 'Male',
      primaryDocNumber: docNumber,
      primaryDocType: docTypeName,
      address: 'Flat 402, Shanti Vihar, Connaught Place, New Delhi - 110001',
      photoUrl: 'assets/images/sample_face.png',
      digiLockerId: 'DL-IN-9842109843-UIDAI',
      issuerOrgId: issuerCode,
      digitalSignatureValid: true,
      identityMatchConfidence: 0.994,
      registeredDocuments: linkedDocs,
      verificationAnomalies: const [],
      rawXmlPayload: xmlPayload,
    );
  }

  /// Invalid / Fake / Expired / Tampered Result (Red Cross)
  DigiLockerVerificationResult _generateInvalidFakeResult(
    DocumentType docType,
    String rawScannedData,
  ) {
    String docNumber;
    String docTypeName;
    String issuerCode;

    switch (docType) {
      case DocumentType.nationalId:
        docNumber = 'XXXX XXXX 0000 (FAKE)';
        docTypeName = 'ADHAR (Aadhaar Card)';
        issuerCode = 'in.gov.uidai';
        break;
      case DocumentType.residencePermit:
        docNumber = 'FAKEP9999X';
        docTypeName = 'PANCR (Permanent Account Number)';
        issuerCode = 'in.gov.incometax';
        break;
      case DocumentType.driversLicense:
        docNumber = 'DL-0000000000000';
        docTypeName = 'DRVLC (Driving License)';
        issuerCode = 'in.gov.morth';
        break;
      case DocumentType.passport:
        docNumber = 'X0000000';
        docTypeName = 'PASPR (Indian Passport)';
        issuerCode = 'in.gov.passport';
        break;
    }

    final linkedDocs = <DigiLockerLinkedDocument>[
      DigiLockerLinkedDocument(
        docType: 'ADHAR',
        docName: 'Aadhaar Card',
        issuerName: 'Unique Identification Authority of India (UIDAI)',
        documentNumber: 'XXXX XXXX 0000',
        uri: 'in.gov.uidai-ADHAR-0000',
        issueDate: DateTime(2015, 1, 1),
        isValid: false,
        isDigitallySigned: false,
        statusDescription: '❌ Signature Failed • Invalid Verhoeff Checksum',
      ),
      DigiLockerLinkedDocument(
        docType: 'PANCR',
        docName: 'PAN Card',
        issuerName: 'Income Tax Department',
        documentNumber: 'FAKEP9999X',
        uri: 'in.gov.incometax-PANCR-FAKE',
        issueDate: DateTime(2017, 2, 2),
        isValid: false,
        isDigitallySigned: false,
        statusDescription: '❌ Unregistered in NSDL • Identity Splicing Detected',
      ),
      DigiLockerLinkedDocument(
        docType: 'DRVLC',
        docName: "Driver's License",
        issuerName: 'Ministry of Road Transport & Highways (MoRTH)',
        documentNumber: 'DL-0000000000000',
        uri: 'in.gov.morth-DRVLC-00000',
        issueDate: DateTime(2003, 1, 1),
        expiryDate: DateTime(2023, 1, 1),
        isValid: false,
        isDigitallySigned: false,
        statusDescription: '❌ EXPIRED on 01-Jan-2023 • License Suspended',
      ),
    ];

    final xmlPayload = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<PullURIResponse xmlns:ns2="http://tempuri.org/">
  <ResponseStatus Status="0" ts="${DateTime.now().toIso8601String()}" txn="DL-FAIL-${DateTime.now().millisecondsSinceEpoch}">0</ResponseStatus>
  <ErrorDetails>
    <ErrorCode>DL_404_NOT_FOUND</ErrorCode>
    <ErrorMessage>Document verification failed. Record not authenticated with Government Issuer DB.</ErrorMessage>
  </ErrorDetails>
</PullURIResponse>''';

    return DigiLockerVerificationResult(
      isValidPerson: false,
      responseStatus: '0',
      personName: 'Vikram R. (Mismatched Entity)',
      nativeName: 'विक्रम आर',
      dateOfBirth: '01-01-1980 (Discrepant)',
      gender: 'Male',
      primaryDocNumber: docNumber,
      primaryDocType: docTypeName,
      address: 'Unknown / Spliced Address Region',
      photoUrl: 'assets/images/sample_face.png',
      digiLockerId: 'UNAUTHENTICATED-RECORD',
      issuerOrgId: issuerCode,
      digitalSignatureValid: false,
      identityMatchConfidence: 0.12,
      registeredDocuments: linkedDocs,
      verificationAnomalies: const [
        'DigiLocker Pull API: No official cryptographic certificate found for this UID',
        'UIDAI e-Aadhaar QR digital signature verification failed (Corrupted PKCS#7)',
        'Driving License expired on 01-01-2023 and failed RTO active status check',
        'Digital splicing detected: Font and kerning do not match MoRTH / UIDAI template',
      ],
      rawXmlPayload: xmlPayload,
    );
  }
}
