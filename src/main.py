import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from src.api.v1.router import api_router
from src.core.config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="ShieldID API",
    description="AI-Powered Identity Verification Platform",
    version="1.0.0",
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routes
app.include_router(api_router, prefix="/api/v1")

@app.get("/")
async def root():
    return {
        "service": "ShieldID",
        "version": "1.0.0",
        "status": "operational",
        "docs": "/api/docs"
    }

@app.get("/health")
async def health():
    return {"status": "healthy"}