# Quick Start: Backend Setup (5 Steps)

## ⚡ TL;DR - Get Backend Running in 5 Minutes

### Step 1: Create Firebase Project (2 min)
```
1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Name: hydro-smart
4. Click "Create project"
5. Wait for it to initialize
```

### Step 2: Download Credentials (1 min)
```
1. Click ⚙️ (Settings) → Service Accounts
2. Click "Generate New Private Key"
3. JSON file downloads
4. Save to: C:\Users\Debjit\Music\hydro\hydroponics\hydro_smart\backend\firebase-credentials.json
```

### Step 3: Install Python Dependencies (2 min)
```powershell
cd C:\Users\Debjit\Music\hydro\hydroponics\hydro_smart\backend
pip install -r requirements.txt
```

### Step 4: Run Backend
```powershell
python app.py

# You should see:
# ✓ Firebase initialized
# ✓ Firestore database connected
# Running on http://127.0.0.1:5000
```

### Step 5: Test It Works ✅
```powershell
# In new PowerShell window
curl http://localhost:5000/api/v1/health

# Should return:
# {"status": "healthy", "version": "2.0.0", "database": "firestore", "database_connected": true}
```

---

## What Now?

### Option A: Upload Sample Crops via PDF
- Create a text file with crop data
- Convert to PDF
- Upload to: `POST http://localhost:5000/api/v1/upload-crop-pdf`

### Option B: Upload via Flutter
- Run Flutter app
- Go to PDF Upload page
- Pick PDF file
- Crops automatically save to Firestore

### Option C: Add Crops Manually
Use your Firestore console:
```
1. Firebase Console → Firestore Database
2. Click "+" next to "crops" collection
3. Add document with fields:
   - name: "Tomato"
   - emoji: "🍅"
   - days_to_harvest: 60
   - yield_per_sqm: 25
   - profit_margin: 65
   - difficulty_level: "beginner"
   - active: true
```

---

## Files You Just Got

| File | Purpose |
|------|---------|
| `database.py` | Firestore database handler |
| `app.py` | Updated with new API endpoints |
| `requirements.txt` | Python dependencies (with firebase-admin) |
| `BACKEND_SETUP.md` | Detailed setup guide |
| `test_api.py` | Test script for all endpoints |
| `.env.example` | Environment variables template |
| `firebase-credentials.json` | **YOU NEED TO ADD THIS** |

---

## New API Endpoints

```
GET  /api/v1/health                    - Check backend status
GET  /api/v1/crops                     - Get all crops
GET  /api/v1/crops/:id                 - Get single crop
GET  /api/v1/crops/search?q=...        - Search crops
POST /api/v1/upload-crop-pdf           - Upload PDF & extract
DELETE /api/v1/crops/:id               - Delete crop
```

---

## Troubleshooting

**"ModuleNotFoundError: firebase_admin"**
→ Run: `pip install firebase-admin==6.2.0`

**"firebase-credentials.json not found"**
→ Download from Firebase Console → Service Accounts

**"Database connection failed"**
→ Check Firestore Rules are published in Firebase Console

**Backend won't start**
→ Check port 5000 is not in use: `netstat -ano | findstr 5000`

---

## Next: Connect Flutter to Backend

Once backend is running with crops in Firestore:

1. Update `crop_repository.dart` to fetch from: `https://hydro-smart-backend.onrender.com/api/v1/crops`
2. Deploy backend to Render (will auto-update from GitHub)
3. Flutter app will fetch live crops from database ✅

---

## Need More Details?

See `BACKEND_SETUP.md` for:
- Full setup instructions with screenshots
- Complete API documentation
- Advanced configuration
- Production deployment tips
