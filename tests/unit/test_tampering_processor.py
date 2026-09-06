"""
Unit tests for ShieldID Tampering Detection Processor and Submodules.
Tests ELA, Metadata extraction, specialized tamper detectors, and TamperingResult schema conformity.
"""

import io

import numpy as np
import pytest
from PIL import Image

from src.processors.base_processor import BaseProcessor
from src.processors.tampering.ela import compute_ela, detect_ela_tampering
from src.processors.tampering.metadata import (
    analyze_metadata,
    check_date_consistency,
    check_editing_software,
)
from src.processors.tampering.processor import TamperingProcessor
from src.schemas.verification import TamperingResult


@pytest.fixture
def clean_document_image():
    """Generates a synthetic pristine identity document canvas (200x300 RGB)."""
    img_arr = np.full((200, 300, 3), 245, dtype=np.uint8)
    # Simulate some document structure
    img_arr[20:100, 200:280] = 180  # Photo frame
    img_arr[120:130, 20:250] = 50   # Text line 1
    img_arr[140:150, 20:200] = 50   # Text line 2
    return img_arr


@pytest.fixture
def tampered_document_image(clean_document_image):
    """Generates a spliced/tampered document canvas with high contrast digital artifact."""
    tampered = clean_document_image.copy()
    # Digital vector patch with sharp boundaries and noise mismatch
    tampered[40:80, 210:270] = np.random.randint(0, 255, size=(40, 60, 3), dtype=np.uint8)
    return tampered


def test_tampering_processor_inheritance():
    """Verify TamperingProcessor inherits from BaseProcessor."""
    processor = TamperingProcessor()
    assert isinstance(processor, BaseProcessor)
    assert processor.is_loaded is False


def test_tampering_processor_load_model():
    """Verify model loading initializes model attribute and flags."""
    processor = TamperingProcessor()
    processor.load_model()
    assert processor.is_loaded is True
    assert processor.model is not None
    assert "threshold" in processor.model


def test_tampering_preprocess_numpy(clean_document_image):
    """Verify preprocessing correctly normalizes numpy arrays."""
    processor = TamperingProcessor()
    processed = processor.preprocess(clean_document_image)
    assert isinstance(processed, np.ndarray)
    assert processed.shape == (200, 300, 3)
    assert processed.dtype == np.uint8


def test_tampering_preprocess_pil(clean_document_image):
    """Verify preprocessing handles PIL Image instances."""
    processor = TamperingProcessor()
    pil_img = Image.fromarray(clean_document_image)
    processed = processor.preprocess(pil_img)
    assert isinstance(processed, np.ndarray)
    assert processed.shape == (200, 300, 3)


def test_tampering_preprocess_bytes(clean_document_image):
    """Verify preprocessing handles raw bytes."""
    processor = TamperingProcessor()
    pil_img = Image.fromarray(clean_document_image)
    buf = io.BytesIO()
    pil_img.save(buf, format="PNG")
    raw_bytes = buf.getvalue()

    processed = processor.preprocess(raw_bytes)
    assert isinstance(processed, np.ndarray)
    assert processed.shape == (200, 300, 3)


def test_ela_computation(clean_document_image):
    """Verify Error Level Analysis produces difference image and valid metrics."""
    ela_img, stats = compute_ela(clean_document_image, quality=90)
    assert isinstance(ela_img, np.ndarray)
    assert ela_img.shape == clean_document_image.shape
    assert "mean_error" in stats
    assert "max_error" in stats
    assert "std_error" in stats
    assert stats["mean_error"] >= 0.0


def test_ela_detect_tampering(tampered_document_image):
    """Verify ELA detection flags anomalies and generates valid structure."""
    result = detect_ela_tampering(tampered_document_image, quality=90)
    assert "is_tampered" in result
    assert "tamper_score" in result
    assert "regions" in result
    assert 0.0 <= result["tamper_score"] <= 100.0


def test_metadata_software_detection():
    """Verify Photoshop software signature detection."""
    meta = {
        "exif": {"Software": "Adobe Photoshop CC 2023"},
        "info": {},
        "raw_string_matches": [],
    }
    software, score = check_editing_software(meta)
    assert any("photoshop" in s for s in software)
    assert score >= 80.0


def test_metadata_date_inconsistency():
    """Verify future date and modified-before-creation anomalies are flagged."""
    meta = {
        "exif": {
            "DateTimeOriginal": "2025:01:01 10:00:00",
            "DateTime": "2020:01:01 10:00:00",  # Modified 5 years before creation
        }
    }
    inconsistencies, score = check_date_consistency(meta)
    assert len(inconsistencies) > 0
    assert score >= 50.0


def test_analyze_metadata_clean_image(clean_document_image):
    """Verify clean image with no metadata produces low risk score."""
    res = analyze_metadata(clean_document_image)
    assert "is_suspicious" in res
    assert "metadata_score" in res
    assert res["metadata_score"] == 0.0
    assert res["is_suspicious"] is False


def test_individual_detectors(clean_document_image):
    """Verify all individual detector methods execute and return required keys."""
    processor = TamperingProcessor()
    photo_res = processor.detect_photo_replacement(clean_document_image)
    assert "detected" in photo_res
    assert "score" in photo_res

    text_res = processor.detect_text_manipulation(clean_document_image)
    assert "detected" in text_res
    assert "regions" in text_res

    date_res = processor.detect_date_alteration(clean_document_image)
    assert "detected" in date_res
    assert "regions" in date_res

    stamp_res = processor.detect_stamp_forgery(clean_document_image)
    assert "detected" in stamp_res

    digital_res = processor.detect_digital_editing(clean_document_image)
    assert "detected" in digital_res


def test_tampering_processor_process_flow(clean_document_image):
    """Verify process() runs pipeline and output strictly conforms to TamperingResult."""
    processor = TamperingProcessor()
    result = processor.process(clean_document_image)

    assert isinstance(result, dict)
    assert "is_tampered" in result
    assert "tamper_score" in result
    assert "tampering_regions" in result
    assert "detection_method" in result

    # Validate schema instantiation
    schema_instance = TamperingResult(**result)
    assert schema_instance.is_tampered == result["is_tampered"]
    assert schema_instance.tamper_score == result["tamper_score"]
    assert schema_instance.detection_method == result["detection_method"]


def test_tampering_processor_verify_tampering_helper(clean_document_image):
    """Verify verify_tampering convenience method returns TamperingResult model directly."""
    processor = TamperingProcessor()
    schema_res = processor.verify_tampering(clean_document_image)
    assert isinstance(schema_res, TamperingResult)
    assert isinstance(schema_res.is_tampered, bool)
    assert 0.0 <= schema_res.tamper_score <= 100.0
