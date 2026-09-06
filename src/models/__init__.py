"""
ShieldID ORM Models Package.

Importing this package registers all model classes with SQLAlchemy's
metadata, which is required for:
    - Alembic autogenerate to detect all tables
    - create_db_tables() in database.py to work correctly

All models are exported here for convenient imports elsewhere:
    from src.models import User, Document, OCRResult, ...
"""

from src.models.audit_log import AuditLog
from src.models.base import Base
from src.models.document import Document
from src.models.face_verification import FaceVerification
from src.models.fraud_report import FraudReport
from src.models.kyc_session import KYCSession
from src.models.ocr_result import OCRResult
from src.models.screening_result import ScreeningResult
from src.models.tampering_analysis import TamperingAnalysis
from src.models.user import User

__all__ = [
    "AuditLog",
    "Base",
    "Document",
    "FaceVerification",
    "FraudReport",
    "KYCSession",
    "OCRResult",
    "ScreeningResult",
    "TamperingAnalysis",
    "User",
]
