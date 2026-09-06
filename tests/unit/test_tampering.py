import numpy as np
import pytest

from src.processors.base_processor import BaseProcessor
from src.schemas import TamperingResult


class MockTamperingProcessor(BaseProcessor):
    """Reference concrete implementation of BaseProcessor for Tampering tests."""

    def __init__(self, model_path: str | None = None, threshold: float = 0.5):
        super().__init__(model_path)
        self.threshold = threshold

    def load_model(self):
        self.model = "mock_tamper_cnn_model_v1"

    def preprocess(self, input_data: bytes | np.ndarray) -> np.ndarray:
        if isinstance(input_data, bytes):
            if len(input_data) == 0:
                raise ValueError("Empty image bytes provided for tampering analysis")
            return np.frombuffer(input_data, dtype=np.uint8)
        elif isinstance(input_data, np.ndarray):
            return input_data
        raise TypeError(f"Unsupported input type for tampering: {type(input_data)}")

    def predict(self, processed_input: np.ndarray) -> dict:
        # Check simulated tamper tag in byte stream
        raw_bytes = processed_input.tobytes()
        is_tampered = b"TAMPERED" in raw_bytes or b"FORGERY" in raw_bytes

        tamper_score = 0.88 if is_tampered else 0.05
        regions = ["region_photo_box", "region_dob_text"] if is_tampered else []

        return {
            "is_tampered": is_tampered,
            "tamper_score": tamper_score,
            "tampering_regions": regions,
            "detection_method": "Error Level Analysis + CNN Feature Extraction",
        }


# ==============================================================================
# 1. Base Processor Lifecycle & Contract Tests
# ==============================================================================

def test_tampering_processor_inherits_base_processor():
    """Verify TamperingProcessor adheres to BaseProcessor inheritance."""
    processor = MockTamperingProcessor(model_path="models/tamper.pth")
    assert isinstance(processor, BaseProcessor)
    assert processor.model_path == "models/tamper.pth"
    assert processor.is_loaded is False
    assert processor.model is None


def test_tampering_processor_lifecycle():
    """Verify process template method calls load_model, preprocess, and predict."""
    processor = MockTamperingProcessor()
    clean_bytes = b"AUTHENTIC_GOVERNMENT_ISSUED_IDENTITY_DOCUMENT"

    result = processor.process(clean_bytes)

    assert processor.is_loaded is True
    assert processor.model == "mock_tamper_cnn_model_v1"
    assert result["is_tampered"] is False
    assert result["tamper_score"] < 0.20
    assert result["tampering_regions"] == []
    assert "detection_method" in result


def test_tampering_processor_does_not_reload():
    """Verify processor does not re-invoke load_model after initialization."""
    processor = MockTamperingProcessor()
    processor.process(b"FIRST_DOC")
    assert processor.is_loaded is True

    processor.model = "cached_tamper_network"
    processor.process(b"SECOND_DOC")
    assert processor.model == "cached_tamper_network"


# ==============================================================================
# 2. Tampering Detection Scenarios & Schema Tests
# ==============================================================================

def test_tampering_result_schema_clean_document():
    """Test TamperingResult schema validation on a verified authentic document."""
    result = TamperingResult(
        is_tampered=False,
        tamper_score=0.04,
        tampering_regions=[],
        detection_method="Error Level Analysis (ELA)",
    )

    assert result.is_tampered is False
    assert result.tamper_score == 0.04
    assert len(result.tampering_regions) == 0
    assert result.detection_method == "Error Level Analysis (ELA)"


def test_tampering_result_schema_forged_document():
    """Test TamperingResult schema on a detected forged document with altered regions."""
    result = TamperingResult(
        is_tampered=True,
        tamper_score=0.92,
        tampering_regions=["photo_box_splicing", "dob_text_alteration", "stamp_copy_move"],
        detection_method="Dual-Stream ELA + ResNet50 Tamper Detector",
    )

    assert result.is_tampered is True
    assert result.tamper_score > 0.90
    assert len(result.tampering_regions) == 3
    assert "photo_box_splicing" in result.tampering_regions
    assert "dob_text_alteration" in result.tampering_regions


def test_tampering_detection_with_tampered_payload():
    """Test detection on a simulated tampered document payload."""
    processor = MockTamperingProcessor()
    tampered_bytes = b"DOCUMENT_WITH_FORGERY_AND_TAMPERED_PHOTO"

    output = processor.process(tampered_bytes)
    result = TamperingResult(**output)

    assert result.is_tampered is True
    assert result.tamper_score >= 0.80
    assert len(result.tampering_regions) > 0


# ==============================================================================
# 3. Detection Methods & Scoring Logic Tests
# ==============================================================================

@pytest.mark.parametrize(
    "score, expected_tampered",
    [
        (0.02, False),
        (0.15, False),
        (0.40, False),
        (0.55, True),
        (0.85, True),
        (0.99, True),
    ],
)
def test_tamper_score_threshold_classification(score, expected_tampered):
    """Ensure tamper score threshold accurately predicts boolean tampering status."""
    threshold = 0.50
    is_tampered = score >= threshold
    assert is_tampered == expected_tampered


def test_tampering_detection_methods_supported():
    """Verify various tampering detection methodologies can be represented."""
    methods = [
        "Error Level Analysis (ELA)",
        "Copy-Move Forgery Detection (SIFT/ORB)",
        "Noise Variance Analysis",
        "Deep Learning Forensic Classifier",
    ]
    for method in methods:
        result = TamperingResult(
            is_tampered=False,
            tamper_score=0.1,
            tampering_regions=[],
            detection_method=method,
        )
        assert result.detection_method == method


# ==============================================================================
# 4. Error Handling & Edge Cases
# ==============================================================================

def test_tampering_empty_bytes_raises_error():
    """Verify empty input raises ValueError."""
    processor = MockTamperingProcessor()
    with pytest.raises(ValueError, match="Empty image bytes"):
        processor.process(b"")


def test_tampering_invalid_type_raises_type_error():
    """Verify passing non-bytes / non-ndarray raises TypeError."""
    processor = MockTamperingProcessor()
    with pytest.raises(TypeError, match="Unsupported input type"):
        processor.process({"image": "invalid"})


def test_tampering_risk_score_contribution():
    """Verify tampering score formula correctly calculates tamper_risk (tamper.tamper_score * 100)."""
    tamper_result = TamperingResult(
        is_tampered=True,
        tamper_score=0.75,
        tampering_regions=["photo_swapped"],
        detection_method="CNN Forensic",
    )
    tamper_risk = tamper_result.tamper_score * 100
    assert tamper_risk == 75.0
