"""Unit tests for CurrencyProcessor and banknote verification."""

import cv2
import numpy as np
import pytest

from src.processors.base_processor import BaseProcessor
from src.processors.currency.processor import (
    CANONICAL_HEIGHT,
    CANONICAL_WIDTH,
    CurrencyProcessor,
)
from src.schemas.verification import CurrencyVerificationResult, SecurityFeatureCheck


def _create_synthetic_note(
    denomination: int = 500,
    has_watermark: bool = True,
    has_security_thread: bool = True,
    has_sharp_microprint: bool = True,
    is_fake_paper: bool = False,
) -> np.ndarray:
    """
    Generate a synthetic banknote image with authentic or counterfeit features.
    """
    img = np.full((440, 1000, 3), 200, dtype=np.uint8)

    # Denomination color tinting
    if denomination == 500:
        # Stone Grey: low saturation, neutral
        img[:, :] = (175, 180, 180)
    elif denomination == 200:
        # Bright Yellow: (B, G, R) -> high G & R, low B
        img[:, :] = (40, 210, 230)
    elif denomination == 100:
        # Lavender / Violet: high B & R, lower G
        img[:, :] = (210, 150, 180)
    elif denomination == 50:
        # Fluorescent Blue: high B & G, lower R
        img[:, :] = (220, 200, 50)
    elif denomination == 10:
        # Chocolate Brown: low B, moderate G, higher R
        img[:, :] = (40, 75, 120)

    # Note borders (inner framing)
    cv2.rectangle(img, (20, 20), (980, 420), (50, 50, 50), 2)

    # 1. Security Thread: vertical strip at x=430 (x ~ 43%)
    if has_security_thread:
        # Thread with periodic window dashes
        thread_x = 430
        for y in range(30, 410, 20):
            # Alternating metallic color and dark dash
            color = (120, 180, 70) if (y // 20) % 2 == 0 else (40, 80, 40)
            cv2.line(img, (thread_x, y), (thread_x, y + 16), color, 4)
            # Add horizontal contrast
            cv2.line(img, (thread_x - 2, y), (thread_x + 2, y + 16), (20, 20, 20), 1)

    # 2. Watermark: right side area (x: 750-920, y: 80-360)
    if has_watermark:
        # Soft Gaussian shaded circular portrait gradient
        wm_center = (830, 220)
        for r in range(70, 10, -5):
            val = int(180 - (r * 0.8))
            cv2.circle(img, wm_center, r, (val, val, val), -1)
        # Blur to give authentic mold-made continuous gradient
        roi = img[100:340, 720:940]
        blurred_roi = cv2.GaussianBlur(roi, (21, 21), 0)
        img[100:340, 720:940] = blurred_roi

    # 3. Micro-printing: between center portrait and thread (x: 520-660, y: 150-300)
    if has_sharp_microprint:
        # Fine intaglio lines simulating 'RBI 500' microlettering
        for y_line in range(160, 290, 8):
            for x_dot in range(530, 650, 6):
                cv2.line(img, (x_dot, y_line), (x_dot + 3, y_line), (30, 30, 30), 1)
    else:
        # Blurry / washed out
        img[150:300, 520:660] = cv2.GaussianBlur(img[150:300, 520:660], (15, 15), 0)

    # 4. UV / Paper Substrate
    if is_fake_paper:
        # High blue emission (bleached copy paper with OBAs)
        img[0:70, 0:160, 0] = 250  # Blue channel high
        img[0:70, 0:160, 2] = 140  # Red channel lower


    return img


# ─── Tests ─────────────────────────────────────────────────────────────────────

def test_currency_processor_inheritance():
    processor = CurrencyProcessor()
    assert isinstance(processor, BaseProcessor)
    assert processor.is_loaded is False


def test_currency_processor_load_model():
    processor = CurrencyProcessor()
    processor.load_model()
    assert processor.is_loaded is True
    assert 500 in processor.benchmarks
    assert 100 in processor.benchmarks


def test_boundary_detection_with_synthetic_note():
    processor = CurrencyProcessor()
    note = _create_synthetic_note(denomination=500)

    # Embed note inside a larger image with a dark background
    canvas = np.zeros((600, 1200, 3), dtype=np.uint8)
    canvas[80:520, 100:1100] = note

    rectified, boundary_detected, info = processor.detect_note_boundaries(canvas)
    assert rectified.shape == (CANONICAL_HEIGHT, CANONICAL_WIDTH, 3)
    assert boundary_detected is True
    assert "aspect_ratio" in info


def test_denomination_identification():
    processor = CurrencyProcessor()
    for denom in [500, 200, 100, 50, 10]:
        synthetic_note = _create_synthetic_note(denomination=denom)
        detected_denom, confidence = processor.identify_denomination(synthetic_note)
        assert detected_denom == denom, f"Expected {denom}, got {detected_denom}"
        assert confidence > 0.5


def test_watermark_inspection_valid():
    processor = CurrencyProcessor()
    note_with_wm = _create_synthetic_note(denomination=500, has_watermark=True)
    check = processor.check_watermark(note_with_wm, denomination=500)
    assert isinstance(check, SecurityFeatureCheck)
    assert check.is_valid is True
    assert check.confidence > 0.5


def test_watermark_inspection_blank_fake():
    processor = CurrencyProcessor()
    note_without_wm = _create_synthetic_note(denomination=500, has_watermark=False)
    check = processor.check_watermark(note_without_wm, denomination=500)
    assert check.is_valid is False
    assert "blank" in check.details.lower() or "washed out" in check.details.lower()


def test_security_thread_inspection_valid():
    processor = CurrencyProcessor()
    note_with_thread = _create_synthetic_note(denomination=500, has_security_thread=True)
    check = processor.check_security_thread(note_with_thread, denomination=500)
    assert isinstance(check, SecurityFeatureCheck)
    assert check.is_valid is True
    assert check.confidence > 0.6


def test_security_thread_inspection_missing_fake():
    processor = CurrencyProcessor()
    note_without_thread = _create_synthetic_note(denomination=500, has_security_thread=False)
    check = processor.check_security_thread(note_without_thread, denomination=500)
    assert check.is_valid is False
    assert "missing" in check.details.lower() or "lacks" in check.details.lower()


def test_microprinting_sharpness_valid():
    processor = CurrencyProcessor()
    note_sharp = _create_synthetic_note(denomination=500, has_sharp_microprint=True)
    check = processor.check_microprinting(note_sharp, denomination=500)
    assert isinstance(check, SecurityFeatureCheck)
    assert check.is_valid is True
    assert check.confidence > 0.6


def test_microprinting_sharpness_blurred_fake():
    processor = CurrencyProcessor()
    note_blurred = _create_synthetic_note(denomination=500, has_sharp_microprint=False)
    check = processor.check_microprinting(note_blurred, denomination=500)
    assert check.is_valid is False
    assert "blurred" in check.details.lower() or "inkjet" in check.details.lower()


def test_authentic_note_full_pipeline():
    processor = CurrencyProcessor()
    authentic_500 = _create_synthetic_note(
        denomination=500,
        has_watermark=True,
        has_security_thread=True,
        has_sharp_microprint=True,
    )
    result_dict = processor.process(authentic_500)
    assert isinstance(result_dict, dict)
    assert result_dict["is_authentic"] is True
    assert result_dict["denomination"] == 500
    assert result_dict["confidence_score"] >= 0.70

    # Validate against Pydantic schema
    res_obj = CurrencyVerificationResult.model_validate(result_dict)
    assert res_obj.is_authentic is True
    assert res_obj.watermark_check.is_valid is True
    assert res_obj.security_thread_check.is_valid is True
    assert len(res_obj.reasons) == 0


def test_fake_note_missing_security_thread():
    processor = CurrencyProcessor()
    fake_note = _create_synthetic_note(
        denomination=500,
        has_watermark=True,
        has_security_thread=False,
        has_sharp_microprint=True,
    )
    res_obj = processor.process_to_schema(fake_note)
    assert isinstance(res_obj, CurrencyVerificationResult)
    assert res_obj.is_authentic is False
    assert res_obj.security_thread_check.is_valid is False
    assert any("security thread" in r.lower() for r in res_obj.reasons)


def test_fake_note_blurred_microprint_and_missing_watermark():
    processor = CurrencyProcessor()
    fake_note = _create_synthetic_note(
        denomination=100,
        has_watermark=False,
        has_security_thread=False,
        has_sharp_microprint=False,
    )
    res_obj = processor.process_to_schema(fake_note)
    assert res_obj.is_authentic is False
    assert len(res_obj.reasons) >= 2


def test_uv_features_check():
    processor = CurrencyProcessor()
    authentic_note = _create_synthetic_note(denomination=50, is_fake_paper=False)
    uv_check = processor.check_uv_features(authentic_note)
    assert uv_check.is_valid is True

    fake_paper_note = _create_synthetic_note(denomination=50, is_fake_paper=True)
    uv_check_fake = processor.check_uv_features(fake_paper_note)
    assert uv_check_fake.is_valid is False
