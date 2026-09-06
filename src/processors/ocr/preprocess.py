"""
OCR Preprocessing module for document images.

Provides image deskewing, binarization, noise removal, and contrast enhancement
to maximize OCR accuracy on Indian identity documents (Passport, Aadhaar, PAN, DL, Voter ID).
"""

import math
from pathlib import Path

import cv2
import numpy as np


def load_image(input_data: np.ndarray | bytes | str | Path) -> np.ndarray:
    """
    Load image from a file path, raw bytes, or numpy ndarray.

    Returns:
        np.ndarray: BGR image array.
    """
    if isinstance(input_data, np.ndarray):
        return input_data.copy()

    if isinstance(input_data, (str, Path)):
        path_str = str(input_data)
        img = cv2.imread(path_str, cv2.IMREAD_COLOR)
        if img is None:
            raise ValueError(f"Unable to read image from path: {path_str}")
        return img

    if isinstance(input_data, (bytes, bytearray)):
        nparr = np.frombuffer(input_data, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        if img is None:
            raise ValueError("Unable to decode image from raw bytes")
        return img

    raise TypeError(
        f"Unsupported input type {type(input_data)}. Expected np.ndarray, bytes, str, or Path."
    )


def enhance_contrast(
    image: np.ndarray,
    clip_limit: float = 2.0,
    tile_grid_size: tuple[int, int] = (8, 8),
) -> np.ndarray:
    """
    Enhance image contrast using CLAHE (Contrast Limited Adaptive Histogram Equalization).

    Supports both 3-channel (BGR/RGB) and single-channel grayscale images.
    """
    if image is None or image.size == 0:
        raise ValueError("Empty or invalid image passed to enhance_contrast")

    clahe = cv2.createCLAHE(clipLimit=clip_limit, tileGridSize=tile_grid_size)

    if len(image.shape) == 2:
        return clahe.apply(image)

    if len(image.shape) == 3:
        # Convert to LAB color space and apply CLAHE to the Luminance (L) channel
        lab = cv2.cvtColor(image, cv2.COLOR_BGR2LAB)
        l_channel, a_channel, b_channel = cv2.split(lab)
        l_enhanced = clahe.apply(l_channel)
        merged = cv2.merge([l_enhanced, a_channel, b_channel])
        return cv2.cvtColor(merged, cv2.COLOR_LAB2BGR)

    return image


def denoise(
    image: np.ndarray,
    method: str = "bilateral",
    kernel_size: int = 3,
) -> np.ndarray:
    """
    Remove noise from image while preserving sharp document text boundaries.

    Methods:
        - "bilateral": Preserves sharp text edges while smoothing background noise.
        - "median": Eliminates salt-and-pepper noise.
        - "gaussian": Smooth Gaussian blurring.
        - "morph_open": Morphological opening with rectangular kernel to eliminate speckles.
    """
    if image is None or image.size == 0:
        raise ValueError("Empty or invalid image passed to denoise")

    # Ensure kernel_size is positive odd integer
    if kernel_size % 2 == 0:
        kernel_size += 1

    method_lower = method.lower()
    if method_lower == "bilateral":
        if len(image.shape) == 3:
            return cv2.bilateralFilter(image, d=9, sigmaColor=75, sigmaSpace=75)
        return cv2.bilateralFilter(image, d=9, sigmaColor=75, sigmaSpace=75)

    if method_lower == "median":
        return cv2.medianBlur(image, kernel_size)

    if method_lower == "gaussian":
        return cv2.GaussianBlur(image, (kernel_size, kernel_size), 0)

    if method_lower == "morph_open":
        kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (kernel_size, kernel_size))
        return cv2.morphologyEx(image, cv2.MORPH_OPEN, kernel)

    # Fallback to bilateral
    return cv2.bilateralFilter(image, d=9, sigmaColor=75, sigmaSpace=75)


def calculate_skew_angle(image: np.ndarray) -> float:
    """
    Calculate the skew angle of text/document in degrees.

    Returns:
        float: Skew angle in degrees (typically between -45 and 45).
    """
    if len(image.shape) == 3:
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    else:
        gray = image.copy()

    # Thresholding to isolate text content
    _, thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)

    # Find non-zero points (text pixels)
    coords = np.column_stack(np.where(thresh > 0))
    if len(coords) < 50:
        return 0.0

    # Minimum area rectangle around all text pixels
    rect = cv2.minAreaRect(coords)
    angle = rect[-1]

    # cv2.minAreaRect angle normalization:
    # Older OpenCV: [-90, 0), Newer OpenCV: [0, 90) or [-90, 0)
    if angle < -45:
        angle = -(90 + angle)
    elif angle > 45:
        angle = 90 - angle

    # Check using HoughLines for confirmation if angle is large
    edges = cv2.Canny(gray, 50, 150, apertureSize=3)
    lines = cv2.HoughLinesP(
        edges, 1, np.pi / 180, threshold=100, minLineLength=image.shape[1] // 5, maxLineGap=10
    )

    if lines is not None and len(lines) > 0:
        hough_angles = []
        for line in lines:
            x1, y1, x2, y2 = line[0]
            if x2 - x1 != 0:
                rad = math.atan2(y2 - y1, x2 - x1)
                deg = math.degrees(rad)
                # Keep near horizontal lines (|deg| <= 45)
                if abs(deg) <= 45:
                    hough_angles.append(deg)
        if len(hough_angles) >= 3:
            median_angle = float(np.median(hough_angles))
            # If Hough and minAreaRect agree roughly or Hough is dominant, use median
            if abs(median_angle) <= 45:
                angle = median_angle

    return float(angle)


def deskew(
    image: np.ndarray,
    background_color: tuple[int, int, int] = (255, 255, 255),
    angle: float | None = None,
) -> tuple[np.ndarray, float]:
    """
    Deskew document image to align horizontal text lines.

    Args:
        image: Input image (BGR or grayscale).
        background_color: Fill color for exposed borders (default white).
        angle: Explicit angle in degrees. If None, angle is auto-detected.

    Returns:
        Tuple[np.ndarray, float]: (deskewed_image, applied_angle_in_degrees)
    """
    if image is None or image.size == 0:
        raise ValueError("Empty or invalid image passed to deskew")

    if angle is None:
        angle = calculate_skew_angle(image)

    # If skew angle is negligible, return original image
    if abs(angle) < 0.3:
        return image, 0.0

    (h, w) = image.shape[:2]
    center = (w // 2, h // 2)

    rot_mat = cv2.getRotationMatrix2D(center, angle, 1.0)

    # Compute new bounding dimensions so corners aren't cropped
    cos = np.abs(rot_mat[0, 0])
    sin = np.abs(rot_mat[0, 1])
    new_w = int((h * sin) + (w * cos))
    new_h = int((h * cos) + (w * sin))

    rot_mat[0, 2] += (new_w / 2) - center[0]
    rot_mat[1, 2] += (new_h / 2) - center[1]

    fill_color = background_color if len(image.shape) == 3 else 255
    deskewed = cv2.warpAffine(
        image,
        rot_mat,
        (new_w, new_h),
        flags=cv2.INTER_CUBIC,
        borderMode=cv2.BORDER_CONSTANT,
        borderValue=fill_color,
    )

    return deskewed, angle


def binarize(
    image: np.ndarray,
    method: str = "otsu",
    block_size: int = 15,
    c: int = 8,
) -> np.ndarray:
    """
    Convert document image to binary (black and white) image.

    Methods:
        - "otsu": Global Otsu's thresholding (best for clean scans).
        - "adaptive_gaussian": Local Gaussian adaptive thresholding (best for shadows/uneven light).
        - "adaptive_mean": Local Mean adaptive thresholding.
    """
    if image is None or image.size == 0:
        raise ValueError("Empty or invalid image passed to binarize")

    if len(image.shape) == 3:
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    else:
        gray = image.copy()

    # Ensure block_size is odd and >= 3
    if block_size % 2 == 0:
        block_size += 1
    block_size = max(3, block_size)

    method_lower = method.lower()
    if method_lower == "otsu":
        _, binary = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
        return binary

    if method_lower == "adaptive_gaussian":
        return cv2.adaptiveThreshold(
            gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, block_size, c
        )

    if method_lower == "adaptive_mean":
        return cv2.adaptiveThreshold(
            gray, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, block_size, c
        )

    # Default fallback
    _, binary = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    return binary


def preprocess_document(
    input_data: np.ndarray | bytes | str | Path,
    deskew_enabled: bool = True,
    denoise_method: str = "bilateral",
    binarize_method: str | None = None,
) -> np.ndarray:
    """
    Full preprocessing pipeline for Indian document OCR.

    1. Load image (array / bytes / file path)
    2. Enhance contrast via CLAHE
    3. Noise removal
    4. Deskew image to align horizontal text lines
    5. Optional binarization (if binarize_method is provided)

    Returns:
        np.ndarray: Preprocessed image ready for OCR text recognition.
    """
    img = load_image(input_data)
    img = enhance_contrast(img)
    img = denoise(img, method=denoise_method)

    if deskew_enabled:
        img, _ = deskew(img)

    if binarize_method is not None:
        img = binarize(img, method=binarize_method)

    return img
