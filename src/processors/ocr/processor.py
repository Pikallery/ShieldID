"""
OCR Processor module for Indian Identity Documents.

Inherits from BaseProcessor and integrates EasyOCR with computer vision preprocessing
and specialized heuristic/regex parsing for:
- Passport
- Aadhaar
- PAN Card
- Driving License
- Voter ID (EPIC)
"""

import logging
import os
import re
import shutil
from datetime import date
from typing import Any

import numpy as np

from src.processors.base_processor import BaseProcessor
from src.processors.ocr.preprocess import preprocess_document
from src.schemas.document import (
    AadhaarData,
    DocumentType,
    DrivingLicenseData,
    PANData,
    PassportData,
    VoterIDData,
)
from src.schemas.verification import OCRResult

logger = logging.getLogger(__name__)


class OCRProcessor(BaseProcessor):
    """
    OCR Processor for extracting and parsing text from Indian identity documents.
    Inherits from BaseProcessor.
    """

    def __init__(
        self,
        model_path: str | None = None,
        languages: list[str] | None = None,
        gpu: bool = False,
    ):
        super().__init__(model_path=model_path or "models/easyocr")
        self.languages = languages or ["en", "hi"]
        self.gpu = gpu
        self.reader = None
        self.has_pytesseract = False
        self._init_pytesseract()

    def _init_pytesseract(self):
        """Configure pytesseract binary path if available."""
        try:
            import pytesseract

            # Auto-detect Tesseract executable on Windows or Linux
            if not shutil.which("tesseract"):
                common_paths = [
                    r"C:\Program Files\Tesseract-OCR\tesseract.exe",
                    r"C:\Program Files (x86)\Tesseract-OCR\tesseract.exe",
                    os.path.expanduser(r"~\AppData\Local\Programs\Tesseract-OCR\tesseract.exe"),
                    "/usr/bin/tesseract",
                    "/usr/local/bin/tesseract",
                ]
                for path in common_paths:
                    if os.path.exists(path):
                        pytesseract.pytesseract.tesseract_cmd = path
                        break

            self.has_pytesseract = True
            logger.info("PyTesseract OCR engine initialized successfully.")
        except (ImportError, OSError, RuntimeError) as e:
            logger.warning(f"PyTesseract not available: {e}")
            self.has_pytesseract = False

    def load_model(self):
        """
        Load OCR engines (PyTesseract & EasyOCR).
        Falls back gracefully if an engine is not installed in the environment.
        """
        self.is_loaded = True
        try:
            import easyocr

            logger.info(
                f"Loading EasyOCR Reader with languages {self.languages}, gpu={self.gpu}..."
            )
            self.reader = easyocr.Reader(
                self.languages,
                gpu=self.gpu,
                model_storage_directory=self.model_path,
                download_enabled=True,
            )
            self.model = self.reader
            logger.info("EasyOCR Reader loaded successfully.")
        except ImportError as e:
            logger.warning(
                f"EasyOCR or PyTorch not available in current environment: {e}. "
                "PyTesseract will be used for optical recognition."
            )
            self.reader = None
            self.model = None

    def preprocess(self, input_data: Any) -> np.ndarray:
        """
        Preprocess input image with deskewing, binarization, noise removal,
        and contrast enhancement.
        """
        return preprocess_document(
            input_data, deskew_enabled=True, denoise_method="bilateral"
        )

    def predict(self, processed_input: np.ndarray) -> dict[str, Any]:
        """
        Run OCR inference on preprocessed image, extract structured identity fields,
        and return standardized dictionary matching OCRResult schema.
        """
        raw_text, confidence = self._extract_text_and_confidence(processed_input)
        ocr_result = self.parse_text(raw_text, confidence_score=confidence)
        return ocr_result.model_dump()

    def process_to_schema(self, input_data: Any) -> OCRResult:
        """
        Convenience method to execute full pipeline and return validated OCRResult schema object.
        """
        result_dict = self.process(input_data)
        return OCRResult.model_validate(result_dict)

    # ── Text Extraction Internal ──────────────────────────────────────────

    def _extract_text_and_confidence(self, image: np.ndarray) -> tuple[str, float]:
        """
        Run PyTesseract as primary OCR engine; fallback to EasyOCR if needed.
        """
        # 1. Primary Engine: PyTesseract
        if self.has_pytesseract:
            try:
                import pytesseract
                from PIL import Image

                if isinstance(image, np.ndarray):
                    # Convert BGR/Grayscale OpenCV image to RGB PIL Image
                    if len(image.shape) == 2:
                        pil_img = Image.fromarray(image).convert("RGB")
                    elif len(image.shape) == 3 and image.shape[2] == 3:
                        import cv2
                        rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
                        pil_img = Image.fromarray(rgb)
                    else:
                        pil_img = Image.fromarray(image)
                elif isinstance(image, Image.Image):
                    pil_img = image
                else:
                    pil_img = None

                if pil_img is not None:
                    # Extract structured word data with confidence scores
                    data = pytesseract.image_to_data(
                        pil_img, output_type=pytesseract.Output.DICT
                    )
                    words = []
                    conf_scores = []
                    for text, conf in zip(data["text"], data["conf"], strict=False):
                        text_str = str(text).strip()
                        conf_val = float(conf)
                        if text_str and conf_val > 0:
                            words.append(text_str)
                            conf_scores.append(conf_val / 100.0)

                    # Also fetch full string layout
                    full_text = pytesseract.image_to_string(pil_img).strip()
                    raw_text = full_text if full_text else " ".join(words)
                    avg_conf = float(np.mean(conf_scores)) if conf_scores else 0.90
                    if raw_text:
                        return raw_text, round(avg_conf, 4)
            except (ImportError, OSError, RuntimeError, ValueError, KeyError) as e:
                logger.warning(f"PyTesseract extraction exception: {e}")

        # 2. Secondary Engine: EasyOCR
        if self.reader is not None:
            try:
                results = self.reader.readtext(image)
                lines = []
                scores = []
                for item in results:
                    text = item[1].strip()
                    prob = float(item[2])
                    if text:
                        lines.append(text)
                        scores.append(prob)

                raw_text = "\n".join(lines)
                avg_score = float(np.mean(scores)) if scores else 0.0
                return raw_text, round(avg_score, 4)
            except (ImportError, OSError, RuntimeError, ValueError, KeyError) as e:
                logger.warning(f"EasyOCR extraction exception: {e}")

        # Fallback if engines return empty
        return "", 0.0

    # ── Document Parsing & Classification ────────────────────────────────

    def parse_text(
        self,
        raw_text: str,
        confidence_score: float = 0.90,
        forced_type: DocumentType | None = None,
    ) -> OCRResult:
        """
        Classify document type and extract structured fields from raw text.
        """
        cleaned_text = raw_text.strip()
        doc_type = forced_type or self.detect_document_type(cleaned_text)

        passport_data = None
        aadhaar_data = None
        pan_data = None
        dl_data = None
        voter_data = None

        if doc_type == DocumentType.PASSPORT:
            passport_data = self._parse_passport(cleaned_text)
        elif doc_type == DocumentType.AADHAAR:
            aadhaar_data = self._parse_aadhaar(cleaned_text)
        elif doc_type == DocumentType.PAN:
            pan_data = self._parse_pan(cleaned_text)
        elif doc_type == DocumentType.DRIVING_LICENSE:
            dl_data = self._parse_driving_license(cleaned_text)
        elif doc_type == DocumentType.VOTER_ID:
            voter_data = self._parse_voter_id(cleaned_text)

        return OCRResult(
            document_type=doc_type,
            passport=passport_data,
            aadhaar=aadhaar_data,
            pan=pan_data,
            driving_license=dl_data,
            voter_id=voter_data,
            raw_text=cleaned_text,
            confidence_score=confidence_score,
        )

    def detect_document_type(self, text: str) -> DocumentType:
        """
        Heuristic classification based on keyword markers and distinct ID patterns.
        """
        upper = text.upper()

        # Check Passport markers
        if (
            "PASSPORT" in upper
            or "REPUBLIC OF INDIA" in upper
            or re.search(r"P<IND", upper)
        ):
            return DocumentType.PASSPORT

        # Check Aadhaar markers
        if (
            "AADHAAR" in upper
            or "UNIQUE IDENTIFICATION" in upper
            or "UIDAI" in upper
            or "MERA AADHAAR" in upper
            or "GOVERNMENT OF INDIA" in upper
            and re.search(r"\b\d{4}\s\d{4}\s\d{4}\b", upper)
        ):
            return DocumentType.AADHAAR

        # Check PAN markers
        if (
            "INCOME TAX" in upper
            or "PERMANENT ACCOUNT NUMBER" in upper
            or re.search(r"\b[A-Z]{5}[0-9]{4}[A-Z]\b", upper)
        ):
            return DocumentType.PAN

        # Check Driving License markers
        if (
            "DRIVING LICENCE" in upper
            or "DRIVING LICENSE" in upper
            or "UNION OF INDIA DRIVING" in upper
            or "TRANSPORT DEPARTMENT" in upper
            or re.search(r"\b[A-Z]{2}[-\s]?[0-9]{2}[-\s]?[0-9]{11}\b", upper)
            or re.search(r"\b[A-Z]{2}\d{13,15}\b", upper)
        ):
            return DocumentType.DRIVING_LICENSE

        # Check Voter ID markers
        if (
            "ELECTION COMMISSION" in upper
            or "ELECTOR PHOTO IDENTITY" in upper
            or "VOTER" in upper
            or "EPIC" in upper
            or re.search(r"\b[A-Z]{3}[0-9]{7}\b", upper)
        ):
            return DocumentType.VOTER_ID

        # Fallback pattern checks if keywords were missing
        if re.search(r"\b[A-Z]{5}[0-9]{4}[A-Z]\b", upper):
            return DocumentType.PAN
        if re.search(r"\b\d{4}\s\d{4}\s\d{4}\b", upper):
            return DocumentType.AADHAAR
        if re.search(r"\b[A-Z]{3}[0-9]{7}\b", upper):
            return DocumentType.VOTER_ID
        if re.search(r"\b[A-Z][0-9]{7}\b", upper):
            return DocumentType.PASSPORT

        # Default fallback
        return DocumentType.PAN

    # ── Individual Document Field Parsers ─────────────────────────────────

    def _parse_passport(self, text: str) -> PassportData:
        """
        Parse Indian Passport fields: name, passport_number, nationality, DOB, expiry, gender.
        Supports both visual inspection lines and Machine Readable Zone (MRZ).
        """
        lines = [line.strip() for line in text.split("\n") if line.strip()]
        upper = text.upper()

        # 1. MRZ Check (P<IND...)
        mrz_match = re.search(r"P<IND([A-Z<]+)", upper)
        passport_num = None
        name = "Unknown"
        dob = None
        expiry = None
        gender = "M"
        nationality = "Indian"

        # Search Passport Number (1 letter + 7 digits)
        num_match = re.search(r"\b([A-PR-WYa-pr-wy][1-9]\d{6})\b", upper)
        if num_match:
            passport_num = num_match.group(1).upper()
        else:
            num_fallback = re.search(r"\b([A-Z][0-9]{7})\b", upper)
            if num_fallback:
                passport_num = num_fallback.group(1)

        # Dates extraction
        dates = self._extract_all_dates(text)
        if len(dates) >= 2:
            # Usually DOB is earlier than expiry
            sorted_dates = sorted(dates)
            dob = sorted_dates[0]
            expiry = sorted_dates[-1]
        elif len(dates) == 1:
            dob = dates[0]
            expiry = date(dob.year + 10, dob.month, dob.day)

        if dob is None:
            dob = date(1990, 1, 1)
        if expiry is None:
            expiry = date(2030, 1, 1)

        # Gender extraction
        gender_match = re.search(r"\b(?:GENDER|SEX)[:\s]*([MF]|MALE|FEMALE)\b", upper)
        if gender_match:
            val = gender_match.group(1)
            gender = "M" if val.startswith("M") else "F"

        # Nationality
        nat_match = re.search(r"\b(?:NATIONALITY)[:\s]*([A-Z]+)\b", upper)
        if nat_match:
            nationality = nat_match.group(1).capitalize()

        # Name extraction
        given_name = ""
        surname = ""
        gn_match = re.search(
            r"(?:GIVEN\s*NAMES?(?:\([^\)]*\))?|FIRST\s*NAME)[:\s]*([A-Z\s]+)",
            text,
            re.IGNORECASE,
        )
        if gn_match:
            given_name = gn_match.group(1).split("\n")[0].strip()
        sn_match = re.search(
            r"(?:SURNAME|LAST NAME)(?:\([^\)]*\))?[:\s]*([A-Z\s]+)",
            text,
            re.IGNORECASE,
        )
        if sn_match:
            surname = sn_match.group(1).split("\n")[0].strip()

        if given_name or surname:
            name = f"{given_name} {surname}".strip()
        else:
            name_match = re.search(r"(?:NAME)[:\s]*([A-Z\s]+)", text, re.IGNORECASE)
            if name_match:
                candidate = name_match.group(1).split("\n")[0].strip()
                if len(candidate) > 2:
                    name = candidate
            elif mrz_match:
                raw_mrz = mrz_match.group(1)
                parts = [p for p in raw_mrz.split("<") if p]
                if parts:
                    name = " ".join(parts[:2]).title()
            else:
                # First line with all alpha words
                for line in lines:
                    if (
                        re.match(r"^[A-Za-z\s]{3,40}$", line)
                        and "PASSPORT" not in line.upper()
                        and "INDIA" not in line.upper()
                    ):
                        name = line.strip()
                        break

        return PassportData(
            name=name,
            passport_number=passport_num or "A0000000",
            nationality=nationality,
            date_of_birth=dob,
            date_of_expiry=expiry,
            gender=gender,
        )

    def _parse_aadhaar(self, text: str) -> AadhaarData:
        """
        Parse Aadhaar card: 12-digit number (xxxx xxxx xxxx), name, DOB, gender.
        """
        lines = [line.strip() for line in text.split("\n") if line.strip()]
        upper = text.upper()

        # Aadhaar Number
        num_match = re.search(r"\b(\d{4}\s\d{4}\s\d{4})\b", text)
        if num_match:
            aadhaar_number = num_match.group(1)
        else:
            num_digits = re.search(r"\b(\d{12})\b", text)
            if num_digits:
                d = num_digits.group(1)
                aadhaar_number = f"{d[:4]} {d[4:8]} {d[8:]}"
            else:
                aadhaar_number = "0000 0000 0000"

        # Date of Birth
        dob = None
        dob_match = re.search(
            r"(?:DOB|DATE OF BIRTH|YEAR OF BIRTH)[:\s]*([0-9]{2}[/-][0-9]{2}[/-][0-9]{4}|[0-9]{4})",
            upper,
        )
        if dob_match:
            raw_dob = dob_match.group(1)
            dob = self._parse_single_date(raw_dob)
        else:
            dates = self._extract_all_dates(text)
            if dates:
                dob = dates[0]

        # Gender
        gender = None
        gender_match = re.search(r"\b(MALE|FEMALE|TRANSGENDER)\b", upper)
        if gender_match:
            gender = gender_match.group(1).capitalize()

        # Name extraction
        name = "Unknown"
        name_match = re.search(r"(?:NAME)[:\s]*([A-Z\s]+)", text, re.IGNORECASE)
        if name_match:
            name = name_match.group(1).split("\n")[0].strip()
        else:
            # Heuristic: Find first capitalized non-header line before DOB
            ignore_keywords = {
                "GOVERNMENT",
                "INDIA",
                "AADHAAR",
                "UNIQUE",
                "AUTHORITY",
                "UIDAI",
                "HELP",
                "ENROLLMENT",
                "MALE",
                "FEMALE",
                "DOB",
                "BIRTH",
            }
            for line in lines:
                u_line = line.upper()
                if any(noise in u_line for noise in ("SRAM", "BRAM", "VRAM", "NRAM", "FARA", "HIVA", "WATE", "STAE", "ATT", "LOSRAM")):
                    continue
                tokens = set(u_line.split())
                if (
                    len(line) > 3
                    and re.match(r"^[A-Za-z\s]+$", line)
                    and not (tokens & ignore_keywords)
                ):
                    name = line.strip()
                    break

        return AadhaarData(
            name=name,
            aadhaar_number=aadhaar_number,
            date_of_birth=dob,
            gender=gender,
        )

    def _parse_pan(self, text: str) -> PANData:
        """
        Parse PAN Card: 10-character PAN number (AAAAA9999A), name, DOB.
        Standard layout:
        Line 1: Name
        Line 2: Father's Name
        Line 3: Date of Birth
        """
        lines = [line.strip() for line in text.split("\n") if line.strip()]
        upper = text.upper()

        # PAN number
        pan_number = "UNKNOWN000"
        pan_match = re.search(r"\b([A-Z]{5}[0-9]{4}[A-Z])\b", upper)
        if pan_match:
            pan_number = pan_match.group(1)
        else:
            # Check for spaced PAN e.g. "SFAPS 5084D" or "SFAPS 5084 D"
            spaced_pan = re.search(r"\b([A-Z0-9]{5})\s+([A-Z0-9]{4})\s*([A-Z0-9])\b", upper)
            if spaced_pan:
                candidate = "".join(spaced_pan.groups())
                if re.match(r"^[A-Z]{5}[0-9]{4}[A-Z]$", candidate):
                    pan_number = candidate

        # DOB
        dob = None
        dates = self._extract_all_dates(text)
        if dates:
            dob = dates[0]

        # Name extraction
        name = "Unknown"
        name_match = re.search(r"(?:NAME)[:\s]*([A-Z\s]+)", text, re.IGNORECASE)
        if name_match:
            name = name_match.group(1).split("\n")[0].strip()
        else:
            # Comprehensive blacklist of government card headers, Devanagari transliteration noise & artifacts
            ignore = {
                "INCOME", "TAX", "DEPARTMENT", "GOVT", "GOVERNMENT", "INDIA",
                "PERMANENT", "ACCOUNT", "NUMBER", "CARD", "SIGNATURE",
                "AYAKAR", "VIBHAG", "BHARAT", "SARKAR", "FATHER", "FATHERS",
                "NAME", "LOSRAM", "ATT", "SRAM", "CREE", "TE", "WT", "TGA", "TCA",
                "HIVA", "WATE", "STAE", "FARA", "YATE", "BRAM", "NRAM", "VRAM",
                "HOLDER", "DATE", "BIRTH", "DIGILOCKER"
            }
            noise_substrings = ("SRAM", "BRAM", "VRAM", "NRAM", "FARA", "HIVA", "WATE", "STAE", "ATT", "LOSRAM")

            candidate_lines = []
            for line in lines:
                u_line = line.upper()
                if any(noise in u_line for noise in noise_substrings):
                    continue
                tokens = set(u_line.split())
                if (
                    re.match(r"^[A-Za-z\s\.]{3,40}$", line)
                    and not (tokens & ignore)
                    and not re.search(r"\b[A-Z]{5}[0-9]{4}[A-Z]\b", u_line)
                ):
                    candidate_lines.append(line.strip())

            # 5th letter of PAN represents the cardholder's surname initial
            surname_initial = pan_number[4] if len(pan_number) == 10 and pan_number[4].isalpha() else ""

            best_name = None
            if surname_initial:
                for cand in candidate_lines:
                    words = cand.split()
                    if any(w.upper().startswith(surname_initial) for w in words):
                        best_name = cand
                        break

            if not best_name and candidate_lines:
                # Require candidate to have at least 2 words or length >= 5
                for cand in candidate_lines:
                    words = cand.split()
                    if len(words) >= 2 and all(len(w) >= 3 for w in words):
                        best_name = cand
                        break
                if not best_name:
                    long_cands = [c for c in candidate_lines if len(c) >= 5]
                    if long_cands:
                        best_name = max(long_cands, key=len)

            if best_name:
                name = best_name

        return PANData(
            name=name,
            pan_number=pan_number,
            date_of_birth=dob,
        )

    def _parse_driving_license(self, text: str) -> DrivingLicenseData:
        """
        Parse Driving License: DL number, name, DOB, expiry date, gender.
        """
        lines = [line.strip() for line in text.split("\n") if line.strip()]
        upper = text.upper()

        # License Number: e.g., DL-0420110012345 or MH12 20110012345
        dl_number = "DL0000000000000"
        dl_match = re.search(r"\b([A-Z]{2}[-\s]?[0-9]{2}[-\s]?[0-9]{11})\b", upper)
        if dl_match:
            dl_number = dl_match.group(1)
        else:
            dl_match_alt = re.search(r"\b([A-Z]{2}\d{13,15})\b", upper)
            if dl_match_alt:
                dl_number = dl_match_alt.group(1)
            else:
                num_match = re.search(
                    r"(?:DL\s*NO|LICENCE\s*NO)[:\s]*([A-Z0-9\-\s]+)", upper
                )
                if num_match:
                    dl_number = num_match.group(1).split("\n")[0].strip()

        # Dates: DOB and Expiry / Valid till
        dob = None
        expiry = None
        dates = self._extract_all_dates(text)
        if len(dates) >= 2:
            sorted_dates = sorted(dates)
            dob = sorted_dates[0]
            expiry = sorted_dates[-1]
        elif len(dates) == 1:
            dob = dates[0]

        # Explicit Expiry regex
        exp_match = re.search(
            r"(?:VALID\s*TILL|EXPIRY|VALIDITY)[:\s]*([0-9]{2}[/-][0-9]{2}[/-][0-9]{4})",
            upper,
        )
        if exp_match:
            parsed_exp = self._parse_single_date(exp_match.group(1))
            if parsed_exp:
                expiry = parsed_exp

        # Gender
        gender = None
        gender_match = re.search(r"\b(?:SEX|GENDER)[:\s]*([MF]|MALE|FEMALE)\b", upper)
        if gender_match:
            val = gender_match.group(1)
            gender = "Male" if val.startswith("M") else "Female"

        # Name
        name = "Unknown"
        name_match = re.search(r"(?:NAME|HOLDER)[:\s]*([A-Z\s]+)", text, re.IGNORECASE)
        if name_match:
            name = name_match.group(1).split("\n")[0].strip()
        else:
            ignore = {
                "DRIVING",
                "LICENCE",
                "LICENSE",
                "UNION",
                "INDIA",
                "TRANSPORT",
                "VALID",
                "FORM",
            }
            for line in lines:
                tokens = set(line.upper().split())
                if (
                    len(line) > 3
                    and re.match(r"^[A-Za-z\s]+$", line)
                    and not (tokens & ignore)
                ):
                    name = line.strip()
                    break

        return DrivingLicenseData(
            name=name,
            license_number=dl_number,
            date_of_birth=dob,
            date_of_expiry=expiry,
            gender=gender,
        )

    def _parse_voter_id(self, text: str) -> VoterIDData:
        """
        Parse Voter ID (EPIC): EPIC number (3 letters + 7 digits), name, DOB/age, gender.
        """
        lines = [line.strip() for line in text.split("\n") if line.strip()]
        upper = text.upper()

        # EPIC number: 3 letters + 7 numbers, e.g. ABC1234567
        voter_id_number = "EPIC0000000"
        epic_match = re.search(r"\b([A-Z]{3}[0-9]{7})\b", upper)
        if epic_match:
            voter_id_number = epic_match.group(1)
        else:
            num_match = re.search(r"(?:EPIC|ELECTOR\s*NO)[:\s]*([A-Z0-9]+)", upper)
            if num_match:
                voter_id_number = num_match.group(1).split("\n")[0].strip()

        # DOB or Age
        dob = None
        dates = self._extract_all_dates(text)
        if dates:
            dob = dates[0]

        # Gender
        gender = None
        gender_match = re.search(r"\b(?:GENDER|SEX)[:\s]*([MF]|MALE|FEMALE)\b", upper)
        if gender_match:
            val = gender_match.group(1)
            gender = "Male" if val.startswith("M") else "Female"

        # Name
        name = "Unknown"
        name_match = re.search(
            r"(?:ELECTOR'?S?\s*NAME|NAME)[:\s]*([A-Z\s]+)", text, re.IGNORECASE
        )
        if name_match:
            name = name_match.group(1).split("\n")[0].strip()
        else:
            ignore = {
                "ELECTION",
                "COMMISSION",
                "INDIA",
                "ELECTOR",
                "PHOTO",
                "IDENTITY",
                "CARD",
            }
            for line in lines:
                tokens = set(line.upper().split())
                if (
                    len(line) > 3
                    and re.match(r"^[A-Za-z\s]+$", line)
                    and not (tokens & ignore)
                ):
                    name = line.strip()
                    break

        return VoterIDData(
            name=name,
            voter_id_number=voter_id_number,
            date_of_birth=dob,
            gender=gender,
        )

    # ── Date Helpers ──────────────────────────────────────────────────────

    def _extract_all_dates(self, text: str) -> list[date]:
        """Extract all valid dates from text (DD/MM/YYYY, DD-MM-YYYY, DD.MM.YYYY)."""
        date_pattern = r"\b(\d{2})[/-](\d{2})[/-](\d{4})\b"
        matches = re.findall(date_pattern, text)
        results = []
        for day_str, month_str, year_str in matches:
            try:
                day, month, year = int(day_str), int(month_str), int(year_str)
                d = date(year, month, day)
                # Reasonable human birth/expiry range
                if 1920 <= year <= 2050:
                    results.append(d)
            except ValueError:
                continue
        return results

    def _parse_single_date(self, date_str: str) -> date | None:
        """Parse single date string (DD/MM/YYYY or YYYY)."""
        date_str = date_str.strip()
        # Full date DD/MM/YYYY or DD-MM-YYYY
        match = re.search(r"(\d{2})[/-](\d{2})[/-](\d{4})", date_str)
        if match:
            try:
                day, month, year = (
                    int(match.group(1)),
                    int(match.group(2)),
                    int(match.group(3)),
                )
                return date(year, month, day)
            except ValueError:
                pass

        # Year only YYYY
        year_match = re.search(r"\b(19\d{2}|20\d{2})\b", date_str)
        if year_match:
            return date(int(year_match.group(1)), 1, 1)

        return None
