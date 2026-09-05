# pyrefly: ignore [missing-import]
# src/services/verification_service.py
from src.processors.face.processor import FaceProcessor
from src.processors.ocr.processor import OCRProcessor
from src.processors.tampering.processor import TamperingProcessor
from src.schemas import (
    FaceVerificationResult,
    OCRResult,
    RiskScoreResult,
    TamperingResult,
)


class VerificationService:
    def __init__(self):
        self.ocr = OCRProcessor()
        self.tamper = TamperingProcessor()
        self.face = FaceProcessor()

    async def verify(self, document_bytes: bytes, selfie_bytes: bytes | None = None):
        # 1. OCR Extraction
        ocr_result = self.ocr.process(document_bytes)

        # 2. Tampering Detection
        tamper_result = self.tamper.process(document_bytes)

        # 3. Face Verification (if selfie provided)
        face_result = None
        if selfie_bytes:
            face_result = self.face.process((document_bytes, selfie_bytes))

        # 4. Calculate Risk Score
        risk_score = self._calculate_risk(ocr_result, tamper_result, face_result)

        return {
            "status": "verified" if risk_score.overall_risk < 40 else "suspicious",
            "risk_score": risk_score,
            "ocr_data": ocr_result,
            "tamper_data": tamper_result,
            "face_data": face_result
        }

    def _calculate_risk(self, ocr: OCRResult, tamper: TamperingResult, face: FaceVerificationResult):
        overall_risk = (
            (1 - ocr.confidence_score) * 30 +
            tamper.tamper_score * 40 +
            (1 - face.similarity_score) * 30 if face else 0
        )
        return RiskScoreResult(
            overall_risk=overall_risk,
            ocr_risk=(1 - ocr.confidence_score) * 100,
            tamper_risk=tamper.tamper_score * 100,
            face_risk=(1 - face.similarity_score) * 100 if face else 0,
            recommendation="APPROVE" if overall_risk < 40 else "REVIEW_MANUALLY" if overall_risk < 70 else "REJECT"
        )
