# ──────────────────────────────────────────────
# Hydro Smart — ML Crop Recommendation Backend
# ──────────────────────────────────────────────
# Deployed on Render.com (Docker runtime, free tier).
# Trains model at build time, serves FastAPI predictions.
# ──────────────────────────────────────────────

FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy all source (ml_api.py = FastAPI app, train_model.py = trainer)
COPY . .

# Train a LIGHT model at build time (fewer samples + trees to fit 512MB)
RUN python train_model.py --output . --samples 10000

EXPOSE 10000

# 1 worker + preload to fit Render free tier 512MB RAM limit
CMD gunicorn ml_api:app --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:${PORT:-10000} --workers 1 --timeout 120 --preload
