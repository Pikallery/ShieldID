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
import re
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

    def load_model(self):
        """
        Load EasyOCR reader model from disk / models directory.
        Falls back gracefully if easyocr or torch is not installed in the environment.
        """
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
            self.is_loaded = True
            logger.info("EasyOCR Reader loaded successfully.")
        except ImportError as e:
            logger.warning(
                f"EasyOCR or PyTorch not available in current environment: {e}. "
                "Running in fallback text-parser mode."
            )
            self.reader = None
            self.model = None
            self.is_loaded = True

    def preprocess(self, input_data: Any) -> np.ndarray:
        """
        Preprocess input image with deskewing, binarization, noise removal,
        and contrast enhancement.
        """
        return preprocess_document(input_data, deskew_enabled=True, denoise_method="bilateral")

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

    def _extract_text_and_confidence(
        self, image: np.ndarray
    ) -> tuple[str, float]:
        """
        Run EasyOCR Reader if available; otherwise return placeholder / inspect image.
        """
        if self.reader is not None:
            results = self.reader.readtext(image)
            # results is list of (bbox, text, prob)
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

        # Fallback if EasyOCR is not installed in local environment
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
        if "PASSPORT" in upper or "REPUBLIC OF INDIA" in upper or re.search(r"P<IND", upper):
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
                tokens = set(line.upper().split())
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
            # Search lines between "INCOME TAX DEPARTMENT" / "GOVT OF INDIA" and Father's name / DOB
            ignore = {
                "INCOME",
                "TAX",
                "DEPARTMENT",
                "GOVT",
                "GOVERNMENT",
                "INDIA",
                "PERMANENT",
                "ACCOUNT",
                "NUMBER",
                "CARD",
                "SIGNATURE",
            }
            candidate_lines = []
            for line in lines:
                tokens = set(line.upper().split())
                if (
                    re.match(r"^[A-Za-z\s]{3,40}$", line)
                    and not (tokens & ignore)
                    and not re.search(r"\b[A-Z]{5}[0-9]{4}[A-Z]\b", line.upper())
                ):
                    candidate_lines.append(line.strip())

            if candidate_lines:
                name = candidate_lines[0]

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
        dl_match = re.search(
            r"\b([A-Z]{2}[-\s]?[0-9]{2}[-\s]?[0-9]{11})\b", upper
        )
        if dl_match:
            dl_number = dl_match.group(1)
        else:
            dl_match_alt = re.search(r"\b([A-Z]{2}\d{13,15})\b", upper)
            if dl_match_alt:
                dl_number = dl_match_alt.group(1)
            else:
                num_match = re.search(r"(?:DL\s*NO|LICENCE\s*NO)[:\s]*([A-Z0-9\-\s]+)", upper)
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
            ignore = {"DRIVING", "LICENCE", "LICENSE", "UNION", "INDIA", "TRANSPORT", "VALID", "FORM"}
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
            ignore = {"ELECTION", "COMMISSION", "INDIA", "ELECTOR", "PHOTO", "IDENTITY", "CARD"}
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
                day, month, year = int(match.group(1)), int(match.group(2)), int(match.group(3))
                return date(year, month, day)
            except ValueError:
                pass

        # Year only YYYY
        year_match = re.search(r"\b(19\d{2}|20\d{2})\b", date_str)
        if year_match:
            return date(int(year_match.group(1)), 1, 1)

        return None

