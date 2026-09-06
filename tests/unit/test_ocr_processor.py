"""Unit tests for OCR Preprocessing and OCR Processor."""

from datetime import date
import numpy as np
import pytest

from src.processors.base_processor import BaseProcessor
from src.processors.ocr.preprocess import (
    binarize,
    calculate_skew_angle,
    denoise,
    deskew,
    enhance_contrast,
    load_image,
    preprocess_document,
)
from src.processors.ocr.processor import OCRProcessor
from src.schemas.document import DocumentType
from src.schemas.verification import OCRResult


# ─── Preprocessing Tests ───────────────────────────────────────────────────────

def test_load_image_from_numpy():
    dummy = np.zeros((100, 100, 3), dtype=np.uint8)
    loaded = load_image(dummy)
    assert loaded.shape == (100, 100, 3)


def test_enhance_contrast():
    img_bgr = np.full((100, 100, 3), 128, dtype=np.uint8)
    enhanced = enhance_contrast(img_bgr)
    assert enhanced.shape == (100, 100, 3)

    img_gray = np.full((100, 100), 128, dtype=np.uint8)
    enhanced_gray = enhance_contrast(img_gray)
    assert enhanced_gray.shape == (100, 100)


def test_denoise_methods():
    img = np.random.randint(0, 256, (100, 100, 3), dtype=np.uint8)
    for method in ["bilateral", "median", "gaussian", "morph_open"]:
        denoised = denoise(img, method=method)
        assert denoised.shape == (100, 100, 3)


def test_binarize_methods():
    img = np.full((100, 100, 3), 150, dtype=np.uint8)
    for method in ["otsu", "adaptive_gaussian", "adaptive_mean"]:
        binary = binarize(img, method=method)
        assert len(binary.shape) == 2
        assert set(np.unique(binary)).issubset({0, 255})


def test_deskew():
    img = np.full((120, 200, 3), 255, dtype=np.uint8)
    # Draw horizontal text line
    img[55:65, 30:170] = 0
    deskewed, angle = deskew(img)
    assert deskewed is not None
    assert isinstance(angle, float)


def test_preprocess_document_pipeline():
    img = np.random.randint(50, 200, (150, 250, 3), dtype=np.uint8)
    processed = preprocess_document(img, deskew_enabled=True, denoise_method="median")
    assert processed is not None
    assert len(processed.shape) == 3


# ─── OCR Processor Tests ───────────────────────────────────────────────────────

def test_ocr_processor_inheritance():
    processor = OCRProcessor()
    assert isinstance(processor, BaseProcessor)
    assert processor.is_loaded is False


def test_ocr_processor_process_pipeline():
    processor = OCRProcessor()
    img = np.full((200, 400, 3), 255, dtype=np.uint8)
    # Running process() triggers load_model(), preprocess(), predict()
    result = processor.process(img)
    assert isinstance(result, dict)
    assert "document_type" in result
    assert "raw_text" in result
    assert "confidence_score" in result

    # Validate against schema
    schema_obj = OCRResult.model_validate(result)
    assert schema_obj.document_type in [
        DocumentType.PASSPORT,
        DocumentType.AADHAAR,
        DocumentType.PAN,
        DocumentType.DRIVING_LICENSE,
        DocumentType.VOTER_ID,
    ]


def test_passport_parsing():
    processor = OCRProcessor()
    passport_text = """
    PASSPORT
    REPUBLIC OF INDIA
    Passport No: Z9876543
    Given Name(s): VIKRAM
    Surname: SINGH
    Nationality: INDIAN
    Sex: M
    Date of Birth: 12/04/1988
    Date of Expiry: 11/04/2028
    P<INDVIKRAM<<SINGH<<<<<<<<<<<<<<<<<<<<<<<<<<
    """
    res = processor.parse_text(passport_text, confidence_score=0.96)
    assert res.document_type == DocumentType.PASSPORT
    assert res.passport is not None
    assert res.passport.passport_number == "Z9876543"
    assert res.passport.date_of_birth == date(1988, 4, 12)
    assert res.passport.date_of_expiry == date(2028, 4, 11)
    assert res.passport.gender == "M"
    assert "VIKRAM" in res.passport.name.upper()


def test_aadhaar_parsing():
    processor = OCRProcessor()
    aadhaar_text = """
    GOVERNMENT OF INDIA
    UNIQUE IDENTIFICATION AUTHORITY OF INDIA
    Ananya Sharma
    DOB: 24/09/1994
    Female
    5678 1234 9876
    Mera Aadhaar, Meri Pehchan
    """
    res = processor.parse_text(aadhaar_text, confidence_score=0.94)
    assert res.document_type == DocumentType.AADHAAR
    assert res.aadhaar is not None
    assert res.aadhaar.aadhaar_number == "5678 1234 9876"
    assert res.aadhaar.date_of_birth == date(1994, 9, 24)
    assert res.aadhaar.gender == "Female"
    assert "Ananya" in res.aadhaar.name


def test_pan_parsing():
    processor = OCRProcessor()
    pan_text = """
    INCOME TAX DEPARTMENT
    GOVT OF INDIA
    Permanent Account Number
    ABCDE1234F
    Name
    RAJESH KUMAR
    Father's Name
    RAMESH KUMAR
    Date of Birth: 15/08/1982
    """
    res = processor.parse_text(pan_text, confidence_score=0.98)
    assert res.document_type == DocumentType.PAN
    assert res.pan is not None
    assert res.pan.pan_number == "ABCDE1234F"
    assert res.pan.date_of_birth == date(1982, 8, 15)
    assert "RAJESH" in res.pan.name.upper()


def test_driving_license_parsing():
    processor = OCRProcessor()
    dl_text = """
    UNION OF INDIA DRIVING LICENCE
    TRANSPORT DEPARTMENT
    Licence No: DL-0420110012345
    Name: ROHIT VERMA
    DOB: 10/11/1991
    Valid Till: 09/11/2031
    Gender: MALE
    """
    res = processor.parse_text(dl_text, confidence_score=0.93)
    assert res.document_type == DocumentType.DRIVING_LICENSE
    assert res.driving_license is not None
    assert "DL-0420110012345" in res.driving_license.license_number
    assert res.driving_license.date_of_birth == date(1991, 11, 10)
    assert res.driving_license.date_of_expiry == date(2031, 11, 9)
    assert res.driving_license.gender == "Male"
    assert "ROHIT" in res.driving_license.name.upper()


def test_voter_id_parsing():
    processor = OCRProcessor()
    voter_text = """
    ELECTION COMMISSION OF INDIA
    ELECTOR PHOTO IDENTITY CARD
    EPIC NO: WXY1234567
    Elector's Name: POOJA HEGDE
    Date of Birth: 05/06/1993
    Sex: FEMALE
    """
    res = processor.parse_text(voter_text, confidence_score=0.91)
    assert res.document_type == DocumentType.VOTER_ID
    assert res.voter_id is not None
    assert res.voter_id.voter_id_number == "WXY1234567"
    assert res.voter_id.date_of_birth == date(1993, 6, 5)
    assert res.voter_id.gender == "Female"
    assert "POOJA" in res.voter_id.name.upper()


def test_process_to_schema_helper():
    processor = OCRProcessor()
    img = np.full((150, 300, 3), 240, dtype=np.uint8)
    schema_res = processor.process_to_schema(img)
    assert isinstance(schema_res, OCRResult)
