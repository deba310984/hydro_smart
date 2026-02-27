# ML Crop Recommendation — Deployment Guide

Complete guide for the AI-powered crop recommendation system in Hydro Smart.

---

## Architecture

```
┌────────────────┐      POST /predict       ┌──────────────────────┐
│  Flutter App   │  ──────────────────────►  │  FastAPI ML Backend  │
│  (crop_page)   │  ◄──────────────────────  │  (RandomForest)      │
│                │    { recommended_crop }   │  model.pkl           │
└────────────────┘                           └──────────────────────┘
       │                                              │
       │ weather data (Open-Meteo)                    │ trained on
       │ GPS location (Geolocator)                    │ synthetic / Kaggle data
       ▼                                              ▼
  temperature, humidity,                        train_model.py
  location, month                               (scikit-learn)
```

---

## 1. Connect a Kaggle Dataset

### Option A: Use the Crop Recommendation Dataset
1. Go to: https://www.kaggle.com/datasets/atharvaingle/crop-recommendation-dataset
2. Download `Crop_recommendation.csv`
3. The CSV must have these columns (case-insensitive):
   - `temperature` — float (°C)
   - `humidity` — float (%)
   - `location` / `state` / `region` — string (Indian state name)
   - `month` — int (1–12)
   - `label` / `crop` / `crop_name` — string (target crop name)

4. If the Kaggle CSV doesn't have `location` or `month` columns, add them:
   ```python
   import pandas as pd
   import numpy as np
   
   df = pd.read_csv('Crop_recommendation.csv')
   
   # Add location column (random Indian states for training)
   states = ['Maharashtra', 'Karnataka', 'Tamil Nadu', 'West Bengal', 
             'Punjab', 'Kerala', 'Rajasthan', 'Gujarat', 'Andhra Pradesh',
             'Uttar Pradesh', 'Madhya Pradesh', 'Bihar']
   df['location'] = np.random.choice(states, size=len(df))
   
   # Add month column
   df['month'] = np.random.randint(1, 13, size=len(df))
   
   # Rename 'label' to 'crop' if needed
   df = df.rename(columns={'label': 'crop'})
   
   # Keep only needed columns
   df = df[['temperature', 'humidity', 'location', 'month', 'crop']]
   df.to_csv('dataset_ready.csv', index=False)
   ```

### Option B: Use the built-in synthetic dataset
No CSV needed — `train_model.py` generates 15,000 training samples from 15 hydroponic crop profiles.

---

## 2. Train the Model

### Prerequisites
```bash
pip install scikit-learn joblib numpy pandas
```

### Train on synthetic data (default)
```bash
cd ml_backend
python train_model.py
```

### Train on Kaggle CSV
```bash
cd ml_backend
python train_model.py --csv dataset_ready.csv
```

### Train with more samples
```bash
python train_model.py --samples 50000
```

### Output files
- `model.pkl` — trained model + encoders + scaler (~150 MB)
- `label_encoders.pkl` — standalone encoders for reference

---

## 3. Run Backend Locally

```bash
cd ml_backend
pip install -r requirements.txt
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Test endpoints
```bash
# Health check
curl http://localhost:8000/health

# Predict single crop
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"temperature": 25.0, "humidity": 60.0, "location": "West Bengal", "month": 2}'

# Top 5 predictions
curl -X POST "http://localhost:8000/predict/top?n=5" \
  -H "Content-Type: application/json" \
  -d '{"temperature": 25.0, "humidity": 60.0, "location": "West Bengal", "month": 2}'

# Interactive API docs
open http://localhost:8000/docs
```

---

## 4. Deploy Backend on Render

### Step-by-step

1. **Push `ml_backend/` to GitHub** (or a separate repo)

2. **Go to [Render Dashboard](https://dashboard.render.com)**

3. **New → Web Service**
   - **Repository**: your repo
   - **Root Directory**: `ml_backend` (if in a monorepo)
   - **Runtime**: Python 3
   - **Build Command**: `bash render_build.sh`
   - **Start Command**: `gunicorn main:app --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:$PORT --workers 2 --timeout 120`

4. **Environment Variables** (optional):
   - `MODEL_PATH` → `/opt/render/project/src/model.pkl` (default works)

5. **Deploy** — Render will:
   - Install deps from `requirements.txt`
   - Run `train_model.py` (generates model.pkl during build)
   - Start the FastAPI server

6. **Copy the Render URL**, e.g. `https://hydro-ml-xyz.onrender.com`

### Alternative: Deploy with Docker
```bash
cd ml_backend
docker build -t hydro-ml .
docker run -p 8000:8000 hydro-ml
```

---

## 5. Flutter Integration — What Changes Were Made

### New files created:
| File | Purpose |
|------|---------|
| `lib/features/crop_recommendation/services/ml_crop_service.dart` | HTTP client for ML backend |
| `lib/features/crop_recommendation/providers/ml_prediction_provider.dart` | Riverpod state management |

### Modified file:
| File | Change |
|------|--------|
| `lib/features/crop_recommendation/presentation/pages/crop_recommendation_page.dart` | Added AI Prediction card UI |

### How it works:
1. User opens Crop Recommendations page
2. Weather data loads (temperature, humidity, location via Open-Meteo + GPS)
3. User taps **"Get AI Recommendation"** button
4. Flutter sends `POST /predict` to ML backend with:
   ```json
   {
     "temperature": 25.0,
     "humidity": 50.0,
     "location": "West Bengal",
     "month": 2
   }
   ```
5. Backend returns:
   ```json
   {
     "recommended_crop": "Swiss Chard",
     "confidence": 25.6,
     "location_used": "West Bengal",
     "input_summary": { ... }
   }
   ```
6. UI shows the prediction with confidence bar + alternative crops

---

## 6. Manual Changes for Production

### Switch backend URL from local to Render:

In `ml_crop_service.dart`, change:
```dart
// LOCAL (emulator → host)
defaultValue: 'http://10.0.2.2:8000',

// PRODUCTION (Render)
defaultValue: 'https://your-app.onrender.com',
```

Or pass it at build time:
```bash
flutter run --dart-define=ML_BACKEND_URL=https://your-app.onrender.com
```

### For physical Android device (local testing):
Replace `10.0.2.2` with your computer's local IP:
```dart
defaultValue: 'http://192.168.1.XX:8000',
```

---

## Folder Structure

```
ml_backend/
├── main.py              # FastAPI app with /predict endpoint
├── train_model.py       # ML training script (synthetic + CSV)
├── model.pkl            # Trained model (generated)
├── label_encoders.pkl   # Encoders (generated)
├── requirements.txt     # Python dependencies
├── Dockerfile           # Docker deployment
├── Procfile             # Render/Heroku process file
├── render_build.sh      # Render build script
└── ML_DEPLOYMENT_GUIDE.md  # This file
```

---

## API Reference

### `POST /predict`
Single best crop prediction.

**Request:**
```json
{
  "temperature": 25.0,
  "humidity": 60.0,
  "location": "West Bengal",
  "month": 2
}
```

**Response:**
```json
{
  "recommended_crop": "Lettuce",
  "confidence": 35.2,
  "location_used": "West Bengal",
  "input_summary": {
    "temperature": 25.0,
    "humidity": 60.0,
    "location": "West Bengal",
    "month": 2
  }
}
```

### `POST /predict/top?n=5`
Top-N predictions with confidence.

**Response:**
```json
{
  "predictions": [
    {"crop": "Lettuce", "confidence": 35.2},
    {"crop": "Swiss Chard", "confidence": 22.1},
    {"crop": "Bok Choy", "confidence": 15.8}
  ],
  "input_summary": { ... }
}
```

### `GET /health`
```json
{
  "status": "healthy",
  "model_loaded": true,
  "num_crops": 15,
  "num_locations": 22
}
```

### `GET /crops`
```json
{"crops": ["Basil", "Bell Pepper", "Bok Choy", ...]}
```

### `GET /locations`
```json
{"locations": ["Andhra Pradesh", "Assam", "Bihar", ...]}
```
