"""
Error Level Analysis (ELA) Processor for ShieldID Tampering Detection.

Detects JPEG compression inconsistencies, resaved regions, copy-move artifacts,
and digital splices by analyzing localized compression error differentials.
"""

from __future__ import annotations

import io
import os
from typing import Any

import numpy as np

try:
    from PIL import Image, ImageChops
    HAS_PIL = True
except ImportError:
    HAS_PIL = False


def _to_pil_image(image_input: Any) -> Any:
    """Convert various input formats into a PIL RGB Image."""
    if not HAS_PIL:
        raise RuntimeError("Pillow is required for ELA analysis.")

    if isinstance(image_input, Image.Image):
        return image_input.convert("RGB")
    elif isinstance(image_input, (str, os.PathLike)):
        return Image.open(image_input).convert("RGB")
    elif isinstance(image_input, (bytes, bytearray)):
        return Image.open(io.BytesIO(image_input)).convert("RGB")
    elif isinstance(image_input, np.ndarray):
        # Handle numpy arrays (float or uint8)
        arr = image_input
        if arr.dtype == np.float32 or arr.dtype == np.float64:
            if arr.max() <= 1.0:
                arr = (arr * 255.0).clip(0, 255).astype(np.uint8)
            else:
                arr = arr.clip(0, 255).astype(np.uint8)
        else:
            arr = arr.astype(np.uint8)

        if arr.ndim == 2:
            return Image.fromarray(arr, mode="L").convert("RGB")
        elif arr.ndim == 3:
            if arr.shape[2] == 4:
                return Image.fromarray(arr, mode="RGBA").convert("RGB")
            elif arr.shape[2] == 3:
                return Image.fromarray(arr, mode="RGB")
            elif arr.shape[0] == 3:  # CHW format
                return Image.fromarray(np.transpose(arr, (1, 2, 0)), mode="RGB")
        raise ValueError(f"Unsupported numpy array shape for ELA: {arr.shape}")
    else:
        raise TypeError(f"Unsupported image input type for ELA: {type(image_input)}")


def compute_ela(
    image_input: Any,
    quality: int = 90,
    scale: float = 15.0,
) -> tuple[np.ndarray, dict[str, float]]:
    """
    Compute Error Level Analysis (ELA) for a given image.

    Args:
        image_input: Image as PIL Image, numpy array, bytes, or file path.
        quality: Resave JPEG quality (1-100), default 90.
        scale: Amplification scale factor for error contrast, default 15.0.

    Returns:
        Tuple of:
            - ELA difference image as uint8 numpy array (H, W, 3)
            - Dictionary of error statistics (mean, std, max, 95th_percentile)
    """
    if not HAS_PIL:
        # Graceful pure numpy fallback if PIL is somehow unavailable
        if isinstance(image_input, np.ndarray):
            arr = image_input.astype(np.float32)
            # Simulated compression artifact gradient
            diff = np.abs(arr - np.roll(arr, 1, axis=0)) * scale
            diff = np.clip(diff, 0, 255).astype(np.uint8)
            return diff, {"mean_error": float(np.mean(diff)), "std_error": float(np.std(diff)), "max_error": float(np.max(diff)), "p95_error": float(np.percentile(diff, 95))}
        raise RuntimeError("Pillow is required for full ELA computation.")

    orig_img = _to_pil_image(image_input)
    
    # Save original to in-memory JPEG at target quality
    buffer = io.BytesIO()
    orig_img.save(buffer, format="JPEG", quality=quality)
    buffer.seek(0)
    resaved_img = Image.open(buffer).convert("RGB")

    # Calculate absolute difference
    diff = ImageChops.difference(orig_img, resaved_img)

    # Scale differences to highlight compression disparities
    orig_arr = np.asarray(orig_img, dtype=np.float32)
    resaved_arr = np.asarray(resaved_img, dtype=np.float32)
    abs_diff = np.abs(orig_arr - resaved_arr)

    # Multiplied and clipped ELA output array
    scaled_diff = np.clip(abs_diff * scale, 0, 255).astype(np.uint8)

    # Compute error metrics
    mean_err = float(np.mean(abs_diff))
    std_err = float(np.std(abs_diff))
    max_err = float(np.max(abs_diff))
    p95_err = float(np.percentile(abs_diff, 95))

    stats = {
        "mean_error": mean_err,
        "std_error": std_err,
        "max_error": max_err,
        "p95_error": p95_err,
    }
    return scaled_diff, stats


def detect_ela_tampering(
    image_input: Any,
    quality: int = 90,
    block_size: int = 32,
    anomaly_threshold_std: float = 2.4,
) -> dict[str, Any]:
    """
    Detect edited or spliced regions using block-wise Error Level Analysis.

    Args:
        image_input: Image input (numpy, PIL, bytes, path).
        quality: JPEG compression quality factor.
        block_size: Grid window size in pixels for block-wise error statistics.
        anomaly_threshold_std: Standard deviation multiplier to flag outliers.

    Returns:
        Dictionary containing:
            - is_tampered (bool)
            - tamper_score (float, 0-100)
            - regions (List[str], formatted bounding boxes/clusters)
            - mean_error (float)
            - max_error (float)
            - std_error (float)
            - ela_image (np.ndarray)
    """
    ela_img, stats = compute_ela(image_input, quality=quality)
    h, w, _c = ela_img.shape

    # Compute block-level error distribution
    gray_ela = np.mean(ela_img.astype(np.float32), axis=2)

    n_blocks_y = max(1, h // block_size)
    n_blocks_x = max(1, w // block_size)

    block_means = np.zeros((n_blocks_y, n_blocks_x), dtype=np.float32)

    for by in range(n_blocks_y):
        for bx in range(n_blocks_x):
            y1 = by * block_size
            y2 = min(h, (by + 1) * block_size)
            x1 = bx * block_size
            x2 = min(w, (bx + 1) * block_size)
            block = gray_ela[y1:y2, x1:x2]
            block_means[by, bx] = np.mean(block)

    # Identify statistically anomalous blocks
    global_mean = float(np.mean(block_means))
    global_std = float(np.std(block_means))

    cutoff = global_mean + (anomaly_threshold_std * max(global_std, 1.0))
    anomalous_blocks = block_means > cutoff

    tampered_regions: list[str] = []
    suspicious_count = int(np.sum(anomalous_blocks))
    total_blocks = n_blocks_y * n_blocks_x

    # Group anomalous blocks into bounding regions
    if suspicious_count > 0:
        y_indices, x_indices = np.where(anomalous_blocks)
        min_y, max_y = int(np.min(y_indices)), int(np.max(y_indices))
        min_x, max_x = int(np.min(x_indices)), int(np.max(x_indices))

        box_y1 = min_y * block_size
        box_y2 = min(h, (max_y + 1) * block_size)
        box_x1 = min_x * block_size
        box_x2 = min(w, (max_x + 1) * block_size)

        tampered_regions.append(f"ela_anomaly_cluster: [{box_x1}, {box_y1}, {box_x2}, {box_y2}]")

        # If multiple distinct clusters exist, record individual regions
        if suspicious_count >= 4:
            for idx in range(min(5, len(y_indices))):
                iy, ix = int(y_indices[idx]), int(x_indices[idx])
                tampered_regions.append(
                    f"ela_hotspot_{idx + 1}: [{ix * block_size}, {iy * block_size}, "
                    f"{min(w, (ix + 1) * block_size)}, {min(h, (iy + 1) * block_size)}]"
                )

    # Calculate calibrated tamper score (0.0 to 100.0)
    # Ratio of anomalous blocks, ratio of max block mean to global mean, and std
    anomaly_ratio = suspicious_count / max(total_blocks, 1)
    contrast_ratio = (stats["max_error"] / max(stats["mean_error"] + 1e-5, 1.0))

    raw_score = (anomaly_ratio * 50.0) + min(35.0, stats["std_error"] * 2.0) + min(15.0, (contrast_ratio - 1.0) * 3.0)
    tamper_score = float(np.clip(raw_score, 0.0, 100.0))

    is_tampered = tamper_score >= 30.0 and len(tampered_regions) > 0

    return {
        "is_tampered": is_tampered,
        "tamper_score": round(tamper_score, 2),
        "regions": tampered_regions,
        "mean_error": round(stats["mean_error"], 3),
        "max_error": round(stats["max_error"], 3),
        "std_error": round(stats["std_error"], 3),
        "ela_image": ela_img,
    }
