import numpy as np
import pytest

from src.processors.base_processor import BaseProcessor
from src.schemas import FaceVerificationResult


class MockFaceProcessor(BaseProcessor):
    """Reference concrete implementation of BaseProcessor for Face Verification tests."""

    def __init__(self, model_path: str | None = None, similarity_threshold: float = 0.70):
        super().__init__(model_path)
        self.similarity_threshold = similarity_threshold

    def load_model(self):
        self.model = "mock_facenet_embedding_model_v1"

    def preprocess(self, input_data: tuple[bytes, bytes] | dict | np.ndarray) -> dict:
        if isinstance(input_data, tuple):
            if len(input_data) != 2:
                raise ValueError("Face processor requires a pair of (document_bytes, selfie_bytes)")
            doc_bytes, selfie_bytes = input_data
            if len(doc_bytes) == 0 or len(selfie_bytes) == 0:
                raise ValueError("Document or selfie bytes cannot be empty")
            return {
                "doc_emb": np.frombuffer(doc_bytes[:16], dtype=np.uint8),
                "selfie_emb": np.frombuffer(selfie_bytes[:16], dtype=np.uint8),
                "has_face": b"NO_FACE" not in doc_bytes and b"NO_FACE" not in selfie_bytes,
                "is_match": b"DIFFERENT_PERSON" not in selfie_bytes,
            }
        raise TypeError(f"Unsupported input type for face processing: {type(input_data)}")

    def predict(self, processed_input: dict) -> dict:
        if not processed_input["has_face"]:
            return {
                "face_detected": False,
                "face_confidence": 0.0,
                "similarity_score": 0.0,
                "is_same_person": False,
            }

        is_match = processed_input["is_match"]
        similarity = 0.89 if is_match else 0.32
        is_same = similarity >= self.similarity_threshold

        return {
            "face_detected": True,
            "face_confidence": 0.96,
            "similarity_score": similarity,
            "is_same_person": is_same,
        }


# ==============================================================================
# 1. Base Processor Contract Tests for Face Biometrics
# ==============================================================================

def test_face_processor_inherits_base_processor():
    """Verify FaceProcessor adheres to BaseProcessor inheritance and contracts."""
    processor = MockFaceProcessor(model_path="models/facenet.pth")
    assert isinstance(processor, BaseProcessor)
    assert processor.model_path == "models/facenet.pth"
    assert processor.is_loaded is False
    assert processor.model is None


def test_face_processor_lifecycle():
    """Verify process template method executes load_model, preprocess, and predict."""
    processor = MockFaceProcessor()
    doc_bytes = b"DOCUMENT_ID_PHOTO_BYTES_1234567890"
    selfie_bytes = b"USER_LIVE_SELFIE_BYTES_1234567890"

    result = processor.process((doc_bytes, selfie_bytes))

    assert processor.is_loaded is True
    assert processor.model == "mock_facenet_embedding_model_v1"
    assert result["face_detected"] is True
    assert result["is_same_person"] is True
    assert result["similarity_score"] >= 0.70


def test_face_processor_does_not_reload():
    """Ensure face embedding model is not re-loaded on subsequent inferences."""
    processor = MockFaceProcessor()
    doc_bytes = b"DOC_PHOTO_DATA_1"
    selfie_bytes = b"SELFIE_PHOTO_DATA_1"

    processor.process((doc_bytes, selfie_bytes))
    assert processor.is_loaded is True

    processor.model = "cached_facenet_network"
    processor.process((doc_bytes, selfie_bytes))
    assert processor.model == "cached_facenet_network"


# ==============================================================================
# 2. Biometric Matching & Verification Scenarios
# ==============================================================================

def test_face_verification_matching_person():
    """Test verification when document photo and selfie match the same individual."""
    processor = MockFaceProcessor(similarity_threshold=0.70)
    doc_bytes = b"VALID_PASSPORT_PORTRAIT_SAMPLE"
    selfie_bytes = b"VALID_LIVE_SELFIE_SAMPLE"

    raw_output = processor.process((doc_bytes, selfie_bytes))
    result = FaceVerificationResult(**raw_output)

    assert result.face_detected is True
    assert result.face_confidence > 0.90
    assert result.similarity_score >= 0.70
    assert result.is_same_person is True


def test_face_verification_mismatched_person():
    """Test verification when document photo and selfie belong to different persons (impersonation)."""
    processor = MockFaceProcessor(similarity_threshold=0.70)
    doc_bytes = b"VALID_AADHAAR_PORTRAIT_SAMPLE"
    selfie_bytes = b"DIFFERENT_PERSON_ATTEMPTING_FRAUD"

    raw_output = processor.process((doc_bytes, selfie_bytes))
    result = FaceVerificationResult(**raw_output)

    assert result.face_detected is True
    assert result.similarity_score < 0.50
    assert result.is_same_person is False


def test_face_verification_no_face_detected():
    """Test scenario where no human face could be extracted from the document or selfie."""
    processor = MockFaceProcessor()
    doc_bytes = b"NO_FACE_BLANK_DOCUMENT_IMAGE"
    selfie_bytes = b"VALID_LIVE_SELFIE_SAMPLE"

    raw_output = processor.process((doc_bytes, selfie_bytes))
    result = FaceVerificationResult(**raw_output)

    assert result.face_detected is False
    assert result.face_confidence == 0.0
    assert result.similarity_score == 0.0
    assert result.is_same_person is False


# ==============================================================================
# 3. Thresholds & Schema Validation
# ==============================================================================

@pytest.mark.parametrize(
    "score, threshold, expected_match",
    [
        (0.95, 0.70, True),
        (0.85, 0.70, True),
        (0.71, 0.70, True),
        (0.69, 0.70, False),
        (0.40, 0.70, False),
        (0.12, 0.70, False),
    ],
)
def test_face_similarity_threshold_evaluation(score, threshold, expected_match):
    """Test threshold boundary logic for face similarity classification."""
    is_match = score >= threshold
    assert is_match == expected_match


def test_face_verification_result_schema_fields():
    """Test FaceVerificationResult schema accepts valid inputs and validates types."""
    result = FaceVerificationResult(
        face_detected=True,
        face_confidence=0.98,
        similarity_score=0.88,
        is_same_person=True,
    )

    assert result.face_detected is True
    assert result.face_confidence == 0.98
    assert result.similarity_score == 0.88
    assert result.is_same_person is True


def test_face_risk_calculation_integration():
    """Verify face risk calculation: (1 - similarity_score) * 100."""
    result = FaceVerificationResult(
        face_detected=True,
        face_confidence=0.95,
        similarity_score=0.85,
        is_same_person=True,
    )
    face_risk = (1 - result.similarity_score) * 100
    assert pytest.approx(face_risk, 0.001) == 15.0


# ==============================================================================
# 4. Error Handling & Edge Cases
# ==============================================================================

def test_face_processor_missing_tuple_raises_error():
    """Verify passing a single item instead of a 2-element tuple raises ValueError."""
    processor = MockFaceProcessor()
    with pytest.raises(ValueError, match="requires a pair"):
        processor.process((b"DOC_ONLY",))


def test_face_processor_empty_bytes_raises_error():
    """Verify passing empty bytes for either document or selfie raises ValueError."""
    processor = MockFaceProcessor()
    with pytest.raises(ValueError, match="bytes cannot be empty"):
        processor.process((b"", b"SELFIE"))

    with pytest.raises(ValueError, match="bytes cannot be empty"):
        processor.process((b"DOC", b""))


def test_face_processor_invalid_type_raises_type_error():
    """Verify non-tuple input raises TypeError."""
    processor = MockFaceProcessor()
    with pytest.raises(TypeError, match="Unsupported input type"):
        processor.process("not_a_tuple")
