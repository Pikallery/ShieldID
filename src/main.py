from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging

from src.core.config import settings
from src.core.database import create_db_tables, dispose_engine
from src.api.v1.router import api_router

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


# ── Application Lifespan ──────────────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Manage startup and shutdown of shared async resources.

    Startup:
        - Creates database tables if they don't exist (dev convenience).
          In production, tables are managed via Alembic migrations.

    Shutdown:
        - Disposes the SQLAlchemy async engine connection pool cleanly.
    """
    logger.info("Starting ShieldID — initialising database connection pool...")
    await create_db_tables()
    logger.info("Database ready.")
    yield
    logger.info("Shutting down ShieldID — closing database connections...")
    await dispose_engine()
    logger.info("Database connections closed.")


# ── FastAPI Application ───────────────────────────────────────────────────────
app = FastAPI(
    title="ShieldID API",
    description="AI-Powered Identity Verification Platform",
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    lifespan=lifespan,
)

# ── CORS ──────────────────────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Routes ────────────────────────────────────────────────────────────────────
app.include_router(api_router, prefix="/api/v1")


@app.get("/")
async def root():
    return {
        "service": "ShieldID",
        "version": "1.0.0",
        "status": "operational",
        "docs": "/api/docs",
    }


@app.get("/health")
async def health():
    return {"status": "healthy"}