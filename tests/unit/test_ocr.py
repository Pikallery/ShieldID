import re
from datetime import date

import numpy as np
import pytest

from src.processors.base_processor import BaseProcessor
from src.schemas import DocumentType, OCRResult


class MockOCRProcessor(BaseProcessor):
    """Reference concrete implementation of BaseProcessor for OCR testing."""

    def load_model(self):
        self.model = "mock_ocr_engine_loaded"

    def preprocess(self, input_data: bytes | str | np.ndarray) -> np.ndarray:
        if isinstance(input_data, bytes):
            if len(input_data) == 0:
                raise ValueError("Empty document input bytes")
            # Simulate image decoding into ndarray
            return np.frombuffer(input_data, dtype=np.uint8)
        elif isinstance(input_data, str):
            return np.array([ord(c) for c in input_data], dtype=np.uint8)
        elif isinstance(input_data, np.ndarray):
            return input_data
        raise TypeError(f"Unsupported input type: {type(input_data)}")

    def predict(self, processed_input: np.ndarray) -> dict:
        # Default mock prediction behavior
        return {
            "document_type": DocumentType.PASSPORT,
            "raw_text": "PASSPORT REPUBLIC OF INDIA RAHUL SHARMA Z1234567 15/01/1990",
            "confidence_score": 0.95,
        }


# ==============================================================================
# 1. Base Processor Contract Tests for OCR
# ==============================================================================

def test_ocr_processor_inherits_base_processor():
    """Verify OCR processor adheres to BaseProcessor inheritance and contracts."""
    processor = MockOCRProcessor()
    assert isinstance(processor, BaseProcessor)
    assert processor.is_loaded is False
    assert processor.model is None


def test_ocr_processor_lifecycle():
    """Verify process template method triggers load_model, preprocess, and predict."""
    processor = MockOCRProcessor()
    dummy_doc_bytes = b"REPUBLIC_OF_INDIA_PASSPORT_SAMPLE_BYTES"

    result = processor.process(dummy_doc_bytes)

    assert processor.is_loaded is True
    assert processor.model == "mock_ocr_engine_loaded"
    assert result["document_type"] == DocumentType.PASSPORT
    assert result["confidence_score"] == 0.95
    assert "raw_text" in result


def test_ocr_processor_does_not_reload_model():
    """Ensure OCR model is only loaded once across multiple calls."""
    processor = MockOCRProcessor()
    processor.process(b"FIRST_CALL_DOCUMENT_BYTES")
    assert processor.is_loaded is True

    # Mutate model attribute to confirm load_model is not called again
    processor.model = "cached_model_instance"
    processor.process(b"SECOND_CALL_DOCUMENT_BYTES")
    assert processor.model == "cached_model_instance"


# ==============================================================================
# 2. Document Extraction & Schema Tests
# ==============================================================================

def test_ocr_result_passport_schema(sample_passport_data):
    """Test OCRResult creation and validation for Indian Passport."""
    raw_ocr_text = (
        "P<INDSHARMA<<RAHUL<<<<<<<<<<<<<<<<<<<<<<<<<<\n"
        "Z1234567<3IND9001155M3001148<<<<<<<<<<<<<<<4"
    )

    result = OCRResult(
        document_type=DocumentType.PASSPORT,
        passport=sample_passport_data,
        raw_text=raw_ocr_text,
        confidence_score=0.96,
    )

    assert result.document_type == DocumentType.PASSPORT
    assert result.passport is not None
    assert result.passport.name == "Rahul Sharma"
    assert result.passport.passport_number == "Z1234567"
    assert result.passport.nationality == "Indian"
    assert result.passport.gender == "M"
    assert result.confidence_score == 0.96
    assert result.aadhaar is None
    assert result.pan is None


def test_ocr_result_aadhaar_schema(sample_aadhaar_data):
    """Test OCRResult creation and validation for Aadhaar Card."""
    raw_ocr_text = "Government of India Priya Patel DOB: 20/05/1995 1234 5678 9012 Female"

    result = OCRResult(
        document_type=DocumentType.AADHAAR,
        aadhaar=sample_aadhaar_data,
        raw_text=raw_ocr_text,
        confidence_score=0.91,
    )

    assert result.document_type == DocumentType.AADHAAR
    assert result.aadhaar is not None
    assert result.aadhaar.name == "Priya Patel"
    assert result.aadhaar.aadhaar_number == "1234 5678 9012"
    assert result.aadhaar.date_of_birth == date(1995, 5, 20)
    assert result.aadhaar.gender == "F"
    assert result.confidence_score == 0.91
    assert result.passport is None


def test_ocr_result_pan_schema(sample_pan_data):
    """Test OCRResult creation and validation for Income Tax PAN Card."""
    raw_ocr_text = "INCOME TAX DEPARTMENT GOVT. OF INDIA AMIT KUMAR ABCDE1234F 10/12/1988"

    result = OCRResult(
        document_type=DocumentType.PAN,
        pan=sample_pan_data,
        raw_text=raw_ocr_text,
        confidence_score=0.94,
    )

    assert result.document_type == DocumentType.PAN
    assert result.pan is not None
    assert result.pan.name == "Amit Kumar"
    assert result.pan.pan_number == "ABCDE1234F"
    assert result.pan.date_of_birth == date(1988, 12, 10)
    assert result.confidence_score == 0.94
    assert result.aadhaar is None


# ==============================================================================
# 3. Regex Pattern Matching Tests for Indian Documents
# ==============================================================================

def test_aadhaar_regex_pattern_extraction():
    """Verify regex patterns for Indian 12-digit Aadhaar UID extraction."""
    aadhaar_pattern = r"\b\d{4}\s\d{4}\s\d{4}\b"
    sample_text = "UIDAI Aadhaar No: 5432 1098 7654 issued to resident."

    match = re.search(aadhaar_pattern, sample_text)
    assert match is not None
    assert match.group(0) == "5432 1098 7654"

    # Test invalid aadhaar patterns
    invalid_text = "Invalid UID: 1234-5678-9012 or 123456789"
    assert re.search(aadhaar_pattern, invalid_text) is None


def test_pan_regex_pattern_extraction():
    """Verify regex pattern for 10-character PAN card format."""
    pan_pattern = r"\b[A-Z]{5}[0-9]{4}[A-Z]{1}\b"
    sample_text = "Permanent Account Number: BZCPK8921M on card."

    match = re.search(pan_pattern, sample_text)
    assert match is not None
    assert match.group(0) == "BZCPK8921M"

    # 4th character must typically be P for Individual, C for Company etc.
    invalid_text = "Wrong format: 12345ABCDE or ABC1234567"
    assert re.search(pan_pattern, invalid_text) is None


def test_passport_regex_pattern_extraction():
    """Verify regex pattern for Indian Passport numbers (1 alphabet followed by 7 digits)."""
    passport_pattern = r"\b[A-Z][0-9]{7}\b"
    sample_text = "Passport No / Passeport No: T8765432"

    match = re.search(passport_pattern, sample_text)
    assert match is not None
    assert match.group(0) == "T8765432"

    invalid_passport = "P12345 or 12345678"
    assert re.search(passport_pattern, invalid_passport) is None


# ==============================================================================
# 4. Confidence Scores and Thresholding Tests
# ==============================================================================

def test_ocr_confidence_score_boundaries():
    """Test confidence scores stay within valid [0.0, 1.0] interval."""
    valid_res = OCRResult(
        document_type=DocumentType.PASSPORT,
        raw_text="SAMPLE TEXT",
        confidence_score=0.88,
    )
    assert 0.0 <= valid_res.confidence_score <= 1.0


def test_ocr_low_confidence_flagging():
    """Test behavior when OCR returns low confidence due to degradation."""
    low_conf_result = OCRResult(
        document_type=DocumentType.PAN,
        raw_text="U..N.C..EAR T..XT",
        confidence_score=0.25,
    )
    assert low_conf_result.confidence_score < 0.40


# ==============================================================================
# 5. Error Handling & Edge Cases
# ==============================================================================

def test_ocr_processor_empty_bytes_raises_error():
    """Ensure processor raises ValueError on zero-byte document input."""
    processor = MockOCRProcessor()
    with pytest.raises(ValueError, match="Empty document input bytes"):
        processor.process(b"")


def test_ocr_processor_invalid_type_raises_type_error():
    """Ensure processor raises TypeError when input is of unsupported type."""
    processor = MockOCRProcessor()
    with pytest.raises(TypeError, match="Unsupported input type"):
        processor.process(12345)
