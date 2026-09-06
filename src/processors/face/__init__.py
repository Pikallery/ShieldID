"""
Face Verification and Liveness Detection Package for ShieldID.
"""

from .processor import FaceProcessor
from .liveness import (
    check_active_liveness,
    check_passive_liveness,
    detect_deepfake,
    evaluate_liveness,
)

__all__ = [
    "FaceProcessor",
    "check_active_liveness",
    "check_passive_liveness",
    "detect_deepfake",
    "evaluate_liveness",
]
