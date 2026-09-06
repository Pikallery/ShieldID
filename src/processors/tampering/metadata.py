"""
Metadata Analysis Processor for ShieldID Tampering Detection.

Extracts EXIF, XMP, and JFIF image headers to detect traces of image manipulation
software (Photoshop, GIMP, Canva, etc.) and date/timestamp discrepancies.
"""

from __future__ import annotations

import io
import logging
import os
from datetime import datetime, timezone
from typing import Any

try:
    from PIL import ExifTags, Image
    HAS_PIL = True
except ImportError:
    HAS_PIL = False

logger = logging.getLogger(__name__)


# Known editing and graphic design software signatures (case-insensitive)
EDITING_SOFTWARE_SIGNATURES = [
    "adobe photoshop",
    "photoshop",
    "gimp",
    "canva",
    "paint.net",
    "photopea",
    "adobe lightroom",
    "lightroom",
    "snapseed",
    "pixlr",
    "picsart",
    "pixelmator",
    "affinity photo",
    "coreldraw",
    "adobe illustrator",
    "illustrator",
    "inkscape",
    "macromedia fireworks",
    "apple preview",
    "fotor",
    "befunky",
]


def extract_raw_metadata(image_input: Any) -> dict[str, Any]:
    """
    Extract all discoverable metadata tags, EXIF dictionary, and raw text headers.
    """
    raw_info: dict[str, Any] = {
        "format": None,
        "mode": None,
        "size": None,
        "exif": {},
        "info": {},
        "raw_string_matches": [],
    }

    raw_bytes: bytes | None = None

    if isinstance(image_input, (str, os.PathLike)):
        if os.path.exists(image_input):
            with open(image_input, "rb") as f:
                raw_bytes = f.read()
    elif isinstance(image_input, (bytes, bytearray)):
        raw_bytes = bytes(image_input)

    # Search raw bytes for software signatures (even if EXIF header was partially stripped)
    if raw_bytes:
        raw_lower = raw_bytes.lower()
        for sig in EDITING_SOFTWARE_SIGNATURES:
            if sig.encode("ascii", errors="ignore") in raw_lower:
                raw_info["raw_string_matches"].append(sig)

    if HAS_PIL:
        img: Image.Image | None = None
        try:
            if raw_bytes:
                img = Image.open(io.BytesIO(raw_bytes))
            elif isinstance(image_input, Image.Image):
                img = image_input
            elif isinstance(image_input, (str, os.PathLike)):
                img = Image.open(image_input)

            if img is not None:
                raw_info["format"] = img.format
                raw_info["mode"] = img.mode
                raw_info["size"] = img.size

                # Extract info dict (contains XMP, comments, icc profile info)
                if hasattr(img, "info") and isinstance(img.info, dict):
                    for k, v in img.info.items():
                        if isinstance(v, (str, int, float, bool)):
                            raw_info["info"][k] = v
                        elif isinstance(v, bytes):
                            # Try decoding short strings
                            try:
                                decoded = v.decode("utf-8", errors="ignore").strip()
                                if len(decoded) < 500:
                                    raw_info["info"][k] = decoded
                            except (UnicodeDecodeError, AttributeError):
                                logger.debug("Unable to decode image metadata value")

                # Extract standard EXIF tags
                exif_data = img.getexif()
                if exif_data:
                    for tag_id, val in exif_data.items():
                        tag_name = ExifTags.TAGS.get(tag_id, str(tag_id))
                        if isinstance(val, (str, int, float, bool, list)):
                            raw_info["exif"][tag_name] = val
                        elif isinstance(val, bytes):
                            try:
                                raw_info["exif"][tag_name] = val.decode("utf-8", errors="ignore").strip()
                            except (UnicodeDecodeError, AttributeError):
                                logger.debug("Unable to decode EXIF metadata value")

                # If IFD SubExif exists
                try:
                    for ifd_id in ExifTags.IFD:
                        try:
                            ifd = exif_data.get_ifd(ifd_id)
                            for tag_id, val in ifd.items():
                                tag_name = ExifTags.TAGS.get(tag_id, str(tag_id))
                                if isinstance(val, (str, int, float, bool, list)):
                                    raw_info["exif"][f"{ifd_id.name}_{tag_name}"] = val
                        except (AttributeError, KeyError, TypeError, ValueError):
                            logger.debug("Unable to read EXIF IFD", exc_info=True)
                except (AttributeError, KeyError, TypeError, ValueError):
                    logger.debug("Unable to enumerate EXIF IFDs", exc_info=True)
        except (AttributeError, OSError, TypeError, ValueError):
            logger.debug("Unable to extract image metadata", exc_info=True)

    return raw_info


def check_editing_software(metadata: dict[str, Any]) -> tuple[list[str], float]:
    """
    Scan metadata fields and raw markers for editing software signatures.

    Returns:
        Tuple of (detected_software_names, software_risk_score [0-100])
    """
    detected: list[str] = []

    # Search extracted EXIF fields
    exif = metadata.get("exif", {})
    info = metadata.get("info", {})
    raw_matches = metadata.get("raw_string_matches", [])

    candidates_to_check: list[str] = []

    for key in ["Software", "ProcessingSoftware", "ImageDescription", "Artist", "HostComputer", "XMP"]:
        if key in exif and isinstance(exif[key], str):
            candidates_to_check.append(exif[key])

    for key, val in info.items():
        if isinstance(val, str):
            candidates_to_check.append(val)

    # Direct raw string matches
    for match in raw_matches:
        if match not in detected:
            detected.append(match)

    for text in candidates_to_check:
        t_lower = text.lower()
        for sig in EDITING_SOFTWARE_SIGNATURES:
            if sig in t_lower and sig not in detected:
                detected.append(sig)

    risk_score = 0.0
    if detected:
        # Software detected heavily correlates with digital manipulation
        # Professional editing tools (Photoshop, GIMP, Photopea) give very high score
        primary_manipulators = ["adobe photoshop", "photoshop", "gimp", "photopea", "paint.net"]
        if any(p in detected for p in primary_manipulators):
            risk_score = 90.0
        else:
            risk_score = 70.0

    return detected, risk_score


def _parse_exif_date(date_str: Any) -> datetime | None:
    """Helper to parse EXIF date formats."""
    if not isinstance(date_str, str):
        return None
    # Standard EXIF: "YYYY:MM:DD HH:MM:SS" or "YYYY-MM-DD HH:MM:SS"
    clean_str = date_str.strip().replace("-", ":")
    for fmt in ("%Y:%m:%d %H:%M:%S", "%Y:%m:%d"):
        try:
            return datetime.strptime(clean_str, fmt).replace(tzinfo=timezone.utc)
        except ValueError:
            pass
    return None


def check_date_consistency(metadata: dict[str, Any]) -> tuple[list[str], float]:
    """
    Verify creation, digitization, and modification dates for inconsistencies.

    Returns:
        Tuple of (inconsistencies_list, date_risk_score [0-100])
    """
    inconsistencies: list[str] = []
    exif = metadata.get("exif", {})

    dt_orig_raw = exif.get("DateTimeOriginal") or exif.get("Exif_DateTimeOriginal")
    dt_dig_raw = exif.get("DateTimeDigitized") or exif.get("Exif_DateTimeDigitized")
    dt_mod_raw = exif.get("DateTime")  # Image modification time

    dt_orig = _parse_exif_date(dt_orig_raw)
    dt_dig = _parse_exif_date(dt_dig_raw)
    dt_mod = _parse_exif_date(dt_mod_raw)

    risk_score = 0.0
    now = datetime.now(timezone.utc)

    # 1. Check for future dates
    for label, dt in [("DateTimeOriginal", dt_orig), ("DateTimeDigitized", dt_dig), ("ModifyDate", dt_mod)]:
        if dt and dt > now:
            inconsistencies.append(f"{label} is set in the future ({dt})")
            risk_score = max(risk_score, 60.0)

    # 2. Check if modification date precedes creation date (impossible without clock tampering)
    if dt_orig and dt_mod:
        if dt_mod < dt_orig:
            inconsistencies.append(f"ModifyDate ({dt_mod}) is earlier than DateTimeOriginal ({dt_orig})")
            risk_score = max(risk_score, 75.0)
        elif (dt_mod - dt_orig).total_seconds() > 86400 * 30:  # modified months/years later
            inconsistencies.append(
                f"Image was modified {(dt_mod - dt_orig).days} days after original capture"
            )
            risk_score = max(risk_score, 45.0)

    # 3. Check digitization preceding creation
    if dt_orig and dt_dig and dt_dig < dt_orig:
        inconsistencies.append(f"DateTimeDigitized ({dt_dig}) is earlier than DateTimeOriginal ({dt_orig})")
        risk_score = max(risk_score, 50.0)

    return inconsistencies, risk_score


def analyze_metadata(image_input: Any) -> dict[str, Any]:
    """
    Analyze image metadata to detect digital editing software and timestamp anomalies.

    Returns:
        Structured dict with:
            - is_suspicious (bool)
            - metadata_score (float, 0-100)
            - software_detected (List[str])
            - date_inconsistencies (List[str])
            - flags (List[str])
            - metadata (Dict[str, Any])
    """
    meta = extract_raw_metadata(image_input)
    software_detected, sw_score = check_editing_software(meta)
    date_inconsistencies, date_score = check_date_consistency(meta)

    flags: list[str] = []
    if software_detected:
        flags.append(f"Editing software signature detected: {', '.join(software_detected)}")
    if date_inconsistencies:
        flags.extend(date_inconsistencies)

    # Composite metadata score
    overall_score = max(sw_score, date_score)
    if sw_score > 0 and date_score > 0:
        overall_score = min(100.0, sw_score + (date_score * 0.3))

    is_suspicious = overall_score >= 40.0

    return {
        "is_suspicious": is_suspicious,
        "metadata_score": round(overall_score, 2),
        "software_detected": software_detected,
        "date_inconsistencies": date_inconsistencies,
        "flags": flags,
        "metadata": meta,
    }
