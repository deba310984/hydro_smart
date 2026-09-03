"""
Hydro Smart — ML Crop Recommendation API
==========================================
FastAPI backend that serves crop predictions from a trained
RandomForestClassifier model.

Endpoints:
  POST /predict          → single crop prediction
  POST /predict/top      → top-N predictions with confidence
  GET  /crops            → list of all known crops
  GET  /locations        → list of all known locations
  GET  /health           → health check

Run locally:
  uvicorn main:app --host 0.0.0.0 --port 8000 --reload

Deploy on Render:
  See ML_DEPLOYMENT_GUIDE.md
"""

import os
import logging
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Optional

import joblib
import numpy as np
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

# ──────────────────────────────────────────────
# Logging
# ──────────────────────────────────────────────
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("ml_backend")

# ──────────────────────────────────────────────
# Global model artifacts (loaded once at startup)
# ──────────────────────────────────────────────
MODEL_DATA: dict = {}

MODEL_PATH = Path(os.environ.get("MODEL_PATH", Path(__file__).parent / "model.pkl"))


def load_model():
    """Load model artifacts from disk."""
    if not MODEL_PATH.exists():
        logger.error(f"Model file not found at {MODEL_PATH}")
        raise FileNotFoundError(
            f"model.pkl not found at {MODEL_PATH}. Run train_model.py first."
        )

    data = joblib.load(MODEL_PATH)
    MODEL_DATA.update(data)
    logger.info(
        f"Model loaded: {len(data['crop_names'])} crops, "
        f"{len(data['all_locations'])} locations"
    )


# ──────────────────────────────────────────────
# App lifecycle
# ──────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Load ML model on startup."""
    load_model()
    yield
    MODEL_DATA.clear()


app = FastAPI(
    title="Hydro Smart ML Crop Recommendation API",
    version="1.0.0",
    description="AI-powered hydroponic crop recommendations using RandomForest",
    lifespan=lifespan,
)

# CORS — allow Flutter app from any origin
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ──────────────────────────────────────────────
# Request / Response schemas
# ──────────────────────────────────────────────
class PredictRequest(BaseModel):
    temperature: float = Field(..., ge=-10, le=60, description="Temperature in °C")
    humidity: float = Field(..., ge=0, le=100, description="Relative humidity %")
    location: str = Field(..., min_length=1, description="Indian state name")
    month: int = Field(..., ge=1, le=12, description="Month number (1-12)")


class PredictResponse(BaseModel):
    recommended_crop: str
    confidence: float
    location_used: str
    input_summary: dict


class TopPrediction(BaseModel):
    crop: str
    confidence: float


class TopPredictResponse(BaseModel):
    predictions: list[TopPrediction]
    input_summary: dict


# ──────────────────────────────────────────────
# Prediction logic
# ──────────────────────────────────────────────
def _encode_location(location: str) -> tuple[int, str]:
    """Encode location string, with fuzzy fallback."""
    le_location = MODEL_DATA["label_encoder_location"]
    known = list(le_location.classes_)

    # Exact match
    if location in known:
        return int(le_location.transform([location])[0]), location

    # Case-insensitive match
    lower_map = {k.lower(): k for k in known}
    if location.lower() in lower_map:
        matched = lower_map[location.lower()]
        return int(le_location.transform([matched])[0]), matched

    # Partial match
    for k in known:
        if location.lower() in k.lower() or k.lower() in location.lower():
            return int(le_location.transform([k])[0]), k

    # Genuinely unknown (e.g. a user outside India). Signal this with -1 so
    # the caller marginalises over every known location rather than pinning
    # the prediction to one arbitrary state, which skewed results badly.
    logger.info(f"Unknown location '{location}', using climate-only prediction")
    return -1, "Climate-based (location not recognised)"


def _predict(req: PredictRequest) -> tuple[np.ndarray, str]:
    """Run prediction, return (probabilities_array, location_used)."""
    model = MODEL_DATA["model"]
    scaler = MODEL_DATA["scaler"]

    loc_enc, loc_used = _encode_location(req.location)

    # Engineered features (must match training feature order exactly)
    t = float(req.temperature)
    h = float(req.humidity)
    month_sin = float(np.sin(2 * np.pi * req.month / 12))
    month_cos = float(np.cos(2 * np.pi * req.month / 12))
    temp_hum_interaction = t * h / 100

    # Dew point (Magnus formula) and vapour pressure deficit - VPD is the
    # dominant driver of transpiration in controlled-environment growing
    # and is the strongest climate feature the model has after humidity.
    rh = min(max(h, 1.0), 100.0)
    alpha = (17.27 * t) / (237.7 + t) + np.log(rh / 100.0)
    dew_point = float((237.7 * alpha) / (17.27 - alpha))
    svp = 0.6108 * np.exp((17.27 * t) / (t + 237.3))
    vpd = float(svp * (1 - rh / 100.0))

    # Feature order: temperature, humidity, location_enc, month,
    #                month_sin, month_cos, temp_hum_interaction,
    #                dew_point, vpd
    def _row(loc_code: int) -> list:
        return [t, h, loc_code, req.month,
                month_sin, month_cos, temp_hum_interaction,
                dew_point, vpd]

    if loc_enc < 0:
        # Unrecognised location: marginalise the location out by averaging
        # the prediction over every location the model knows. That answers
        # "what suits this climate?" instead of silently assuming one state.
        n_locs = len(MODEL_DATA["label_encoder_location"].classes_)
        features = np.array([_row(i) for i in range(n_locs)], dtype=float)
    else:
        features = np.array([_row(loc_enc)], dtype=float)

    # Scale the same indices used during training. The stored list is the
    # authority - every numeric column is scaled, location_enc is not.
    scale_indices = MODEL_DATA.get("scale_indices", [0, 1, 6])
    features[:, scale_indices] = scaler.transform(features[:, scale_indices])

    probas = model.predict_proba(features).mean(axis=0)
    return probas, loc_used


# ──────────────────────────────────────────────
# Endpoints
# ──────────────────────────────────────────────
@app.post("/predict", response_model=PredictResponse)
async def predict_crop(req: PredictRequest):
    """Predict single best crop for given conditions."""
    try:
        probas, loc_used = _predict(req)
        crop_names = MODEL_DATA["crop_names"]

        best_idx = int(np.argmax(probas))
        best_crop = crop_names[best_idx]
        confidence = round(float(probas[best_idx]) * 100, 1)

        return PredictResponse(
            recommended_crop=best_crop,
            confidence=confidence,
            location_used=loc_used,
            input_summary={
                "temperature": req.temperature,
                "humidity": req.humidity,
                "location": req.location,
                "month": req.month,
            },
        )
    except Exception as e:
        logger.exception("Prediction error")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/predict/top", response_model=TopPredictResponse)
async def predict_top_crops(req: PredictRequest, n: int = 5):
    """Return top-N crop predictions with confidence scores."""
    try:
        probas, loc_used = _predict(req)
        crop_names = MODEL_DATA["crop_names"]

        top_indices = np.argsort(probas)[::-1][:n]
        predictions = [
            TopPrediction(
                crop=crop_names[i],
                confidence=round(float(probas[i]) * 100, 1),
            )
            for i in top_indices
            if probas[i] > 0.01  # only include crops with >1% probability
        ]

        return TopPredictResponse(
            predictions=predictions,
            input_summary={
                "temperature": req.temperature,
                "humidity": req.humidity,
                "location": req.location,
                "month": req.month,
            },
        )
    except Exception as e:
        logger.exception("Top prediction error")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/crops")
async def list_crops():
    """List all crops the model knows about."""
    return {"crops": MODEL_DATA.get("crop_names", [])}


@app.get("/locations")
async def list_locations():
    """List all locations the model was trained on."""
    return {"locations": MODEL_DATA.get("all_locations", [])}


@app.get("/health")
async def health():
    """Health check endpoint."""
    model_loaded = bool(MODEL_DATA.get("model"))
    return {
        "status": "healthy" if model_loaded else "model_not_loaded",
        "model_loaded": model_loaded,
        "num_crops": len(MODEL_DATA.get("crop_names", [])),
        "num_locations": len(MODEL_DATA.get("all_locations", [])),
    }


@app.get("/")
async def root():
    """Root endpoint with API info."""
    return {
        "service": "Hydro Smart ML Crop Recommendation API",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health",
    }
