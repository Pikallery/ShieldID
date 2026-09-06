from pydantic import BaseModel
from typing import Optional, List
from .document import DocumentType, PassportData, AadhaarData, PANData, DrivingLicenseData, VoterIDData

class OCRResult(BaseModel):
    document_type: DocumentType
    passport: Optional[PassportData] = None
    aadhaar: Optional[AadhaarData] = None
    pan: Optional[PANData] = None
    driving_license: Optional[DrivingLicenseData] = None
    voter_id: Optional[VoterIDData] = None
    raw_text: str
    confidence_score: float

class TamperingResult(BaseModel):
    is_tampered: bool
    tamper_score: float
    tampering_regions: List[str]
    detection_method: str

class FaceVerificationResult(BaseModel):
    face_detected: bool
    face_confidence: float
    similarity_score: float
    is_same_person: bool

class RiskScoreResult(BaseModel):
    overall_risk: float
    ocr_risk: float
    tamper_risk: float
    face_risk: float
    recommendation: str  # APPROVE, REVIEW_MANUALLY, REJECT

class SecurityFeatureCheck(BaseModel):
    feature_name: str
    is_valid: bool
    confidence: float
    details: Optional[str] = None

class CurrencyVerificationResult(BaseModel):
    is_authentic: bool
    denomination: Optional[int] = None  # e.g., 10, 50, 100, 200, 500
    currency_code: str = "INR"
    confidence_score: float
    boundary_detected: bool
    watermark_check: SecurityFeatureCheck
    security_thread_check: SecurityFeatureCheck
    microprinting_check: SecurityFeatureCheck
    uv_feature_check: Optional[SecurityFeatureCheck] = None
    reasons: List[str] = []

from pydantic import BaseModel

from .document import AadhaarData, DocumentType, PANData, PassportData


class OCRResult(BaseModel):
    document_type: DocumentType
    passport: PassportData | None = None
    aadhaar: AadhaarData | None = None
    pan: PANData | None = None
    raw_text: str
    confidence_score: float

class TamperingResult(BaseModel):
    is_tampered: bool
    tamper_score: float
    tampering_regions: list[str]
    detection_method: str

class FaceVerificationResult(BaseModel):
    face_detected: bool
    face_confidence: float
    similarity_score: float
    is_same_person: bool

class RiskScoreResult(BaseModel):
    overall_risk: float
    ocr_risk: float
    tamper_risk: float
    face_risk: float
    recommendation: str  # APPROVE, REVIEW_MANUALLY, REJECT
