from fastapi import APIRouter

from . import auth, kyc, report, verify

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(verify.router, prefix="/verify", tags=["Verification"])
api_router.include_router(kyc.router, prefix="/kyc", tags=["KYC"])
api_router.include_router(report.router, prefix="/report", tags=["Reporting"])
