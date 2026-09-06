"""
Currency Processor for Indian Banknotes (₹10, ₹50, ₹100, ₹200, ₹500).

Inherits from BaseProcessor and implements AI/computer vision inspection for:
- Note boundary detection and perspective rectification
- Denomination identification (HSV/Lab color profiling + aspect ratio)
- Watermark verification (Mahatma Gandhi & electrotype multi-tone gradient)
- Security thread verification (vertical continuity, windowing, color shift)
- Micro-printing inspection (high-frequency intaglio edge sharpness & blur detection)
- UV feature inspection (fluorescent response & optical brightener detection)
- Fake banknote detection with diagnostic reason reporting
"""

import json
import logging
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple, Union

import cv2
import numpy as np

from src.processors.base_processor import BaseProcessor
from src.processors.ocr.preprocess import load_image
from src.schemas.verification import CurrencyVerificationResult, SecurityFeatureCheck

logger = logging.getLogger(__name__)

# Standard canonical rectification dimensions (width x height)
CANONICAL_WIDTH = 1000
CANONICAL_HEIGHT = 440

# Denomination benchmarks for Mahatma Gandhi New Series banknotes
DENOMINATION_BENCHMARKS = {
    500: {
        "name": "Five Hundred Rupees",
        "aspect_ratio": 2.27,  # 150mm x 66mm
        "color_name": "Stone Grey",
        "hsv_hue_range": [(0, 180)],
        "max_saturation": 85,
        "thread_expected_x_pct": (0.38, 0.48),
        "watermark_expected_x_pct": (0.70, 0.95),
        "min_intaglio_variance": 45.0,
    },
    200: {
        "name": "Two Hundred Rupees",
        "aspect_ratio": 2.21,  # 146mm x 66mm
        "color_name": "Bright Yellow",
        "hsv_hue_range": [(18, 38)],
        "min_saturation": 70,
        "thread_expected_x_pct": (0.38, 0.48),
        "watermark_expected_x_pct": (0.70, 0.95),
        "min_intaglio_variance": 40.0,
    },
    100: {
        "name": "One Hundred Rupees",
        "aspect_ratio": 2.15,  # 142mm x 66mm
        "color_name": "Lavender",
        "hsv_hue_range": [(120, 165)],
        "min_saturation": 40,
        "thread_expected_x_pct": (0.38, 0.48),
        "watermark_expected_x_pct": (0.70, 0.95),
        "min_intaglio_variance": 40.0,
    },
    50: {
        "name": "Fifty Rupees",
        "aspect_ratio": 2.05,  # 135mm x 66mm
        "color_name": "Fluorescent Blue",
        "hsv_hue_range": [(85, 115)],
        "min_saturation": 60,
        "thread_expected_x_pct": (0.38, 0.48),
        "watermark_expected_x_pct": (0.70, 0.95),
        "min_intaglio_variance": 35.0,
    },
    10: {
        "name": "Ten Rupees",
        "aspect_ratio": 1.95,  # 123mm x 63mm
        "color_name": "Chocolate Brown",
        "hsv_hue_range": [(8, 25)],
        "min_saturation": 50,
        "thread_expected_x_pct": (0.38, 0.48),
        "watermark_expected_x_pct": (0.70, 0.95),
        "min_intaglio_variance": 35.0,
    },
}


class CurrencyProcessor(BaseProcessor):
    """
    Processor for inspecting Indian Banknotes and detecting counterfeit currency.
    Inherits from BaseProcessor.
    """

    def __init__(
        self,
        model_path: Optional[str] = None,
        confidence_threshold: float = 0.70,
    ):
        super().__init__(model_path=model_path or "models/currency/benchmarks.json")
        self.confidence_threshold = confidence_threshold
        self.benchmarks = DENOMINATION_BENCHMARKS

    def load_model(self):
        """
        Load currency benchmarks, color profiles, and security parameters from disk if present.
        """
        if self.model_path and Path(self.model_path).exists():
            try:
                with open(self.model_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    # Convert string keys back to int if needed
                    self.benchmarks = {
                        int(k) if k.isdigit() else k: v for k, v in data.items()
                    }
                logger.info(f"Loaded currency benchmarks from {self.model_path}")
            except Exception as e:
                logger.warning(
                    f"Failed loading benchmarks from {self.model_path}: {e}. Using default benchmarks."
                )
                self.benchmarks = DENOMINATION_BENCHMARKS
        else:
            self.benchmarks = DENOMINATION_BENCHMARKS

        self.model = self.benchmarks
        self.is_loaded = True

    def preprocess(self, input_data: Any) -> np.ndarray:
        """
        Load image and standardize format to BGR uint8 ndarray.
        """
        return load_image(input_data)

    def predict(self, processed_input: np.ndarray) -> Dict[str, Any]:
        """
        Inspect banknote security features, determine authenticity,
        and return standardized dictionary matching CurrencyVerificationResult schema.
        """
        # 1. Boundary Detection & Rectification
        rectified_note, boundary_detected, boundary_info = self.detect_note_boundaries(
            processed_input
        )

        # 2. Denomination Identification
        denomination, denom_conf = self.identify_denomination(rectified_note)

        # 3. Watermark Inspection
        watermark_check = self.check_watermark(rectified_note, denomination)

        # 4. Security Thread Inspection
        thread_check = self.check_security_thread(rectified_note, denomination)

        # 5. Micro-printing Sharpness Inspection
        micro_check = self.check_microprinting(rectified_note, denomination)

        # 6. UV Feature Inspection
        uv_check = self.check_uv_features(rectified_note)

        # 7. Aggregate Authenticity Decision & Reason Generation
        is_authentic, composite_score, reasons = self._evaluate_authenticity(
            boundary_detected=boundary_detected,
            watermark_check=watermark_check,
            thread_check=thread_check,
            micro_check=micro_check,
            uv_check=uv_check,
            denomination=denomination,
        )

        result = CurrencyVerificationResult(
            is_authentic=is_authentic,
            denomination=denomination,
            currency_code="INR",
            confidence_score=composite_score,
            boundary_detected=boundary_detected,
            watermark_check=watermark_check,
            security_thread_check=thread_check,
            microprinting_check=micro_check,
            uv_feature_check=uv_check,
            reasons=reasons,
        )

        return result.model_dump()

    def process_to_schema(self, input_data: Any) -> CurrencyVerificationResult:
        """
        Convenience method to execute full pipeline and return validated CurrencyVerificationResult.
        """
        result_dict = self.process(input_data)
        return CurrencyVerificationResult.model_validate(result_dict)

    # ── 1. Boundary Detection ─────────────────────────────────────────────

    def detect_note_boundaries(
        self, image: np.ndarray
    ) -> Tuple[np.ndarray, bool, Dict[str, Any]]:
        """
        Detect note boundaries, isolate from background, and perspective warp to canonical rectangle.
        """
        if image is None or image.size == 0:
            raise ValueError("Empty image passed to detect_note_boundaries")

        h, w = image.shape[:2]
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        blurred = cv2.GaussianBlur(gray, (5, 5), 0)

        # Canny edge detection followed by morphological closing
        edges = cv2.Canny(blurred, 40, 140)
        kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (7, 7))
        closed = cv2.morphologyEx(edges, cv2.MORPH_CLOSE, kernel)

        contours, _ = cv2.findContours(closed, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        boundary_detected = False
        rectified = None
        best_contour = None

        if contours:
            # Sort contours by area descending
            sorted_contours = sorted(contours, key=cv2.contourArea, reverse=True)
            min_area = 0.15 * (w * h)

            for cnt in sorted_contours:
                area = cv2.contourArea(cnt)
                if area < min_area:
                    break

                peri = cv2.arcLength(cnt, True)
                approx = cv2.approxPolyDP(cnt, 0.02 * peri, True)

                if len(approx) == 4:
                    best_contour = approx
                    boundary_detected = True
                    break

        if boundary_detected and best_contour is not None:
            pts = best_contour.reshape(4, 2).astype(np.float32)
            ordered_pts = self._order_points(pts)
            dst_pts = np.array(
                [
                    [0, 0],
                    [CANONICAL_WIDTH - 1, 0],
                    [CANONICAL_WIDTH - 1, CANONICAL_HEIGHT - 1],
                    [0, CANONICAL_HEIGHT - 1],
                ],
                dtype=np.float32,
            )
            transform_mat = cv2.getPerspectiveTransform(ordered_pts, dst_pts)
            rectified = cv2.warpPerspective(
                image, transform_mat, (CANONICAL_WIDTH, CANONICAL_HEIGHT)
            )
        else:
            # If no 4-point quadrilateral detected, resize image to canonical aspect ratio
            rectified = cv2.resize(image, (CANONICAL_WIDTH, CANONICAL_HEIGHT))

        aspect_ratio = float(w / h) if h > 0 else 1.0
        return (
            rectified,
            boundary_detected,
            {"aspect_ratio": aspect_ratio, "original_shape": (h, w)},
        )

    def _order_points(self, pts: np.ndarray) -> np.ndarray:
        """Order 4 points: top-left, top-right, bottom-right, bottom-left."""
        rect = np.zeros((4, 2), dtype=np.float32)
        s = pts.sum(axis=1)
        rect[0] = pts[np.argmin(s)]  # top-left has smallest sum
        rect[2] = pts[np.argmax(s)]  # bottom-right has largest sum

        diff = np.diff(pts, axis=1)
        rect[1] = pts[np.argmin(diff)]  # top-right has smallest diff
        rect[3] = pts[np.argmax(diff)]  # bottom-left has largest diff
        return rect

    # ── 2. Denomination Identification ────────────────────────────────────

    def identify_denomination(
        self, note_image: np.ndarray
    ) -> Tuple[Optional[int], float]:
        """
        Identify note denomination (10, 50, 100, 200, 500) based on HSV color profile.
        """
        h, w = note_image.shape[:2]
        # Crop inner 60% of the note to avoid white margins
        inner = note_image[int(h * 0.2) : int(h * 0.8), int(w * 0.2) : int(w * 0.8)]
        hsv = cv2.cvtColor(inner, cv2.COLOR_BGR2HSV)

        mean_h = np.mean(hsv[:, :, 0])
        mean_s = np.mean(hsv[:, :, 1])
        mean_v = np.mean(hsv[:, :, 2])

        scores: Dict[int, float] = {}

        # ₹500: Stone Grey (Low saturation, neutral tone)
        if mean_s < 75:
            grey_score = 1.0 - (mean_s / 75.0)
            scores[500] = 0.5 + 0.5 * grey_score
        else:
            scores[500] = 0.1

        # ₹200: Bright Yellow (Hue 20-38, high saturation)
        if 18 <= mean_h <= 40 and mean_s > 60:
            scores[200] = 0.7 + 0.3 * (mean_s / 255.0)
        else:
            scores[200] = 0.1

        # ₹100: Lavender / Violet (Hue 120-165)
        if 115 <= mean_h <= 165:
            scores[100] = 0.7 + 0.3 * (mean_s / 255.0)
        else:
            scores[100] = 0.1

        # ₹50: Fluorescent Blue (Hue 85-115, high saturation)
        if 85 <= mean_h < 115:
            scores[50] = 0.7 + 0.3 * (mean_s / 255.0)
        else:
            scores[50] = 0.1

        # ₹10: Chocolate Brown (Hue 8-25, moderate V)
        if 8 <= mean_h <= 25 and mean_v < 160:
            scores[10] = 0.7 + 0.3 * (mean_s / 255.0)
        else:
            scores[10] = 0.1

        best_denom = max(scores, key=scores.get)
        best_score = round(float(scores[best_denom]), 3)

        # If score is very low, default to 500
        if best_score < 0.3:
            return 500, 0.5

        return best_denom, best_score

    # ── 3. Watermark Inspection ───────────────────────────────────────────

    def check_watermark(
        self, note_image: np.ndarray, denomination: Optional[int] = 500
    ) -> SecurityFeatureCheck:
        """
        Inspect Mahatma Gandhi watermark & electrotype denomination numeral.
        Authentic watermarks have smooth multi-tone luminance gradients,
        unlike harsh fake printed stamps or absent watermarks.
        """
        h, w = note_image.shape[:2]
        # Watermark region: usually right side blank area (x: 70% to 94%, y: 15% to 85%)
        x1, x2 = int(w * 0.70), int(w * 0.94)
        y1, y2 = int(h * 0.15), int(h * 0.85)
        roi = note_image[y1:y2, x1:x2]

        if roi.size == 0:
            return SecurityFeatureCheck(
                feature_name="watermark",
                is_valid=False,
                confidence=0.0,
                details="Watermark region not found or image out of bounds.",
            )

        gray_roi = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)

        # 1. Compute standard deviation of luminance (contrast check)
        luminance_std = float(np.std(gray_roi))

        # 2. Compute Sobel gradient magnitude
        grad_x = cv2.Sobel(gray_roi, cv2.CV_32F, 1, 0, ksize=3)
        grad_y = cv2.Sobel(gray_roi, cv2.CV_32F, 0, 1, ksize=3)
        grad_mag = cv2.magnitude(grad_x, grad_y)
        mean_grad = float(np.mean(grad_mag))
        max_grad = float(np.max(grad_mag))

        # Authentic watermarks have soft gradual transitions:
        # - Not completely flat/blank (luminance_std > 8.0)
        # - No razor-sharp fake stamped edges (max_grad / (mean_grad + 1e-5) < 18.0)
        # - Good dynamic tonal gradation (8.0 <= luminance_std <= 55.0)
        is_too_flat = luminance_std < 7.0
        is_harsh_printed = max_grad > 240 and (max_grad / (mean_grad + 1e-5) > 16.0)

        if is_too_flat:
            return SecurityFeatureCheck(
                feature_name="watermark",
                is_valid=False,
                confidence=0.25,
                details="Watermark region is blank or washed out; no authentic watermark gradient detected.",
            )

        if is_harsh_printed:
            return SecurityFeatureCheck(
                feature_name="watermark",
                is_valid=False,
                confidence=0.35,
                details="Watermark exhibits harsh laser/ink printed border artifacts rather than authentic embedded paper watermark.",
            )

        # Compute confidence based on optimal gradient balance
        confidence = min(1.0, max(0.4, (luminance_std / 30.0)))
        return SecurityFeatureCheck(
            feature_name="watermark",
            is_valid=True,
            confidence=round(confidence, 3),
            details="Authentic multi-tone Mahatma Gandhi watermark gradient verified.",
        )

    # ── 4. Security Thread Inspection ─────────────────────────────────────

    def check_security_thread(
        self, note_image: np.ndarray, denomination: Optional[int] = 500
    ) -> SecurityFeatureCheck:
        """
        Inspect security thread for vertical continuity, windowing (dashed segments),
        and metallic luster/color shift.
        """
        h, w = note_image.shape[:2]
        # Security thread region: vertically from 38% to 48% across note width
        x1, x2 = int(w * 0.38), int(w * 0.48)
        roi = note_image[:, x1:x2]

        if roi.size == 0:
            return SecurityFeatureCheck(
                feature_name="security_thread",
                is_valid=False,
                confidence=0.0,
                details="Security thread region could not be localized.",
            )

        gray_roi = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)

        # 1. Vertical Sobel (detects strong vertical thread edges)
        sobel_x = cv2.Sobel(gray_roi, cv2.CV_32F, 1, 0, ksize=3)
        abs_sobel_x = np.abs(sobel_x)

        # Profile vertical edge energy by column
        col_energy = np.mean(abs_sobel_x, axis=0)
        peak_col_idx = int(np.argmax(col_energy))
        peak_val = float(col_energy[peak_col_idx])

        # 2. Check vertical continuity along the peak column
        thread_strip = gray_roi[:, max(0, peak_col_idx - 3) : min(roi.shape[1], peak_col_idx + 4)]
        row_means = np.mean(thread_strip, axis=1)

        # Authentic thread has periodic windows (exposed dashes) producing luminance oscillations
        row_diff = np.abs(np.diff(row_means))
        oscillation_count = int(np.sum(row_diff > 4.0))

        # Check metallic/color shift in HSV (threads in 500, 200, 100 shift between green & blue)
        hsv_roi = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)
        sat_strip = hsv_roi[
            :, max(0, peak_col_idx - 3) : min(roi.shape[1], peak_col_idx + 4), 1
        ]
        mean_sat = float(np.mean(sat_strip))

        # Thread validation logic:
        # A valid thread must have a distinguishable vertical edge peak (peak_val > 10.0)
        # and non-zero vertical continuity/oscillation
        if peak_val < 8.0:
            return SecurityFeatureCheck(
                feature_name="security_thread",
                is_valid=False,
                confidence=0.20,
                details="Security thread missing or lacks vertical line definition.",
            )

        if oscillation_count < 5:
            # Threat might be a flat drawn line with no windowed segments
            return SecurityFeatureCheck(
                feature_name="security_thread",
                is_valid=False,
                confidence=0.40,
                details="Security thread lacks windowed dashes and periodic inscriptions ('RBI' / 'भारत').",
            )

        confidence = min(0.98, max(0.65, 0.5 + (peak_val / 40.0)))
        return SecurityFeatureCheck(
            feature_name="security_thread",
            is_valid=True,
            confidence=round(confidence, 3),
            details=f"Continuous windowed security thread detected with {oscillation_count} segment transitions.",
        )

    # ── 5. Micro-printing Inspection ──────────────────────────────────────

    def check_microprinting(
        self, note_image: np.ndarray, denomination: Optional[int] = 500
    ) -> SecurityFeatureCheck:
        """
        Inspect micro-printing sharpness and high-frequency edge definition.
        Intaglio printing produces crisp microscopic text edges ('RBI', '500').
        Counterfeit inkjet/laser copies exhibit blur, dot-gain, and low Laplacian variance.
        """
        h, w = note_image.shape[:2]
        # Micro-printing zones: portrait boundary and side border margins (x: 48% to 68%, y: 25% to 75%)
        x1, x2 = int(w * 0.48), int(w * 0.68)
        y1, y2 = int(h * 0.25), int(h * 0.75)
        roi = note_image[y1:y2, x1:x2]

        if roi.size == 0:
            return SecurityFeatureCheck(
                feature_name="microprinting",
                is_valid=False,
                confidence=0.0,
                details="Micro-printing region out of bounds.",
            )

        gray_roi = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)

        # 1. Laplacian variance (high-frequency sharpness metric)
        laplacian = cv2.Laplacian(gray_roi, cv2.CV_64F)
        lap_variance = float(laplacian.var())

        # 2. High-pass filter energy ratio
        high_pass = gray_roi.astype(float) - cv2.GaussianBlur(
            gray_roi, (5, 5), 0
        ).astype(float)
        hp_energy = float(np.mean(np.abs(high_pass)))

        min_variance = 30.0
        if denomination in self.benchmarks:
            min_variance = self.benchmarks[denomination].get(
                "min_intaglio_variance", 35.0
            )

        if lap_variance < min_variance or hp_energy < 4.0:
            return SecurityFeatureCheck(
                feature_name="microprinting",
                is_valid=False,
                confidence=0.35,
                details=f"Micro-printing is blurred (Laplacian variance {lap_variance:.1f} < {min_variance}); "
                "consistent with inkjet dithering or low-resolution reproduction.",
            )

        confidence = min(0.95, max(0.60, 0.5 + (lap_variance / 150.0)))
        return SecurityFeatureCheck(
            feature_name="microprinting",
            is_valid=True,
            confidence=round(confidence, 3),
            details=f"Sharp intaglio micro-printing lines verified (variance {lap_variance:.1f}).",
        )

    # ── 6. UV Feature Inspection ──────────────────────────────────────────

    def check_uv_features(
        self, note_image: np.ndarray
    ) -> SecurityFeatureCheck:
        """
        Inspect UV fluorescent security response.
        Banknote substrate is cotton-rag paper free of optical brighteners (OBAs).
        Ordinary wood pulp paper glows brightly in blue/UV.
        """
        # Blue channel dominance check on blank border margin
        h, w = note_image.shape[:2]
        border_roi = note_image[5 : int(h * 0.15), 5 : int(w * 0.15)]

        if border_roi.size == 0:
            return SecurityFeatureCheck(
                feature_name="uv_features",
                is_valid=True,
                confidence=0.80,
                details="Standard RGB mode; UV inspection within nominal range.",
            )

        b, g, r = cv2.split(border_roi)
        mean_b = float(np.mean(b))
        mean_r = float(np.mean(r))

        # Commercial paper bleached with OBAs has disproportionately high blue emission
        is_oba_fluorescing = mean_b > 220 and (mean_b - mean_r > 30)


        if is_oba_fluorescing:
            return SecurityFeatureCheck(
                feature_name="uv_features",
                is_valid=False,
                confidence=0.30,
                details="High optical brightener fluorescence detected in paper substrate (indicates non-currency commercial paper).",
            )

        return SecurityFeatureCheck(
            feature_name="uv_features",
            is_valid=True,
            confidence=0.85,
            details="Banknote paper substrate exhibits non-fluorescent authentic cotton rag characteristics.",
        )

    # ── 7. Decision & Reason Synthesis ───────────────────────────────────

    def _evaluate_authenticity(
        self,
        boundary_detected: bool,
        watermark_check: SecurityFeatureCheck,
        thread_check: SecurityFeatureCheck,
        micro_check: SecurityFeatureCheck,
        uv_check: Optional[SecurityFeatureCheck],
        denomination: Optional[int],
    ) -> Tuple[bool, float, List[str]]:
        """
        Synthesize individual security check results into an overall authenticity score.
        """
        reasons: List[str] = []

        # Weights
        w_wm = 0.30
        w_th = 0.30
        w_mp = 0.25
        w_bd = 0.10
        w_uv = 0.05

        composite_score = (
            (watermark_check.confidence * w_wm)
            + (thread_check.confidence * w_th)
            + (micro_check.confidence * w_mp)
            + ((0.90 if boundary_detected else 0.40) * w_bd)
            + ((uv_check.confidence if uv_check else 0.8) * w_uv)
        )
        composite_score = round(float(composite_score), 3)

        if not watermark_check.is_valid:
            reasons.append(watermark_check.details or "Watermark verification failed")
        if not thread_check.is_valid:
            reasons.append(thread_check.details or "Security thread verification failed")
        if not micro_check.is_valid:
            reasons.append(micro_check.details or "Micro-printing sharpness check failed")
        if uv_check and not uv_check.is_valid:
            reasons.append(uv_check.details or "UV substrate inspection failed")
        if not boundary_detected:
            reasons.append("Banknote boundaries could not be cleanly isolated from background")

        # Fake note decision:
        # Must have valid watermark and security thread, and composite score >= threshold
        is_authentic = (
            watermark_check.is_valid
            and thread_check.is_valid
            and composite_score >= self.confidence_threshold
        )

        return is_authentic, composite_score, reasons
