from datetime import date
from enum import Enum

from pydantic import BaseModel


class DocumentType(str, Enum):
    PASSPORT = "passport"
    VISA = "visa"
    AADHAAR = "aadhaar"
    PAN = "pan"
    DRIVING_LICENSE = "driving_license"
    VOTER_ID = "voter_id"

class PassportData(BaseModel):
    name: str
    passport_number: str
    nationality: str
    date_of_birth: date
    date_of_expiry: date
    gender: str

class AadhaarData(BaseModel):
    name: str
    aadhaar_number: str
    date_of_birth: date | None = None
    gender: str | None = None

class PANData(BaseModel):
    name: str
    pan_number: str
    date_of_birth: date | None = None