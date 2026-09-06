"""
Tampering Detection Package for ShieldID.
"""

from .processor import TamperingProcessor
from .ela import compute_ela, detect_ela_tampering
from .metadata import analyze_metadata, extract_raw_metadata, check_editing_software, check_date_consistency

__all__ = [
    "TamperingProcessor",
    "compute_ela",
    "detect_ela_tampering",
    "analyze_metadata",
    "extract_raw_metadata",
    "check_editing_software",
    "check_date_consistency",
]
