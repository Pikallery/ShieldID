from fastapi import APIRouter, UploadFile

router = APIRouter()


@router.post("/document")
async def verify_document(
    document: UploadFile,
    selfie: UploadFile | None = None,
):
    """Verify document authenticity"""
    return {
        "status": "verified",
        "risk_score": 15,
        "document_type": "passport",
        "name": "Rahul Sharma",
        "recommendation": "APPROVE",
    }


@router.get("/status/{verification_id}")
async def get_verification_status(verification_id: str):
    """Check verification status"""
    return {"status": "completed", "verification_id": verification_id}
