from fastapi import APIRouter

from src.schemas import KYCRequest, KYCResponse

router = APIRouter()


@router.post("/instant")
async def instant_kyc(request: KYCRequest):
    """Instant KYC with DigiLocker-style redirect"""
    return KYCResponse(
        status="pending",
        kyc_token="SHIELD-KYC-2026-001234",
        qr_code="https://api.qrserver.com/v1/create-qr-code/?data=SHIELD-KYC-2026-001234",
        digilocker_redirect="https://digilocker.gov.in/",
        message="Redirecting to DigiLocker for consent...",
    )