"""Headless banknote template comparison utilities.

This module extracts the reusable ORB and SSIM ideas from the exploratory
currency notebooks without GUI state, notebook magics, or fixed file paths.
"""

from dataclasses import dataclass

import cv2
import numpy as np


@dataclass(frozen=True)
class TemplateMatchResult:
    """Similarity diagnostics for a query image and a reference template."""

    ssim_score: float
    matched_keypoints: int
    inlier_matches: int
    homography_found: bool

    @property
    def is_similar(self) -> bool:
        """Return whether the images meet conservative similarity criteria."""
        return self.ssim_score >= 0.70 and self.inlier_matches >= 4


def _to_gray(image: np.ndarray) -> np.ndarray:
    if image is None or image.size == 0:
        raise ValueError("Image must not be empty")
    if image.ndim == 2:
        return image.astype(np.uint8, copy=False)
    if image.ndim == 3 and image.shape[2] == 3:
        return cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    raise ValueError("Image must be grayscale or a 3-channel BGR image")


def structural_similarity(reference: np.ndarray, query: np.ndarray) -> float:
    """Compute a stable luminance/contrast/structure score in ``[0, 1]``."""
    reference_gray = _to_gray(reference)
    query_gray = _to_gray(query)
    height = min(reference_gray.shape[0], query_gray.shape[0])
    width = min(reference_gray.shape[1], query_gray.shape[1])
    if height < 2 or width < 2:
        raise ValueError("Images must be at least 2x2 pixels")

    size = (width, height)
    first = cv2.resize(reference_gray, size, interpolation=cv2.INTER_AREA).astype(
        np.float32
    )
    second = cv2.resize(query_gray, size, interpolation=cv2.INTER_AREA).astype(
        np.float32
    )
    mean_first = cv2.GaussianBlur(first, (11, 11), 1.5)
    mean_second = cv2.GaussianBlur(second, (11, 11), 1.5)
    variance_first = cv2.GaussianBlur(first * first, (11, 11), 1.5) - mean_first**2
    variance_second = cv2.GaussianBlur(second * second, (11, 11), 1.5) - mean_second**2
    covariance = cv2.GaussianBlur(first * second, (11, 11), 1.5) - (
        mean_first * mean_second
    )

    c1 = 6.5025
    c2 = 58.5225
    score = ((2 * mean_first * mean_second + c1) * (2 * covariance + c2)) / (
        (mean_first**2 + mean_second**2 + c1)
        * (variance_first + variance_second + c2)
    )
    return float(np.clip(np.mean(score), 0.0, 1.0))


def compare_templates(
    reference: np.ndarray,
    query: np.ndarray,
    *,
    max_keypoints: int = 700,
    ratio_threshold: float = 0.75,
) -> TemplateMatchResult:
    """Compare two banknote regions using SSIM and ORB geometric matches."""
    if max_keypoints < 1:
        raise ValueError("max_keypoints must be positive")
    if not 0.0 < ratio_threshold < 1.0:
        raise ValueError("ratio_threshold must be between 0 and 1")

    reference_gray = _to_gray(reference)
    query_gray = _to_gray(query)
    similarity = structural_similarity(reference_gray, query_gray)
    orb = cv2.ORB_create(nfeatures=max_keypoints, edgeThreshold=15)
    reference_points, reference_descriptors = orb.detectAndCompute(reference_gray, None)
    query_points, query_descriptors = orb.detectAndCompute(query_gray, None)
    if reference_descriptors is None or query_descriptors is None:
        return TemplateMatchResult(similarity, 0, 0, False)

    matcher = cv2.BFMatcher(cv2.NORM_HAMMING)
    pairs = matcher.knnMatch(reference_descriptors, query_descriptors, k=2)
    good_matches = [
        first
        for first, second in pairs
        if first.distance < ratio_threshold * second.distance
    ]
    inliers = 0
    homography_found = False
    if len(good_matches) >= 4:
        source = np.float32(
            [reference_points[item.queryIdx].pt for item in good_matches]
        ).reshape(-1, 1, 2)
        destination = np.float32(
            [query_points[item.trainIdx].pt for item in good_matches]
        ).reshape(-1, 1, 2)
        _homography, mask = cv2.findHomography(source, destination, cv2.RANSAC, 5.0)
        if mask is not None:
            homography_found = True
            inliers = int(mask.ravel().sum())

    return TemplateMatchResult(
        ssim_score=round(similarity, 4),
        matched_keypoints=len(good_matches),
        inlier_matches=inliers,
        homography_found=homography_found,
    )
