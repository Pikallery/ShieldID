
from pydantic import BaseModel


class KYCRequest(BaseModel):
    purpose: str  # bank, hotel, airport, etc.
    return_url: str | None = None
    consent: bool = True

class KYCResponse(BaseModel):
    status: str  # pending, verified, rejected
    kyc_token: str
    qr_code: str
    digilocker_redirect: str | None = None
    message: str

class KYCToken(BaseModel):
    token: str
    expiry: int
    data: dict