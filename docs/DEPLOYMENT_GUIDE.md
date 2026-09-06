# 🚀 ShieldID Production Deployment Guide

**Target Environments:** Docker Compose, Kubernetes (K8s), Cloud VM (AWS EC2 / GCP Compute Engine)  
**Application Stack:** FastAPI, PostgreSQL 15, Redis 7, Uvicorn  

---

## 1. Architecture Overview

ShieldID is designed with a cloud-native, microservices-ready architecture:

```text
       Internet / Client Traffic
                   │
                   ▼
     [ Nginx / Ingress Controller ]
           (SSL/TLS Termination)
                   │
                   ▼
     [ ShieldID Backend (FastAPI) ] (Replicas: 2+)
            │             │
            ▼             ▼
  [ PostgreSQL 15 ]   [ Redis 7 ]
  (Relational Data)   (Cache / Rate Limits)
```

- **Backend API**: Python 3.10-slim container executing `uvicorn src.main:app` with multiple worker processes.
- **PostgreSQL 15**: Primary persistence store for verification transactions, FIR reports, and JSONB forensic data.
- **Redis 7**: High-performance in-memory cache and rate-limiting store.
- **Storage**: Persistent Volumes (PVC) for PostgreSQL data directory.

---

## 2. Prerequisites

Ensure the deployment host or cluster satisfies the following minimum requirements:

- **Operating System:** Linux (Ubuntu 22.04 LTS / Debian 12 / RHEL 9)
- **Docker Engine:** `24.0+`
- **Docker Compose:** `v2.20+`
- **Kubernetes (for K8s deployments):** `v1.26+` with `kubectl` configured
- **Hardware Sizing (per backend node):**
  - Minimum: 2 vCPU, 4GB RAM
  - Recommended: 4 vCPU, 8GB RAM (with GPU acceleration for heavy OCR/DeepFace inference)

---

## 3. Environment Variables Configuration

Create a production `.env` file in the root directory based on `.env.example`:

```bash
cp .env.example .env
```

### Environment Variables Reference

| Variable | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `PROJECT_NAME` | `string` | `ShieldID` | Project service identifier. |
| `VERSION` | `string` | `1.0.0` | Application release version. |
| `API_V1_PREFIX` | `string` | `/api/v1` | URL routing prefix for v1 endpoints. |
| `DATABASE_URL` | `string` | `postgresql+asyncpg://user:pass@host:5432/db` | Async PostgreSQL connection string. |
| `REDIS_URL` | `string` | `redis://host:6379/0` | Redis connection URL. |
| `SECRET_KEY` | `string` | *Required in Prod* | Cryptographic 256-bit random secret key for JWT/HMAC. |
| `JWT_ALGORITHM` | `string` | `HS256` | JWT signing algorithm. |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | `integer` | `30` | Access token lifespan in minutes. |
| `ALLOWED_ORIGINS` | `JSON array` | `["https://app.shieldid.in"]` | Allowed CORS origins for browser security. |
| `MODE` | `string` | `production` | Runtime mode (`development` or `production`). |

> [!WARNING]
> In production, never use the default `SECRET_KEY` or default database credentials. Generate a secure secret using:
> ```bash
> python3 -c "import secrets; print(secrets.token_urlsafe(32))"
> ```

---

## 4. Deployment with Docker Compose

Docker Compose is the recommended deployment method for single-host production instances and staging environments.

### 4.1 Configuration Files
- **Backend Dockerfile:** `deployment/docker/Dockerfile.backend`
- **Compose Manifest:** `docker-compose.yml`
- **Database Init Script:** `deployment/scripts/init-db.sql`

### 4.2 Step-by-Step Execution

#### Step 1: Clone the Repository & Configure Environment
```bash
git clone https://github.com/Pikallery/ShieldID.git
cd ShieldID
cp .env.example .env
# Edit .env with production passwords and secret keys
nano .env
```

#### Step 2: Build and Launch Services
```bash
docker compose up -d --build
```

#### Step 3: Verify Container Health
```bash
docker compose ps
```
*Expected Output:*
```text
NAME                IMAGE                     COMMAND                  SERVICE   STATUS
shieldid-backend    shieldid-backend          "uvicorn src.main:ap…"   backend   running (healthy)
shieldid-db         postgres:15-alpine        "docker-entrypoint.s…"   db        running (healthy)
shieldid-redis      redis:7-alpine            "docker-entrypoint.s…"   redis     running (healthy)
```

#### Step 4: Run Database Migrations
```bash
docker compose exec backend alembic upgrade head
```

#### Step 5: Test API Liveness Probe
```bash
curl -i http://localhost:8000/health
```
*Response:*
```http
HTTP/1.1 200 OK
content-type: application/json

{"status":"healthy"}
```

---

## 5. Kubernetes (K8s) Deployment

For high-availability, auto-scaling production workloads, deploy using the bundled Kubernetes manifest located at `deployment/k8s/deployment.yaml`.

### 5.1 Architecture of `deployment.yaml`
The Kubernetes manifest defines complete isolated infrastructure in the `shieldid` namespace:
1. **Namespace:** `shieldid`
2. **ConfigMap:** `shieldid-config` (Environment mode, project metadata)
3. **Secret:** `shieldid-secrets` (PostgreSQL credentials, Redis URL, JWT Secret)
4. **PersistentVolumeClaim:** `postgres-pvc` (5Gi storage for persistent PostgreSQL data)
5. **PostgreSQL Deployment & Service:** `shieldid-db` on port `5432` with readiness probe
6. **Redis Deployment & Service:** `shieldid-redis` on port `6379`
7. **Backend Deployment & Service:**
   - 2 initial replicas
   - Liveness probe: `HTTP GET /health` on port 8000
   - Readiness probe: `HTTP GET /health` on port 8000
   - Resource limits: CPU `500m`, Memory `512Mi`
   - Service Type: `LoadBalancer` (port 80 -> 8000)

### 5.2 Step-by-Step K8s Deployment

#### Step 1: Create Namespace and Deploy All Resources
```bash
kubectl apply -f deployment/k8s/deployment.yaml
```

#### Step 2: Monitor Deployment Progress
```bash
kubectl get pods -n shieldid -w
```

#### Step 3: Verify Services and External IP
```bash
kubectl get svc -n shieldid
```

#### Step 4: Execute Database Migrations Inside the Backend Pod
```bash
BACKEND_POD=$(kubectl get pods -n shieldid -l app=shieldid-backend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n shieldid $BACKEND_POD -- alembic upgrade head
```

#### Step 5: View Backend Pod Logs
```bash
kubectl logs -n shieldid deployment/shieldid-backend -f
```

---

## 6. SSL / TLS Termination & Nginx Ingress

For production internet traffic, terminate TLS using an Ingress Controller (e.g., Ingress-Nginx) with Let's Encrypt automated certificates:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: shieldid-ingress
  namespace: shieldid
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/proxy-body-size: "15m"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - api.shieldid.in
      secretName: shieldid-tls-cert
  rules:
    - host: api.shieldid.in
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: shieldid-backend
                port:
                  number: 80
```

---

## 7. Monitoring, Logging & Troubleshooting

### 7.1 Health Check Endpoints
- **Liveness & Readiness Probe:** `GET /health` returns `{"status": "healthy"}`
- **System Overview:** `GET /` returns platform and operational metadata

### 7.2 Common Troubleshooting Scenarios

#### Scenario 1: Backend Cannot Connect to Database (`asyncpg.exceptions`)
- **Cause:** PostgreSQL container still initializing or incorrect `DATABASE_URL`.
- **Solution:** Verify the `db` container health status (`docker compose ps db`). Ensure `DATABASE_URL` matches the service hostname (`db` in Docker, `shieldid-db` in Kubernetes).

#### Scenario 2: Redis Connection Refused
- **Cause:** Redis server not running or network partition.
- **Solution:** Inspect Redis logs: `docker compose logs redis` or `kubectl logs -n shieldid deployment/shieldid-redis`. Ensure port `6379` is reachable.

#### Scenario 3: Large File Upload Timeout or 413 Payload Too Large
- **Cause:** Default reverse proxy limits upload size.
- **Solution:** Increase `client_max_body_size` in Nginx or add annotation `nginx.ingress.kubernetes.io/proxy-body-size: "15m"` in Kubernetes Ingress.

#### Scenario 4: Alembic Migration Conflicts
- **Cause:** Database schema out of sync with migration scripts.
- **Solution:** Verify current revision: `alembic current`. Stamp database to baseline if schema was initialized with `init-db.sql`: `alembic stamp head`.
