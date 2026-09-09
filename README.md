<p align="center">
	<img src="frontend/mobile/web/shieldid-logo.png" alt="ShieldID logo" width="220">
</p>

<h1 align="center">ShieldID</h1>

<p align="center"><strong>AI-powered identity verification and document fraud screening</strong></p>

<p align="center">Scan documents, validate identity, detect tampering, and make safer KYC decisions from one connected platform.</p>

<p align="center">
	<a href="https://github.com/Pikallery/ShieldID/actions">CI</a> ·
	<a href="docs/API_SPEC.md">API specification</a> ·
	<a href="docs/DEPLOYMENT_GUIDE.md">Deployment guide</a>
</p>

## What ShieldID Does

ShieldID combines document intelligence, face verification, liveness checks, tamper analysis, risk scoring, and KYC workflows for identity screening across Indian identity documents such as Aadhaar, passport, PAN, driving licence, and voter ID.

The system is designed for three real-world surfaces:

| Surface | Purpose | Entry point |
| --- | --- | --- |
| Desktop dashboard | Review screening activity, risk signals, and verification results | `/` |
| Verification kiosk | Guided self-service capture flow for a counter or reception device | `/kiosk.html` |
| Mobile app | Capture documents and biometrics from a phone | `/mobile/` or the installed Flutter app |

## Demo Routing

When the hosted root URL is opened, the web entry point selects the experience automatically:

- Phones and tablets are redirected from `/` to `/mobile/`.
- Desktop browsers stay on the React dashboard at `/`.
- The dashboard opens the kiosk flow at `/kiosk.html`.
- `/?mobile=1` forces the mobile route for testing.
- `/?desktop=1` forces the desktop dashboard for testing.

All three experiences can use the same domain. The Flutter web build must be deployed under `/mobile/` for phone routing to work.

## Core Capabilities

- **Document verification:** OCR extraction, document classification, confidence scoring, and structured identity data.
- **Tamper analysis:** Detection signals for copy-move edits, photo swaps, altered text, forged stamps, and suspicious document structure.
- **Face verification:** Face matching, liveness challenges, facial landmark overlays, and similarity scoring.
- **Risk decisions:** Pass, review, or reject outcomes with explainable signals and a visual risk gauge.
- **KYC workflows:** Consent-driven verification, QR tokens, status polling, and audit-ready results.
- **Currency screening:** A processor path for checking banknote authenticity features.
- **Fraud reporting:** Structured fraud reports and downstream case information.
- **Modular processing:** Shared processor abstractions make OCR, face, tampering, currency, and predictive modules extensible.

## Architecture

```text
										+-----------------------------+
										|        ShieldID API         |
										| FastAPI + verification flow |
										+-------------+---------------+
																	|
			 +--------------------------+--------------------------+
			 |                          |                          |
	React dashboard            Kiosk web flow             Flutter mobile
			 |                          |                          |
			 +--------------------------+--------------------------+
																	|
							OCR | face | liveness | tampering | risk
																	|
								 PostgreSQL + Redis + model artifacts
```

## Technology Stack

| Area | Technologies |
| --- | --- |
| API | FastAPI, Uvicorn, Pydantic v2 |
| Data | PostgreSQL, SQLAlchemy, asyncpg, Redis |
| AI processing | OpenCV, NumPy, Pillow, model artifacts in `models/` |
| Desktop and kiosk web | React, Vite, HTML, CSS, JavaScript |
| Mobile | Flutter and Dart |
| Delivery | Docker, Docker Compose, Kubernetes manifests, GitHub Actions |

## Repository Layout

```text
ShieldID/
├── src/                         FastAPI application, processors, schemas, services
├── tests/                       Unit and integration tests
├── models/                      AI model artifacts and processor configuration
├── migrations/                  Alembic database migrations
├── frontend/
│   ├── dashboard/               React dashboard, kiosk page, and API docs page
│   └── mobile/                  Flutter app, web shell, icons, and widget tests
├── docs/                        API, database, and deployment documentation
├── deployment/                  Docker and Kubernetes deployment files
├── docker-compose.yml           API, PostgreSQL, and Redis development stack
├── requirements.txt             Python dependencies
└── README.md
```

## Quick Start

### Prerequisites

- Python 3.10 or newer
- Git
- Node.js 18 or newer for the dashboard
- Flutter 3.x for the mobile app
- Docker Desktop for PostgreSQL and Redis

### Backend

```bash
git clone https://github.com/Pikallery/ShieldID.git
cd ShieldID

python -m venv venv

# Windows
venv\Scripts\activate

# Linux/macOS
source venv/bin/activate

pip install -r requirements.txt
docker compose up -d db redis
uvicorn src.main:app --reload --port 8080
```

API documentation: [http://localhost:8080/api/docs](http://localhost:8080/api/docs)

To run the complete backend stack in containers:

```bash
docker compose up --build
```

### React dashboard and kiosk

```bash
cd frontend/dashboard
npm install
npm run dev
```

Open the Vite URL shown in the terminal. The dashboard is at `/`, the kiosk is at `/kiosk.html`, and API documentation is at `/docs.html`.

### Flutter mobile app

```bash
cd frontend/mobile
flutter pub get
flutter run
```

For a hosted mobile web build:

```bash
flutter build web --release --base-href /mobile/
```

Deploy the contents of `frontend/mobile/build/web` under the `/mobile/` path of the same host as the dashboard.

## API Surface

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `GET` | `/` | Service status |
| `GET` | `/health` | Health check |
| `POST` | `/api/v1/verify/document` | Verify a document and optional selfie |
| `GET` | `/api/v1/verify/status/{id}` | Poll verification status |
| `POST` | `/api/v1/kyc/instant` | Start an instant KYC flow |
| `POST` | `/api/v1/report/fake` | Submit a fraudulent-document report |

Interactive API references are available at `/api/docs` and `/api/redoc` when the backend is running.

## Verification and Tests

Run backend checks from the repository root:

```bash
ruff check src/
pytest tests/ -v --cov=src
```

Run dashboard checks:

```bash
cd frontend/dashboard
npm run build
```

Run Flutter checks:

```bash
cd frontend/mobile
flutter test
flutter analyze
```

## Documentation

- [API specification](docs/API_SPEC.md)
- [Database schema](docs/DATABASE_SCHEMA.md)
- [Deployment guide](docs/DEPLOYMENT_GUIDE.md)
- [Mobile app guide](frontend/mobile/README.md)

## License

This project is licensed under the MIT License.