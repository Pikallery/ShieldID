# 🛡️ ShieldID REST API Specification

**Version:** `1.0.0`  
**Protocol:** `HTTPS`  
**Base Path:** `/api/v1`  
**Format:** `JSON` (Requests & Responses) / `multipart/form-data` (File Uploads)  

---

## 1. Overview

**ShieldID** provides high-throughput, enterprise-grade REST APIs for automated identity verification, AI forensic tampering detection, biometric face matching, instant DigiLocker KYC, and automated fraud reporting across Indian identity documents (Passport, Aadhaar, PAN, Driving License, Voter ID).

Interactive OpenAPI documentation is automatically served by the application:
- **Swagger UI:** `http://localhost:8000/docs` (or `/api/docs`)
- **ReDoc:** `http://localhost:8000/redoc` (or `/api/redoc`)
- **OpenAPI JSON Schema:** `http://localhost:8000/openapi.json`

---

## 2. Server Environments

| Environment | Base URL | Description |
| :--- | :--- | :--- |
| **Local Development** | `http://localhost:8000` | Local containerized or virtualenv instance |
| **Staging** | `https://staging-api.shieldid.in` | Pre-production testing environment |
| **Production** | `https://api.shieldid.in` | Highly available Kubernetes production cluster |

---

## 3. Authentication & Authorization

All secure API endpoints require authentication via an API Key or Bearer JWT token in the HTTP request headers.

### 3.1 Bearer Token Header
```http
Authorization: Bearer <JWT_ACCESS_TOKEN>
```

### 3.2 Service API Key Header
```http
X-API-Key: <SHIELDID_CLIENT_KEY>
```

### 3.3 Security Responses
- `401 Unauthorized`: Missing, expired, or cryptographically invalid token/key.
- `403 Forbidden`: Insufficient scopes/permissions for the requested resource.

---

## 4. Standard Response Formats & Error Handling

ShieldID adheres to standard HTTP status codes and uniform JSON response envelopes.

### HTTP Status Code Summary
| Code | Status | Meaning |
| :--- | :--- | :--- |
| `200` | OK | Request succeeded. |
| `201` | Created | Resource successfully created. |
| `400` | Bad Request | Malformed request syntax or unparseable input. |
| `401` | Unauthorized | Missing or invalid authentication token. |
| `403` | Forbidden | Authenticated user lacks access to the resource. |
| `404` | Not Found | Target resource or verification ID does not exist. |
| `422` | Unprocessable Entity | Validation error in payload schema or missing fields. |
| `429` | Too Many Requests | Rate limit exceeded (default: 60 req/min per IP/token). |
| `500` | Internal Server Error | Unhandled server exception. |

### Standard Validation Error Envelope (`422`)
```json
{
  "detail": [
    {
      "loc": ["body", "purpose"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

---

## 5. Endpoints Reference

### 5.1 System & Health Checks

#### `GET /`
Returns high-level service status, platform version, and links to interactive documentation.

- **Method:** `GET`
- **Path:** `/`
- **Authentication:** None

**Response (200 OK):**
```json
{
  "service": "ShieldID",
  "version": "1.0.0",
  "status": "operational",
  "docs": "/api/docs"
}
```

---

#### `GET /health`
Liveness and readiness health probe used by container orchestrators (Docker, Kubernetes).

- **Method:** `GET`
- **Path:** `/health`
- **Authentication:** None

**Response (200 OK):**
```json
{
  "status": "healthy"
}
```

---

### 5.2 Verification Module (`/api/v1/verify`)

#### `POST /api/v1/verify/document`
Submit an identity document file (and optional live selfie) for OCR text extraction, tampering forensic analysis, and biometric facial matching.

- **Method:** `POST`
- **Path:** `/api/v1/verify/document`
- **Content-Type:** `multipart/form-data`
- **Authentication:** Bearer Token / API Key

##### Request Parameters
| Parameter | Type | In | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `document` | `UploadFile` (Binary) | FormData | **Yes** | Identity document image or PDF (JPEG, PNG, PDF, max 10MB). |
| `selfie` | `UploadFile` (Binary) | FormData | No | Live user portrait/selfie for biometric facial verification. |

##### cURL Example
```bash
curl -X POST "https://api.shieldid.in/api/v1/verify/document" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -F "document=@/path/to/passport.pdf;type=application/pdf" \
  -F "selfie=@/path/to/selfie.jpg;type=image/jpeg"
```

##### Python Example (`httpx`)
```python
import httpx

files = {
    "document": ("passport.pdf", open("passport.pdf", "rb"), "application/pdf"),
    "selfie": ("selfie.jpg", open("selfie.jpg", "rb"), "image/jpeg"),
}

with httpx.Client() as client:
    response = client.post("https://api.shieldid.in/api/v1/verify/document", files=files)
    print(response.json())
```

##### Response (200 OK)
```json
{
  "status": "verified",
  "risk_score": 15,
  "document_type": "passport",
  "name": "Rahul Sharma",
  "recommendation": "APPROVE"
}
```

##### Recommendation Values
- `APPROVE`: Overall risk score < 40. Document is authentic.
- `REVIEW_MANUALLY`: Risk score between 40 and 69. Low OCR confidence or minor artifact flagged.
- `REJECT`: Risk score >= 70. Significant tampering detected or facial mismatch.

---

#### `GET /api/v1/verify/status/{verification_id}`
Poll the current execution status of an asynchronous verification transaction.

- **Method:** `GET`
- **Path:** `/api/v1/verify/status/{verification_id}`
- **Authentication:** Bearer Token / API Key

##### Path Parameters
| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `verification_id` | `string` | **Yes** | Unique verification transaction identifier. |

##### cURL Example
```bash
curl -X GET "https://api.shieldid.in/api/v1/verify/status/SHIELD-VER-2026-009871" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

##### Response (200 OK)
```json
{
  "status": "completed",
  "verification_id": "SHIELD-VER-2026-009871"
}
```

---

### 5.3 Instant KYC Module (`/api/v1/kyc`)

#### `POST /api/v1/kyc/instant`
Initiates an instant KYC flow with DigiLocker-style redirect URL, verification token, and QR code for cross-device authentication.

- **Method:** `POST`
- **Path:** `/api/v1/kyc/instant`
- **Content-Type:** `application/json`
- **Authentication:** Bearer Token / API Key

##### Request Body Schema (`KYCRequest`)
| Field | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `purpose` | `string` | **Yes** | - | Business purpose (e.g., `bank_account`, `sim_card`, `onboarding`). |
| `return_url` | `string` | No | `null` | Redirection callback URL upon completion of user consent. |
| `consent` | `boolean` | No | `true` | Explicit user consent for identity data retrieval. |

##### Request Body Example
```json
{
  "purpose": "bank_account_opening",
  "return_url": "https://fintech.example.com/kyc/callback",
  "consent": true
}
```

##### cURL Example
```bash
curl -X POST "https://api.shieldid.in/api/v1/kyc/instant" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "purpose": "bank_account_opening",
    "return_url": "https://fintech.example.com/kyc/callback",
    "consent": true
  }'
```

##### Response (200 OK) (`KYCResponse`)
```json
{
  "status": "pending",
  "kyc_token": "SHIELD-KYC-2026-001234",
  "qr_code": "https://api.qrserver.com/v1/create-qr-code/?data=SHIELD-KYC-2026-001234",
  "digilocker_redirect": "https://digilocker.gov.in/",
  "message": "Redirecting to DigiLocker for consent..."
}
```

---

### 5.4 Fraud Reporting Module (`/api/v1/report`)

#### `POST /api/v1/report/fake`
Report a fraudulent, tampered, or forged identity document to dispatch automated cyber crime records and generate a First Information Report (FIR) reference.

- **Method:** `POST`
- **Path:** `/api/v1/report/fake`
- **Content-Type:** `multipart/form-data`
- **Authentication:** Bearer Token / API Key

##### Request Parameters
| Parameter | Type | In | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `document` | `UploadFile` (Binary) | FormData | **Yes** | Fraudulent document image or scan. |
| `description` | `string` | FormData | No | Narrative description of detected forgery or tampering. |
| `latitude` | `float` | FormData | No | GPS latitude coordinate where incident was reported. |
| `longitude` | `float` | FormData | No | GPS longitude coordinate where incident was reported. |

##### cURL Example
```bash
curl -X POST "https://api.shieldid.in/api/v1/report/fake" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -F "document=@/path/to/fake_aadhaar.jpg;type=image/jpeg" \
  -F "description=Tampered photo box and mismatched QR code on Aadhaar card" \
  -F "latitude=28.6139" \
  -F "longitude=77.2090"
```

##### Response (200 OK)
```json
{
  "status": "success",
  "fir_number": "FIR-2026-A1B2C3",
  "message": "Report filed successfully. Police notified.",
  "assigned_station": "Nearest Police Station"
}
```

---

## 6. Rate Limiting & Security Policies

- **Rate Limit Window:** 60 requests per minute per IP address / API key.
- **Header Indicators:**
  - `X-RateLimit-Limit`: Maximum allowable requests per window.
  - `X-RateLimit-Remaining`: Remaining request allowance.
  - `X-RateLimit-Reset`: UTC epoch timestamp when current window resets.
- **CORS:** Controlled via `ALLOWED_ORIGINS` setting (`["*"]` in development; restricted to whitelisted domain origins in production).
- **Compliance:** Full compliance with the Digital Personal Data Protection (DPDP) Act 2023. Aadhaar numbers in OCR payloads are automatically masked (`XXXX XXXX 1234`) according to UIDAI regulations.
