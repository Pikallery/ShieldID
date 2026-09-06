# migrations/versions/ — Alembic migration version scripts

This directory contains auto-generated Alembic migration scripts.

## Usage

```bash
# Create a new migration (after editing models)
alembic revision --autogenerate -m "describe_your_change"

# Apply all pending migrations
alembic upgrade head

# Roll back one migration
alembic downgrade -1

# Show current revision applied to the database
alembic current

# Show migration history
alembic history --verbose
```

Migration files are named: `YYYYMMDD_HHMM_<revision>_<slug>.py`
