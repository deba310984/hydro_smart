FROM python:3.11-slim

WORKDIR /app

# Only copy the ML backend folder
COPY ml_backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ml_backend/ .

# Train model at build time (generates model.pkl from synthetic data)
RUN python train_model.py --output .

EXPOSE 8000

# Render sets $PORT automatically; use it
CMD gunicorn main:app --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:${PORT:-8000} --workers 2 --timeout 120
