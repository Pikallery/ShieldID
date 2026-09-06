"""
Unit tests for ShieldID Face Verification Processor and Liveness Detection.
Tests face detection, embedding similarity, active/passive liveness, deepfakes,
and strict FaceVerificationResult schema conformity.
"""

import numpy as np
import pytest

from src.processors.base_processor import BaseProcessor
from src.processors.face.liveness import (
    check_active_liveness,
    check_passive_liveness,
    detect_deepfake,
    evaluate_liveness,
)
from src.processors.face.processor import FaceProcessor
from src.schemas.verification import FaceVerificationResult


@pytest.fixture
def synthetic_face_canvas():
    """
    Generate a synthetic face portrait canvas (200x200 RGB)
    with typical human skin tone, eye landmarks, and mouth.
    """
    canvas = np.full((200, 200, 3), 230, dtype=np.uint8)  # Light background

    # Center face oval / rectangle (skin tone: R=190, G=140, B=110)
    canvas[30:170, 40:160] = [190, 140, 110]

    # Eyes (dark pupils/irises)
    canvas[70:85, 65:85] = [40, 30, 25]    # Left eye
    canvas[70:85, 115:135] = [40, 30, 25]  # Right eye

    # Eyebrows
    canvas[60:67, 60:90] = [50, 40, 30]
    canvas[60:67, 110:140] = [50, 40, 30]

    # Mouth (lips)
    canvas[130:145, 80:120] = [160, 70, 70]

    return canvas


def test_face_processor_inheritance():
    """Verify FaceProcessor inherits from BaseProcessor."""
    processor = FaceProcessor()
    assert isinstance(processor, BaseProcessor)
    assert processor.is_loaded is False


def test_face_processor_load_model():
    """Verify load_model initializes model metadata and state."""
    processor = FaceProcessor()
    processor.load_model()
    assert processor.is_loaded is True
    assert processor.model is not None
    assert processor.model.get("embedding_dim") == 128


def test_face_processor_preprocess_pair(synthetic_face_canvas):
    """Verify preprocess correctly handles a pair of document & selfie images."""
    processor = FaceProcessor()
    payload = {
        "document": synthetic_face_canvas,
        "selfie": synthetic_face_canvas,
    }
    processed = processor.preprocess(payload)
    assert isinstance(processed, np.ndarray)
    assert processed.shape == (2, 256, 256, 3)
    assert processed.dtype == np.uint8


def test_face_processor_preprocess_single(synthetic_face_canvas):
    """Verify preprocess handles a single image input."""
    processor = FaceProcessor()
    processed = processor.preprocess(synthetic_face_canvas)
    assert isinstance(processed, np.ndarray)
    assert processed.shape == (1, 256, 256, 3)


def test_face_detection(synthetic_face_canvas):
    """Verify face detection identifies facial presence, confidence, and crop."""
    processor = FaceProcessor()
    detected, conf, crop, bbox = processor.detect_face(synthetic_face_canvas)
    assert detected is True
    assert conf >= 0.65
    assert crop is not None
    assert crop.shape == (128, 128, 3)
    assert bbox[2] > 0 and bbox[3] > 0


def test_face_detection_non_face():
    """Verify face detection returns False for blank or non-face background."""
    processor = FaceProcessor()
    blank = np.zeros((200, 200, 3), dtype=np.uint8)
    detected, conf, crop, _bbox = processor.detect_face(blank)
    assert detected is False
    assert conf == 0.0
    assert crop is None


def test_extract_embedding(synthetic_face_canvas):
    """Verify embedding extraction produces 128-d unit-normalized feature vector."""
    processor = FaceProcessor()
    _, _, crop, _ = processor.detect_face(synthetic_face_canvas)
    assert crop is not None
    emb = processor.extract_embedding(crop)
    assert isinstance(emb, np.ndarray)
    assert emb.shape == (128,)
    # Verify unit L2 norm
    norm = np.linalg.norm(emb)
    assert pytest.approx(norm, abs=1e-3) == 1.0


def test_compare_embeddings(synthetic_face_canvas):
    """Verify cosine similarity calculation between identical and modified faces."""
    processor = FaceProcessor()
    _, _, crop, _ = processor.detect_face(synthetic_face_canvas)
    emb1 = processor.extract_embedding(crop)
    emb2 = processor.extract_embedding(crop)

    # Identical embeddings should yield maximum similarity
    sim_identical = processor.compare_embeddings(emb1, emb2)
    assert pytest.approx(sim_identical, abs=1e-2) == 1.0

    # Orthogonal or zero embedding
    zero_emb = np.zeros(128, dtype=np.float32)
    assert processor.compare_embeddings(emb1, zero_emb) == 0.0


def test_passive_liveness(synthetic_face_canvas):
    """Verify passive presentation attack detection metrics."""
    res = check_passive_liveness(synthetic_face_canvas)
    assert "passive_passed" in res
    assert "passive_score" in res
    assert "moire_detected" in res
    assert 0.0 <= res["passive_score"] <= 1.0


def test_deepfake_detection(synthetic_face_canvas):
    """Verify deepfake evaluation metrics."""
    res = detect_deepfake(synthetic_face_canvas)
    assert "is_deepfake" in res
    assert "deepfake_score" in res
    assert 0.0 <= res["deepfake_score"] <= 1.0
    assert res["is_deepfake"] is False


def test_active_liveness_frames(synthetic_face_canvas):
    """Verify active liveness evaluation on sequential frames."""
    frame1 = synthetic_face_canvas.copy()
    frame2 = synthetic_face_canvas.copy()
    # Simulate slight eye blink in frame 2
    frame2[70:85, 65:85] = [190, 140, 110]  # Close left eye
    frame2[70:85, 115:135] = [190, 140, 110] # Close right eye
    frame3 = synthetic_face_canvas.copy()

    res = check_active_liveness([frame1, frame2, frame3])
    assert "active_passed" in res
    assert "blink_detected" in res
    assert res["blink_detected"] is True
    assert res["active_passed"] is True


def test_unified_evaluate_liveness(synthetic_face_canvas):
    """Verify unified evaluate_liveness output structure."""
    res = evaluate_liveness(synthetic_face_canvas)
    assert "is_live" in res
    assert "liveness_score" in res
    assert 0.0 <= res["liveness_score"] <= 1.0


def test_face_processor_process_flow(synthetic_face_canvas):
    """Verify FaceProcessor.process() strictly outputs schema conforming to FaceVerificationResult."""
    processor = FaceProcessor()
    payload = {
        "document": synthetic_face_canvas,
        "selfie": synthetic_face_canvas,
    }
    result = processor.process(payload)

    assert isinstance(result, dict)
    assert "face_detected" in result
    assert "face_confidence" in result
    assert "similarity_score" in result
    assert "is_same_person" in result

    # Strict validation against Pydantic schema
    schema_res = FaceVerificationResult(**result)
    assert schema_res.face_detected is True
    assert schema_res.face_confidence > 0.0
    assert schema_res.similarity_score > 0.70
    assert schema_res.is_same_person is True


def test_face_processor_verify_helper(synthetic_face_canvas):
    """Verify verify() convenience method returns FaceVerificationResult model directly."""
    processor = FaceProcessor()
    schema_res = processor.verify(synthetic_face_canvas, synthetic_face_canvas)
    assert isinstance(schema_res, FaceVerificationResult)
    assert schema_res.face_detected is True
    assert schema_res.is_same_person is True
