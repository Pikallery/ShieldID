# 🛡️ ShieldID

**AI-Powered Identity Verification Platform for India**

*Scan. Verify. Protect.*

---

## Overview

**ShieldID** is an enterprise-grade identity verification and fraud prevention platform built to detect forged identity documents, execute real-time KYC, and mitigate document tampering across Indian identity systems (Aadhaar, Passport, PAN, Driving License, Voter ID).

---

## Key Features

-  **Instant Document Verification**: Authenticates Passport, Aadhaar, PAN, Driving License, and Voter ID with OCR extraction and confidence scoring.
-  **AI Tampering Detection**: Heuristic and neural analysis for copy-move tampering, photo swapping, text alteration, and stamp forgery.
-  **Biometric Face Matching**: Face detection, liveness verification, and similarity scoring between document photos and selfies.
-  **Instant KYC**: Seamless DigiLocker-style user consent and QR code verification tokens.
-  **Automated Fraud Reporting**: Auto-dispatch FIR generation with geo-location tagging and cyber crime station routing.
-  **Counterfeit Currency Detection**: AI inspection for banknote security features.
-  **Extensible Architecture**: Modular `BaseProcessor` pipeline allowing modular AI/ML inference plugins.

---

## Tech Stack

| Layer | Technologies |
| :--- | :--- |
| **API & Backend** | FastAPI, Uvicorn, Pydantic v2 |
| **Database & Cache** | PostgreSQL (asyncpg / SQLAlchemy), Redis |
| **AI / ML Modules** | OpenCV, NumPy, Pillow, model artifacts in `models/` |
| **Security** | OAuth2, JWT, Cryptographic Password Hashing |
| **Infrastructure** | Docker, Docker Compose, GitHub Actions |

---

## Project Structure

```text
ShieldID/
├── alembic.ini                   # Alembic configuration
├── deployment/
│   ├── docker/                   # Backend container definition
│   ├── k8s/                      # Kubernetes manifests
│   ├── scripts/                  # Database initialization scripts
│   ├── docker-compose.yml        # Deployment Compose configuration
│   └── Dockerfile.backend        # Deployment backend image
├── docs/                         # API, database, and deployment guides
├── migrations/
│   ├── env.py                    # Alembic runtime configuration
│   ├── script.py.mako            # Migration template
│   └── versions/                 # Versioned schema migrations
├── src/
│   ├── api/
│   │   ├── v1/
│   │       ├── router.py          # API v1 route aggregator
│   │       ├── verify.py          # Document verification & status endpoints
│   │       ├── kyc.py             # Instant KYC & token endpoints
│   │       └── report.py          # Fraud report & FIR dispatch endpoints
│   │   └── v2/                    # Reserved for API v2 routes
│   ├── core/
│   │   ├── config.py              # Central application settings (Pydantic v2)
│   │   └── database.py            # SQLAlchemy models and async database session
│   ├── processors/
│   │   ├── base_processor.py      # Abstract base processor for AI modules
│   │   ├── currency/              # Currency authenticity processor
│   │   ├── face/                  # Face matching processor
│   │   ├── ocr/                   # Document text extraction processor
│   │   ├── predictive/             # Risk prediction processor
│   │   └── tampering/              # Document tampering processor
│   ├── schemas/
│   │   ├── document.py            # Document schemas (Passport, Aadhaar, PAN, etc.)
│   │   ├── verification.py        # OCR, tampering, and risk score schemas
│   │   └── kyc.py                 # KYC request and response schemas
│   ├── services/
│   │   ├── database_services.py   # Shared database operations
│   │   ├── verification_service.py # Verification workflow service
│   │   ├── kyc_service.py         # KYC workflow service
│   │   └── report_service.py      # Fraud reporting service
│   └── main.py                    # FastAPI application entry point
├── frontend/
│   ├── dashboard/src/             # Dashboard components, pages, and utilities
│   ├── kiosk/                     # Kiosk web client
│   └── mobile/lib/                # Mobile models, screens, services, and widgets
├── models/                        # Local model files
├── scripts/                       # Project utility scripts
├── tests/
│   ├── unit/                      # Processor, schema, config, and API tests
│   └── integration/               # API and database integration tests
├── docker-compose.yml              # API, PostgreSQL, and Redis services
├── Dockerfile                      # Root container definition
├── requirements.txt               # Application dependencies
└── README.md
```

---

## API Endpoints (v1)

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/` | Service root and operational status |
| `GET` | `/health` | Application health check |
| `POST` | `/api/v1/verify/document` | Upload document & optional selfie for verification |
| `GET` | `/api/v1/verify/status/{id}` | Poll verification processing status |
| `POST` | `/api/v1/kyc/instant` | Initiate instant KYC with QR code and DigiLocker URL |
| `POST` | `/api/v1/report/fake` | Submit fraudulent document report and receive FIR number |

Interactive OpenAPI documentation is available at `/api/docs` and `/api/redoc`.

---

## Getting Started

### Prerequisites
- Python 3.10+
- Git

### 1. Clone the Repository
```bash
git clone https://github.com/Pikallery/ShieldID.git
cd ShieldID
```

### 2. Set Up Virtual Environment
```bash
python -m venv venv

# Windows:
venv\Scripts\activate

# Linux / macOS:
source venv/bin/activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Configure the Environment
```bash
# Windows
copy .env.example .env

# Linux / macOS
cp .env.example .env
```

Update `DATABASE_URL`, `REDIS_URL`, and `SECRET_KEY` in `.env` for your environment.

### 5. Run Development Server
```bash
uvicorn src.main:app --reload --port 8080
```

Access the API documentation at: [http://localhost:8080/api/docs](http://localhost:8080/api/docs)

### Docker Compose

Docker Compose starts the API, PostgreSQL, and Redis services:

```bash
docker compose up --build
```

The containerized API is available at [http://localhost:8000/api/docs](http://localhost:8000/api/docs).

## Development Checks

Run the same checks used by CI from the repository root:

```bash
ruff check src/
pytest tests/ -v --cov=src
```

The test suite includes unit and integration coverage. PostgreSQL and Redis are not required for the local unit tests, but are started by Docker Compose for service-level development.

---

## License

This project is licensed under the MIT License.