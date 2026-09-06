"""Unit tests for document and verification schemas."""

import pytest
from datetime import date
from pydantic import ValidationError

from src.schemas.document import (
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
