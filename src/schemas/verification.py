from pydantic import BaseModel
from typing import Optional, List
from .document import DocumentType, PassportData, AadhaarData, PANData

class OCRResult(BaseModel):
    document_type: DocumentType
    passport: Optional[PassportData] = None
    aadhaar: Optional[AadhaarData] = None
    pan: Optional[PANData] = None
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