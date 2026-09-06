"""
Tampering Detection Package for ShieldID.
"""

from .ela import compute_ela, detect_ela_tampering
from .metadata import (
    analyze_metadata,
    check_date_consistency,
    check_editing_software,
    extract_raw_metadata,
)
from .processor import TamperingProcessor

__all__ = [
    "TamperingProcessor",
    "analyze_metadata",
    "check_date_consistency",
    "check_editing_software",
    "compute_ela",
    "detect_ela_tampering",
    "extract_raw_metadata",
]
