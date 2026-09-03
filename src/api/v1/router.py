from fastapi import APIRouter
from . import verify, kyc, report

api_router = APIRouter()

api_router.include_router(verify.router, prefix="/verify", tags=["Verification"])
api_router.include_router(kyc.router, prefix="/kyc", tags=["KYC"])
api_router.include_router(report.router, prefix="/report", tags=["Reporting"])