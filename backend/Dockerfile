# ──────────────────────────────────────────────
# Hydro Smart — ML Crop Recommendation Backend
# ──────────────────────────────────────────────
# Multi-stage build to fit Render free tier (512MB).
# Stage 1: train model (has pandas + full scikit-learn)
# Stage 2: serve API  (lightweight, ~200MB)
# ──────────────────────────────────────────────

# === STAGE 1: Train model ===
FROM python:3.11-slim AS builder
WORKDIR /build
COPY requirements-build.txt .
RUN pip install --no-cache-dir -r requirements-build.txt
COPY train_model.py .
RUN python train_model.py --output . --samples 5000

# === STAGE 2: Serve API (lightweight) ===
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ml_api.py .
COPY --from=builder /build/model.pkl .

EXPOSE 10000

# Single uvicorn process — no gunicorn overhead
CMD uvicorn ml_api:app --host 0.0.0.0 --port ${PORT:-10000}
