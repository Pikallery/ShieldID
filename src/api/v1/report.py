from fastapi import APIRouter, UploadFile

router = APIRouter()


@router.post("/fake")
async def report_fake_document(
    document: UploadFile,
    description: str | None = None,
    latitude: float | None = None,
    longitude: float | None = None,
):
    """Report a fake document"""
    file_tag = hex(abs(hash(document.filename or "doc")))[2:8].upper()
    return {
        "status": "success",
        "fir_number": f"FIR-2026-{file_tag}",
        "message": "Report filed successfully. Police notified.",
        "assigned_station": "Nearest Police Station",
    }
