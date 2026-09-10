from typing import Any

from src.processors.face.processor import FaceProcessor
from src.processors.ocr.processor import OCRProcessor
from src.processors.tampering.processor import TamperingProcessor
from src.schemas import RiskScoreResult


class VerificationService:
    def __init__(self):
        self.ocr = OCRProcessor()
        self.tamper = TamperingProcessor()
        self.face = FaceProcessor()

    async def verify(
        self,
        document_bytes: bytes,
        selfie_bytes: bytes | None = None,
        back_bytes: bytes | None = None,
        doc_type_hint: str | None = None,
    ):
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
            "face_data": face_result,
        }

    def _calculate_risk(self, ocr: Any, tamper: Any, face: Any) -> RiskScoreResult:
        ocr_conf = (
            ocr.get("confidence_score", 0.90)
            if isinstance(ocr, dict)
            else getattr(ocr, "confidence_score", 0.90)
        )
        tamper_raw = (
            tamper.get("tamper_score", 0.0)
            if isinstance(tamper, dict)
            else getattr(tamper, "tamper_score", 0.0)
        )
        # Normalize tamper score to 0.0 - 1.0 if it's on a 0-100 scale
        tamper_norm = tamper_raw / 100.0 if tamper_raw > 1.0 else tamper_raw

        face_sim = 1.0
        if face:
            face_sim = (
                face.get("similarity_score", 0.95)
                if isinstance(face, dict)
                else getattr(face, "similarity_score", 0.95)
            )

        overall_risk = (
            (1.0 - ocr_conf) * 30.0
            + (tamper_norm * 40.0)
            + ((1.0 - face_sim) * 30.0 if face else 0.0)
        )

        overall_risk = max(0.0, min(100.0, overall_risk))

        return RiskScoreResult(
            overall_risk=round(overall_risk, 2),
            ocr_risk=round((1.0 - ocr_conf) * 100.0, 2),
            tamper_risk=round(tamper_norm * 100.0, 2),
            face_risk=round((1.0 - face_sim) * 100.0, 2) if face else 0.0,
            recommendation=(
                "APPROVE"
                if overall_risk < 40
                else "REVIEW_MANUALLY"
                if overall_risk < 70
                else "REJECT"
            ),
        )
