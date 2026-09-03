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
| **AI / ML Modules** | PyTorch, OpenCV, EasyOCR, DeepFace, Scikit-learn |
| **Security** | OAuth2, JWT, Cryptographic Password Hashing |
| **Infrastructure** | Docker, Docker Compose, GitHub Actions |

---

## Project Structure

```text
ShieldID/
├── src/
│   ├── api/
│   │   └── v1/
│   │       ├── router.py          # API v1 route aggregator
│   │       ├── verify.py          # Document verification & status endpoints
│   │       ├── kyc.py             # Instant KYC & token endpoints
│   │       └── report.py          # Fraud report & FIR dispatch endpoints
│   ├── core/
│   │   └── config.py              # Central application settings (Pydantic v2)
│   ├── processors/
│   │   └── base_processor.py      # Abstract base processor for AI modules
│   ├── schemas/
│   │   ├── document.py            # Document schemas (Passport, Aadhaar, PAN, etc.)
│   │   ├── verification.py        # OCR, tampering, and risk score schemas
│   │   └── kyc.py                 # KYC request and response schemas
│   └── main.py                    # FastAPI application entry point
├── tests/                         # Unit and integration test suites
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

### 4. Run Development Server
```bash
uvicorn src.main:app --reload --port 8080
```

Access the API documentation at: [http://localhost:8080/api/docs](http://localhost:8080/api/docs)

---

## License

This project is licensed under the MIT License.