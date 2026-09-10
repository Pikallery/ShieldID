#!/bin/sh
set -e

echo "Running database migrations..."
alembic upgrade head || echo "Migration encountered an issue, proceeding to start application..."

echo "Starting Uvicorn server on port ${PORT:-8000}..."
exec uvicorn src.main:app --host 0.0.0.0 --port "${PORT:-8000}" --workers 1
