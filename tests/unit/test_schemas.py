"""Unit tests for document and verification schemas."""

import pytest
from datetime import date
from pydantic import ValidationError

from src.schemas.document import (
from src.schemas import (
    DocumentType,
    PassportData,
    AadhaarData,
    PANData,
    DrivingLicenseData,
    VoterIDData,
)
from src.schemas.verification import (
    OCRResult,
    TamperingResult,
    FaceVerificationResult,
    RiskScoreResult,
    SecurityFeatureCheck,
    CurrencyVerificationResult,
)


def test_document_types():
    assert DocumentType.PASSPORT == "passport"
    KYCRequest,
    KYCResponse,
    KYCToken,
)


def test_document_type_enum():
    """Test DocumentType enum values."""
    assert DocumentType.PASSPORT == "passport"
    assert DocumentType.VISA == "visa"
    assert DocumentType.AADHAAR == "aadhaar"
    assert DocumentType.PAN == "pan"
    assert DocumentType.DRIVING_LICENSE == "driving_license"
    assert DocumentType.VOTER_ID == "voter_id"


def test_passport_schema():
    passport = PassportData(
        name="John Doe",
        passport_number="A1234567",
        nationality="Indian",
        date_of_birth=date(1990, 1, 15),
        date_of_expiry=date(2030, 1, 14),
        gender="M",
    )
    assert passport.name == "John Doe"
    assert passport.passport_number == "A1234567"


def test_aadhaar_schema():
    aadhaar = AadhaarData(
        name="Jane Doe",
        aadhaar_number="1234 5678 9012",
        date_of_birth=date(1992, 5, 20),
        gender="F",
    )
    assert aadhaar.aadhaar_number == "1234 5678 9012"
    assert aadhaar.gender == "F"


def test_pan_schema():
    pan = PANData(
        name="Rahul Sharma",
        pan_number="ABCDE1234F",
        date_of_birth=date(1985, 12, 1),
    )
    assert pan.pan_number == "ABCDE1234F"


def test_driving_license_schema():
    dl = DrivingLicenseData(
        name="Suresh Kumar",
        license_number="DL-0420110012345",
        date_of_birth=date(1988, 8, 10),
        date_of_expiry=date(2038, 8, 9),
        gender="M",
    )
    assert dl.license_number == "DL-0420110012345"
    assert dl.gender == "M"


def test_voter_id_schema():
    voter = VoterIDData(
        name="Priya Patel",
        voter_id_number="ABC1234567",
        date_of_birth=date(1995, 3, 25),
        gender="F",
    )
    assert voter.voter_id_number == "ABC1234567"


def test_ocr_result_schema():
    pan = PANData(name="Rahul Sharma", pan_number="ABCDE1234F")
    ocr_res = OCRResult(
        document_type=DocumentType.PAN,
        pan=pan,
        raw_text="INCOME TAX DEPARTMENT GOVT OF INDIA ABCDE1234F Rahul Sharma",
        confidence_score=0.95,
    )
    dumped = ocr_res.model_dump()
    assert dumped["document_type"] == "pan"
    assert dumped["pan"]["pan_number"] == "ABCDE1234F"
    assert dumped["confidence_score"] == 0.95


def test_currency_verification_result_schema():
    watermark = SecurityFeatureCheck(
        feature_name="watermark",
        is_valid=True,
        confidence=0.92,
        details="Mahatma Gandhi portrait detected with continuous gradient.",
    )
    security_thread = SecurityFeatureCheck(
        feature_name="security_thread",
        is_valid=True,
        confidence=0.89,
        details="Windowed security thread with color shift.",
    )
    microprinting = SecurityFeatureCheck(
        feature_name="microprinting",
        is_valid=True,
        confidence=0.88,
        details="Sharp microprint RBI 500 lines detected.",
    )

    result = CurrencyVerificationResult(
        is_authentic=True,
        denomination=500,
        currency_code="INR",
        confidence_score=0.91,
        boundary_detected=True,
        watermark_check=watermark,
        security_thread_check=security_thread,
        microprinting_check=microprinting,
        uv_feature_check=None,
        reasons=[],
    )
    assert result.is_authentic is True
    assert result.denomination == 500
    assert result.watermark_check.is_valid is True

    # Test failure case
    fake_result = CurrencyVerificationResult(
        is_authentic=False,
        denomination=500,
        currency_code="INR",
        confidence_score=0.42,
        boundary_detected=True,
        watermark_check=SecurityFeatureCheck(
            feature_name="watermark", is_valid=False, confidence=0.2, details="Watermark missing"
        ),
        security_thread_check=SecurityFeatureCheck(
            feature_name="security_thread", is_valid=False, confidence=0.3, details="Thread discontinuous"
        ),
        microprinting_check=SecurityFeatureCheck(
            feature_name="microprinting", is_valid=False, confidence=0.35, details="Microprinting blurred"
        ),
        reasons=["Watermark missing", "Security thread broken"],
    )
    assert fake_result.is_authentic is False
    assert len(fake_result.reasons) == 2
def test_passport_data_valid(sample_passport_data):
    """Test PassportData schema validation with valid input."""
    assert sample_passport_data.name == "Rahul Sharma"
    assert sample_passport_data.passport_number == "Z1234567"
    assert sample_passport_data.nationality == "Indian"
    assert sample_passport_data.date_of_birth == date(1990, 1, 15)
    assert sample_passport_data.date_of_expiry == date(2030, 1, 14)
    assert sample_passport_data.gender == "M"


def test_passport_data_missing_required_fields():
    """Test PassportData raises ValidationError when mandatory fields are missing."""
    with pytest.raises(ValidationError):
        PassportData(name="Rahul Sharma")


def test_aadhaar_data_valid(sample_aadhaar_data):
    """Test AadhaarData schema with optional fields present."""
    assert sample_aadhaar_data.name == "Priya Patel"
    assert sample_aadhaar_data.aadhaar_number == "1234 5678 9012"
    assert sample_aadhaar_data.date_of_birth == date(1995, 5, 20)
    assert sample_aadhaar_data.gender == "F"


def test_aadhaar_data_minimal():
    """Test AadhaarData schema with only required fields."""
    aadhaar = AadhaarData(name="Test User", aadhaar_number="9999 8888 7777")
    assert aadhaar.name == "Test User"
    assert aadhaar.aadhaar_number == "9999 8888 7777"
    assert aadhaar.date_of_birth is None
    assert aadhaar.gender is None


def test_pan_data_valid(sample_pan_data):
    """Test PANData schema validation."""
    assert sample_pan_data.name == "Amit Kumar"
    assert sample_pan_data.pan_number == "ABCDE1234F"
    assert sample_pan_data.date_of_birth == date(1988, 12, 10)


def test_ocr_result_schema(sample_passport_data):
    """Test OCRResult schema initialization."""
    ocr = OCRResult(
        document_type=DocumentType.PASSPORT,
        passport=sample_passport_data,
        raw_text="PASSPORT INDIA RAHUL SHARMA Z1234567",
        confidence_score=0.95,
    )
    assert ocr.document_type == DocumentType.PASSPORT
    assert ocr.passport.name == "Rahul Sharma"
    assert ocr.aadhaar is None
    assert ocr.pan is None
    assert ocr.confidence_score == 0.95


def test_tampering_result_schema():
    """Test TamperingResult schema initialization."""
    tampering = TamperingResult(
        is_tampered=False,
        tamper_score=0.05,
        tampering_regions=[],
        detection_method="neural_heuristic_v1",
    )
    assert tampering.is_tampered is False
    assert tampering.tamper_score == 0.05
    assert tampering.tampering_regions == []
    assert tampering.detection_method == "neural_heuristic_v1"


def test_face_verification_result_schema():
    """Test FaceVerificationResult schema initialization."""
    face_res = FaceVerificationResult(
        face_detected=True,
        face_confidence=0.99,
        similarity_score=0.88,
        is_same_person=True,
    )
    assert face_res.face_detected is True
    assert face_res.face_confidence == 0.99
    assert face_res.similarity_score == 0.88
    assert face_res.is_same_person is True


def test_risk_score_result_schema():
    """Test RiskScoreResult schema initialization."""
    risk = RiskScoreResult(
        overall_risk=15.0,
        ocr_risk=5.0,
        tamper_risk=5.0,
        face_risk=5.0,
        recommendation="APPROVE",
    )
    assert risk.overall_risk == 15.0
    assert risk.recommendation == "APPROVE"


def test_kyc_request_schema(sample_kyc_request):
    """Test KYCRequest schema validation."""
    assert sample_kyc_request.purpose == "bank_account_opening"
    assert sample_kyc_request.return_url == "https://example.com/callback"
    assert sample_kyc_request.consent is True


def test_kyc_response_schema():
    """Test KYCResponse schema validation."""
    resp = KYCResponse(
        status="pending",
        kyc_token="SHIELD-KYC-12345",
        qr_code="https://api.qrserver.com/v1/create-qr-code/?data=SHIELD-KYC-12345",
        digilocker_redirect="https://digilocker.gov.in/",
        message="Redirecting to DigiLocker...",
    )
    assert resp.status == "pending"
    assert resp.kyc_token == "SHIELD-KYC-12345"
    assert resp.digilocker_redirect == "https://digilocker.gov.in/"


def test_kyc_token_schema():
    """Test KYCToken schema validation."""
    token = KYCToken(
        token="TOKEN_ABC_123",
        expiry=3600,
        data={"user_id": "usr_99", "verified": True},
    )
    assert token.token == "TOKEN_ABC_123"
    assert token.expiry == 3600
    assert token.data["user_id"] == "usr_99"
