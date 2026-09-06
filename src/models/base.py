"""
SQLAlchemy declarative base and shared mixins for all ORM models.

All models must inherit from Base (DeclarativeBase) so that Alembic
can auto-detect table changes. TimestampMixin adds created_at /
updated_at columns to any model that needs them.
"""

import uuid
from datetime import datetime, timezone

from sqlalchemy import DateTime, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    """
    Shared declarative base for all ShieldID ORM models.

    All models inherit from this class so that Alembic's
    target_metadata can discover them in one place.
    """


class UUIDMixin:
    """
    Adds a UUID primary key column named `id`.
    Uses PostgreSQL's gen_random_uuid() as the server default
    so that rows get a valid UUID even when inserted via raw SQL.
    """
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        server_default=func.gen_random_uuid(),
    )


class TimestampMixin:
    """
    Adds `created_at` and `updated_at` columns.

    - `created_at` is set once at insert time by the DB server.
    - `updated_at` is updated on every row change via onupdate.
    """
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        server_default=func.now(),
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        server_default=func.now(),
        onupdate=lambda: datetime.now(timezone.utc),
    )
