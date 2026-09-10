FROM python:3.10-slim

# System dependencies for PostgreSQL client and image processing.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for Docker layer caching.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy runtime source and model configuration.
COPY src/ ./src/
COPY alembic.ini .
COPY migrations/ ./migrations/
COPY models/ ./models/

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# Railway supplies PORT at runtime; the fallback keeps local Docker working.
CMD ["sh", "-c", "uvicorn src.main:app --host 0.0.0.0 --port ${PORT:-8000} --workers 1"]
