FROM python:3.10-slim

# System dependencies for PostgreSQL client, Tesseract OCR, and image processing.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    libgl1 \
    libglib2.0-0 \
    tesseract-ocr \
    tesseract-ocr-eng \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for Docker layer caching.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy alembic config so migrations can run inside the container.
COPY alembic.ini .

# Copy runtime source and model configuration.
COPY src/ ./src/
COPY migrations/ ./migrations/
COPY models/ ./models/

# Copy entrypoint script and set executable permissions.
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["/app/start.sh"]
