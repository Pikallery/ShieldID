from pydantic import BaseModel
from typing import Optional

class KYCRequest(BaseModel):
    purpose: str  # bank, hotel, airport, etc.
    return_url: Optional[str] = None
    consent: bool = True

class KYCResponse(BaseModel):
    status: str  # pending, verified, rejected
    kyc_token: str
    qr_code: str
    digilocker_redirect: Optional[str] = None
    message: str

class KYCToken(BaseModel):
    token: str
    expiry: int
    data: dict