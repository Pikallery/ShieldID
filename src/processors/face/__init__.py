"""
Face Verification and Liveness Detection Package for ShieldID.
"""

from .liveness import (
    check_active_liveness,
    check_passive_liveness,
    detect_deepfake,
    evaluate_liveness,
)
from .processor import FaceProcessor

__all__ = [
    "FaceProcessor",
    "check_active_liveness",
    "check_passive_liveness",
    "detect_deepfake",
    "evaluate_liveness",
]
