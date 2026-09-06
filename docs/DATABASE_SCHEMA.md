# Legacy schema reference
# ShieldID — Database Schema Reference

> **Project**: AI-Based Fake Identity & Document Screening System  
> **Database**: PostgreSQL 16  
> **ORM**: SQLAlchemy 2.0 (async, `mapped_column` style)  
> **Migrations**: Alembic (async env)

---

## Entity Relationship Diagram

```
users
  ├── documents          (1:N)  — user submits many documents
  ├── kyc_sessions       (1:N)  — user initiates many KYC sessions
  ├── fraud_reports      (1:N)  — user files many reports
  ├── audit_logs         (1:N)  — user generates many audit events
  └── screening_results  (1:N)  — user reviews many screenings (as reviewer)

documents  ← central hub
  ├── ocr_results          (1:1)  — CASCADE delete
  ├── tampering_analyses   (1:1)  — CASCADE delete
  ├── face_verifications   (1:1)  — CASCADE delete (nullable if no selfie)
  ├── screening_results    (1:1)  — CASCADE delete
  ├── kyc_sessions         (1:1)  — SET NULL on delete
  └── fraud_reports        (1:N)  — SET NULL on delete

screening_results
  └── fraud_reports  (1:N) — auto-triggered reports
```

---

## Table: `users`

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | UUID | NO | gen_random_uuid() | PK |
| `email` | VARCHAR(255) | NO | — | UNIQUE, indexed |
| `hashed_password` | VARCHAR(255) | NO | — | bcrypt hash |
| `full_name` | VARCHAR(255) | NO | — | |
| `role` | VARCHAR(50) | NO | `user` | admin / operator / user |
| `is_active` | BOOLEAN | NO | `true` | Soft enable/disable |
| `is_verified` | BOOLEAN | NO | `false` | Email verified flag |
| `last_login_at` | TIMESTAMPTZ | YES | NULL | |
| `created_at` | TIMESTAMPTZ | NO | now() | |
| `updated_at` | TIMESTAMPTZ | NO | now() | Auto-updated |

---

## Table: `documents`

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | UUID | NO | gen_random_uuid() | PK |
| `user_id` | UUID | YES | NULL | FK → users(id) SET NULL |
| `document_type` | VARCHAR(50) | NO | — | passport/aadhaar/pan/etc. |
| `original_filename` | VARCHAR(255) | NO | — | |
| `file_path` | TEXT | NO | — | Storage key or local path |
| `file_hash` | VARCHAR(64) | NO | — | SHA-256, indexed |
| `mime_type` | VARCHAR(100) | NO | — | |
| `file_size_bytes` | BIGINT | NO | — | |
| `selfie_path` | TEXT | YES | NULL | Set if selfie uploaded |
| `submission_ip` | INET | YES | NULL | |
| `submission_purpose` | VARCHAR(100) | YES | NULL | bank/hotel/airport/etc. |
| `status` | VARCHAR(50) | NO | `pending` | pending/processing/completed/failed |
| `created_at` | TIMESTAMPTZ | NO | now() | |
| `updated_at` | TIMESTAMPTZ | NO | now() | |

---

## Table: `ocr_results`

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | UUID | NO | gen_random_uuid() | PK |
| `document_id` | UUID | NO | — | FK → documents(id) CASCADE, UNIQUE |
| `raw_text` | TEXT | NO | — | Full OCR output |
| `confidence_score` | FLOAT | NO | — | 0.0–1.0 |
| `extracted_name` | VARCHAR(255) | YES | NULL | |
| `extracted_dob` | DATE | YES | NULL | |
| `extracted_doc_number` | VARCHAR(100) | YES | NULL | Indexed |
| `extracted_expiry_date` | DATE | YES | NULL | |
| `extracted_nationality` | VARCHAR(100) | YES | NULL | |
| `extracted_gender` | VARCHAR(20) | YES | NULL | |
| `extracted_data_json` | JSONB | YES | NULL | Full structured output |
| `ocr_engine` | VARCHAR(50) | NO | `easyocr` | |
| `processing_time_ms` | INTEGER | YES | NULL | |
| `created_at` | TIMESTAMPTZ | NO | now() | |

---

## Table: `tampering_analyses`

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | UUID | NO | gen_random_uuid() | PK |
| `document_id` | UUID | NO | — | FK → documents(id) CASCADE, UNIQUE |
| `is_tampered` | BOOLEAN | NO | — | Indexed |
| `tamper_score` | FLOAT | NO | — | 0.0–1.0 |
| `detection_method` | VARCHAR(100) | NO | — | ela_analysis/neural_cnn/hybrid |
| `tampering_regions` | JSONB | NO | `[]` | Array of region labels |
| `ela_score` | FLOAT | YES | NULL | |
| `copy_move_detected` | BOOLEAN | YES | NULL | |
| `photo_swap_detected` | BOOLEAN | YES | NULL | |
| `text_alteration_detected` | BOOLEAN | YES | NULL | |
| `stamp_forgery_detected` | BOOLEAN | YES | NULL | |
| `raw_analysis_json` | JSONB | YES | NULL | Full model output |
| `processing_time_ms` | INTEGER | YES | NULL | |
| `created_at` | TIMESTAMPTZ | NO | now() | |

---

## Table: `face_verifications`

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | UUID | NO | gen_random_uuid() | PK |
| `document_id` | UUID | NO | — | FK → documents(id) CASCADE, UNIQUE |
| `face_detected` | BOOLEAN | NO | — | Face in doc photo |
| `face_confidence` | FLOAT | NO | — | |
| `selfie_face_detected` | BOOLEAN | YES | NULL | Face in selfie |
| `similarity_score` | FLOAT | NO | — | 0.0–1.0 |
| `is_same_person` | BOOLEAN | NO | — | Indexed |
| `liveness_score` | FLOAT | YES | NULL | Anti-spoofing |
| `liveness_passed` | BOOLEAN | YES | NULL | |
| `model_used` | VARCHAR(100) | NO | `deepface` | |
| `processing_time_ms` | INTEGER | YES | NULL | |
| `created_at` | TIMESTAMPTZ | NO | now() | |

---

## Table: `screening_results`

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | UUID | NO | gen_random_uuid() | PK |
| `document_id` | UUID | NO | — | FK → documents(id) CASCADE, UNIQUE |
| `overall_risk` | FLOAT | NO | — | Indexed |
| `ocr_risk` | FLOAT | NO | — | |
| `tamper_risk` | FLOAT | NO | — | |
| `face_risk` | FLOAT | NO | — | |
| `recommendation` | VARCHAR(50) | NO | — | APPROVE/REVIEW_MANUALLY/REJECT |
| `final_status` | VARCHAR(50) | NO | `pending` | Indexed |
| `reviewed_by_user_id` | UUID | YES | NULL | FK → users(id) SET NULL |
| `reviewed_at` | TIMESTAMPTZ | YES | NULL | |
| `reviewer_notes` | TEXT | YES | NULL | |
| `created_at` | TIMESTAMPTZ | NO | now() | |
| `updated_at` | TIMESTAMPTZ | NO | now() | |

---

## Table: `kyc_sessions`

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | UUID | NO | gen_random_uuid() | PK |
| `user_id` | UUID | YES | NULL | FK → users(id) SET NULL |
| `document_id` | UUID | YES | NULL | FK → documents(id) SET NULL, UNIQUE |
| `kyc_token` | VARCHAR(255) | NO | — | UNIQUE, indexed |
| `qr_code_url` | TEXT | NO | — | |
| `purpose` | VARCHAR(100) | NO | — | bank/hotel/airport/etc. |
| `return_url` | TEXT | YES | NULL | |
| `digilocker_redirect` | TEXT | YES | NULL | |
| `consent_given` | BOOLEAN | NO | `false` | |
| `consent_timestamp` | TIMESTAMPTZ | YES | NULL | |
| `status` | VARCHAR(50) | NO | `pending` | pending/verified/rejected/expired |
| `expires_at` | TIMESTAMPTZ | NO | — | Token TTL |
| `created_at` | TIMESTAMPTZ | NO | now() | |
| `updated_at` | TIMESTAMPTZ | NO | now() | |

---

## Table: `fraud_reports`

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | UUID | NO | gen_random_uuid() | PK |
| `document_id` | UUID | YES | NULL | FK → documents(id) SET NULL |
| `reported_by_user_id` | UUID | YES | NULL | FK → users(id) SET NULL |
| `screening_result_id` | UUID | YES | NULL | FK → screening_results(id) SET NULL |
| `fir_number` | VARCHAR(100) | NO | — | UNIQUE, indexed |
| `description` | TEXT | YES | NULL | |
| `latitude` | NUMERIC(9,6) | YES | NULL | Geo-tag |
| `longitude` | NUMERIC(9,6) | YES | NULL | |
| `assigned_station` | VARCHAR(255) | YES | NULL | |
| `report_status` | VARCHAR(50) | NO | `filed` | filed/under_investigation/closed |
| `evidence_paths` | JSONB | YES | NULL | Array of file paths |
| `reporter_ip` | INET | YES | NULL | |
| `created_at` | TIMESTAMPTZ | NO | now() | |
| `updated_at` | TIMESTAMPTZ | NO | now() | |

---

## Table: `audit_logs`

> ⚠️ **Append-only** — Never issue UPDATE or DELETE on this table.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | BIGSERIAL | NO | auto | PK (integer, not UUID) |
| `actor_user_id` | UUID | YES | NULL | FK → users(id) SET NULL |
| `action` | VARCHAR(100) | NO | — | Indexed |
| `resource_type` | VARCHAR(50) | NO | — | Indexed |
| `resource_id` | UUID | YES | NULL | Indexed |
| `ip_address` | INET | YES | NULL | |
| `user_agent` | TEXT | YES | NULL | |
| `request_id` | UUID | YES | NULL | Trace ID |
| `details` | JSONB | YES | NULL | Arbitrary context |
| `created_at` | TIMESTAMPTZ | NO | now() | No updated_at — immutable |

---

## Alembic Quick Reference

```bash
# From the ShieldID/ project root:

# 1. Apply all migrations to latest
alembic upgrade head

# 2. Create a new migration after modifying models
alembic revision --autogenerate -m "add_index_on_documents_status"

# 3. Roll back the last migration
alembic downgrade -1

# 4. Check what revision the DB is currently at
alembic current

# 5. View full migration history
alembic history --verbose
```

---

## Connection Strings

| Environment | URL |
|---|---|
| Local dev | `postgresql+asyncpg://shieldid:admin123@localhost:5432/shieldid` |
| Docker Compose | `postgresql+asyncpg://shieldid:admin123@db:5432/shieldid` |

Set via `DATABASE_URL` in your `.env` file (copy from `.env.example`).
# Current schema reference

**Database Engine:** PostgreSQL 15+  
**ORM Framework:** SQLAlchemy 2.0 (AsyncIO with `asyncpg`)  
**Migration Tool:** Alembic  
**Caching & Session Store:** Redis 7  

---

## 1. Architectural Overview

The ShieldID persistence layer is built on **PostgreSQL 15** utilizing native `JSONB` support for schema-flexible AI inference payloads (OCR extraction data and tampering analysis results). Asynchronous I/O is managed via `asyncpg` combined with SQLAlchemy 2.0 `Mapped` and `mapped_column` declarative models.

Alembic provides reproducible, version-controlled database schema migrations. A container initialization script (`deployment/scripts/init-db.sql`) guarantees idempotent bootstrapping on fresh environments with extensions enabled (`uuid-ossp`, `pgcrypto`).

---

## 2. Entity Relationship Diagram (ERD)

```mermaid
erDiagram
    VERIFICATIONS {
        int id PK "SERIAL Primary Key"
        varchar_50 document_type "Document classification"
        varchar_50 document_number "Masked / Unique Document ID"
        float risk_score "Aggregate risk score (0-100)"
        varchar_20 status "pending | verified | suspicious | rejected"
        float location_lat "GPS Latitude (optional)"
        float location_lng "GPS Longitude (optional)"
        timestamp timestamp "UTC timestamp (default NOW())"
        jsonb extracted_data "Full OCR extraction JSON"
        jsonb tamper_result "Tamper detection results JSON"
    }

    REPORTS {
        int id PK "SERIAL Primary Key"
        varchar_50 fir_number UK "Unique FIR identifier"
        varchar_50 document_type "Document type reported"
        varchar_500 description "Incident / Forgery description"
        varchar_100 reporter_name "Name of reporting officer/user"
        varchar_15 reporter_phone "Contact phone number"
        float location_lat "Incident GPS Latitude"
        float location_lng "Incident GPS Longitude"
        varchar_20 status "pending | under_investigation | resolved"
        timestamp timestamp "Filing timestamp (default NOW())"
    }
```

---

## 3. Table Specifications

### 3.1 `verifications` Table
Stores each document verification request, computed risk scores, OCR payload, and forensic tampering diagnostics.

| Column | Type | Nullable | Default | Constraints / Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | **No** | Auto-increment (`SERIAL`) | Primary Key. |
| `document_type` | `VARCHAR(50)` | **No** | - | Type of document: `passport`, `aadhaar`, `pan`, `driving_license`, `voter_id`. |
| `document_number` | `VARCHAR(50)` | **No** | - | Masked or raw document identifier (e.g., `Z1234567`, `XXXX XXXX 9012`). |
| `risk_score` | `FLOAT` | **No** | - | Calculated risk metric ranging from `0.0` (safe) to `100.0` (fraudulent). |
| `status` | `VARCHAR(20)` | **No** | `'pending'` | Lifecycle state: `pending`, `verified`, `suspicious`, `rejected`. |
| `location_lat` | `FLOAT` | Yes | `NULL` | WGS84 latitude of client or verification terminal. |
| `location_lng` | `FLOAT` | Yes | `NULL` | WGS84 longitude of client or verification terminal. |
| `timestamp` | `TIMESTAMP` | Yes | `NOW()` | UTC record creation timestamp. |
| `extracted_data` | `JSONB` | **No** | - | Structured document data extracted by OCR engine. |
| `tamper_result` | `JSONB` | Yes | `NULL` | Forensic tampering detection metrics and regions. |

#### `verifications` Performance Indexes
```sql
CREATE INDEX idx_verifications_status ON verifications(status);
CREATE INDEX idx_verifications_risk ON verifications(risk_score);
CREATE INDEX idx_verifications_timestamp ON verifications(timestamp);
CREATE INDEX idx_verifications_doc_number ON verifications(document_number);
```

#### JSONB Payload Schema: `extracted_data`
```json
{
  "document_type": "passport",
  "confidence_score": 0.95,
  "raw_text": "PASSPORT REPUBLIC OF INDIA RAHUL SHARMA Z1234567...",
  "parsed_fields": {
    "name": "Rahul Sharma",
    "passport_number": "Z1234567",
    "nationality": "Indian",
    "date_of_birth": "1990-01-15",
    "date_of_expiry": "2030-01-14",
    "gender": "M"
  }
}
```

#### JSONB Payload Schema: `tamper_result`
```json
{
  "is_tampered": false,
  "tamper_score": 0.08,
  "tampering_regions": [],
  "detection_method": "Error Level Analysis + CNN Forensic"
}
```

---

### 3.2 `reports` Table
Stores reported fraudulent document submissions, law enforcement incident tracking, and First Information Report (FIR) numbers.

| Column | Type | Nullable | Default | Constraints / Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | **No** | Auto-increment (`SERIAL`) | Primary Key. |
| `fir_number` | `VARCHAR(50)` | **No** | - | Unique system-generated FIR identifier (e.g., `FIR-2026-AB12CD`). |
| `document_type` | `VARCHAR(50)` | **No** | - | Type of fraudulent document reported. |
| `description` | `VARCHAR(500)` | **No** | - | Narrative explanation of forgery or observed irregularity. |
| `reporter_name` | `VARCHAR(100)` | Yes | `NULL` | Name of reporting officer, citizen, or KYC agent. |
| `reporter_phone` | `VARCHAR(15)` | Yes | `NULL` | Contact telephone number for follow-up investigation. |
| `location_lat` | `FLOAT` | Yes | `NULL` | Incident latitude coordinate. |
| `location_lng` | `FLOAT` | Yes | `NULL` | Incident longitude coordinate. |
| `status` | `VARCHAR(20)` | Yes | `'pending'` | Case workflow: `pending`, `investigating`, `action_taken`, `closed`. |
| `timestamp` | `TIMESTAMP` | Yes | `NOW()` | UTC timestamp when report was filed. |

#### `reports` Performance Indexes
```sql
CREATE UNIQUE INDEX idx_reports_fir ON reports(fir_number);
CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_timestamp ON reports(timestamp);
```

---

## 4. Alembic Migration Strategy

Database migrations are tracked in `migrations/` and orchestrated using Alembic.

### 4.1 Migration File: `001_initial_schema.py`
- **Revision ID:** `001`
- **Revises:** `None`
- **Actions:**
  - Creates `verifications` and `reports` tables.
  - Provisions single and composite indexes (`idx_verifications_status`, `idx_reports_fir`, etc.).
  - Downgrade removes indexes in reverse topological sequence and drops tables cleanly.

### 4.2 Executing Migrations

#### Apply latest migrations (Production / Staging):
```bash
alembic upgrade head
```

#### Rollback one migration:
```bash
alembic downgrade -1
```

#### Generate a new autodetected migration after model updates:
```bash
alembic revision --autogenerate -m "add_column_name_to_verifications"
```

---

## 5. Security, Masking & DPDP Act 2023 Compliance

1. **Aadhaar Masking**: In accordance with UIDAI regulations and the Digital Personal Data Protection (DPDP) Act 2023, the first 8 digits of Aadhaar numbers MUST be masked before persistence into `document_number` or `extracted_data` (e.g., `XXXX XXXX 9012`).
2. **Encryption at Rest**: Production storage volumes must utilize AES-256 block-level encryption (AWS EBS / GCP Persistent Disk) and column-level encryption via PostgreSQL `pgcrypto` for sensitive PII.
3. **Audit Trails**: All modifications to verification and report records are timestamped with UTC server time.
