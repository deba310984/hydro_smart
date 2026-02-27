# Backend Database Setup Guide - Hydro Smart

## Overview

Your backend now supports **Firestore** (Google's cloud database) for storing crops. This guide shows you how to:

1. ✅ Set up Firebase Firestore
2. ✅ Download credentials
3. ✅ Install Python packages
4. ✅ Run the backend
5. ✅ Test the API endpoints

---

## Step 1: Create a Firebase Project

### Option A: Use Existing Google Account (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"**
3. Enter project name: `hydro-smart`
4. Click **"Create project"**
5. Wait for project to initialize (takes ~1-2 minutes)

### Option B: Using Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create new project: `hydro-smart`
3. Go to **Firestore Database**
4. Click **"Create Database"**
5. Select region: **asia-southeast1** (Singapore) - closest to you
6. Start in **Production mode**
7. Click **"Create"**

---

## Step 2: Create Service Account & Download Credentials

### Get Firebase Admin Credentials:

1. In Firebase Console, go to **Project Settings** (⚙️ icon)
2. Click **"Service Accounts"** tab
3. Click **"Generate New Private Key"**
4. A JSON file downloads automatically → **SAVE THIS FILE**

### Move Credentials to Backend:

```powershell
# On your Windows (PowerShell)
# Copy the downloaded JSON file to your backend folder:

Copy-Item "C:\Path\To\Downloaded\firebase-credentials.json" `
  "C:\Users\Debjit\Music\hydro\hydroponics\hydro_smart\backend\firebase-credentials.json"
```

**The file should look like:**
```json
{
  "type": "service_account",
  "project_id": "hydro-smart-xxxxx",
  "private_key_id": "...",
  "private_key": "...",
  "client_email": "firebase-adminsdk-...",
  ...
}
```

---

## Step 3: Set Up Firestore Database Access Rules

### Create Basic Security Rules:

1. In Firebase Console, go to **Firestore Database**
2. Click **"Rules"** tab
3. Replace all content with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write for all documents in crops collection
    match /crops/{document=**} {
      allow read: if true;
      allow write: if true;  // For development only
    }
    
    // Add other rules here
  }
}
```

4. Click **"Publish"**

⚠️ **Note:** These are development rules. For production, use proper authentication.

---

## Step 4: Install Python Dependencies

```powershell
# Navigate to backend
cd C:\Users\Debjit\Music\hydro\hydroponics\hydro_smart\backend

# Install packages
pip install -r requirements.txt

# Output should show:
# ✓ Flask==3.0.0
# ✓ gunicorn==21.2.0
# ✓ pdfplumber==0.9.0
# ✓ firebase-admin==6.2.0  <-- NEW
# ✓ python-dotenv==1.0.0
# ✓ requests==2.31.0
```

---

## Step 5: Run the Backend

```powershell
# From backend folder
python app.py

# You should see:
# ✓ Firebase initialized with credentials from firebase-credentials.json
# ✓ Firestore database connected
# WARNING: This is a development server. (Flask message)
# Running on http://127.0.0.1:5000
```

---

## Step 6: Test the Backend API

### Test 1: Health Check
```powershell
# PowerShell
Invoke-WebRequest http://localhost:5000/api/v1/health -Method GET

# Response:
# {
#   "status": "healthy",
#   "version": "2.0.0",
#   "database": "firestore",
#   "database_connected": true
# }
```

### Test 2: Get All Crops
```powershell
Invoke-WebRequest http://localhost:5000/api/v1/crops -Method GET

# Response (empty at first):
# {
#   "success": true,
#   "crops": [],
#   "total": 0
# }
```

### Test 3: Upload PDF (Extract & Save Crops)
```powershell
# If you have a crop PDF, test by:
$file = Get-Item "C:\path\to\crops.pdf"
$form = @{ file = $file }

Invoke-WebRequest -Uri "http://localhost:5000/api/v1/upload-crop-pdf" `
  -Method POST `
  -Form $form

# Response:
# {
#   "success": true,
#   "message": "Extracted and saved 3 crops",
#   "saved_crop_ids": ["doc1", "doc2", "doc3"],
#   "crops": [...]
# }
```

---

## Step 7: Update Flutter to Fetch from Backend

Once backend is running, update your Flutter app to fetch from the new API:

### File: `lib/features/crop_recommendation/data/repositories/crop_repository.dart`

Change the `getAllCrops()` method to:

```dart
Future<List<Crop>> getAllCrops() async {
  try {
    final response = await http.get(
      Uri.parse('https://hydro-smart-backend.onrender.com/api/v1/crops'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final cropsList = (jsonData['crops'] as List)
          .map((crop) => _mapFirestoreCropToModel(crop))
          .toList();
      return cropsList;
    } else {
      throw Exception('Failed to load crops');
    }
  } catch (e) {
    print('Error fetching crops: $e');
    return [];
  }
}

Crop _mapFirestoreCropToModel(Map<String, dynamic> data) {
  return Crop(
    id: data['id'] ?? 'unknown',
    cropName: data['name'] ?? 'Unknown Crop',
    // Map rest of fields...
  );
}
```

---

## Complete API Endpoints

### GET /api/v1/health
Health check with database status
```bash
curl http://localhost:5000/api/v1/health
```

### GET /api/v1/crops
Get all active crops
```bash
curl http://localhost:5000/api/v1/crops
```

### GET /api/v1/crops?q=tomato&difficulty=beginner
Search crops by name and difficulty
```bash
curl "http://localhost:5000/api/v1/crops/search?q=tomato&difficulty=beginner"
```

### GET /api/v1/crops/:crop_id
Get single crop by ID
```bash
curl http://localhost:5000/api/v1/crops/doc123
```

### POST /api/v1/upload-crop-pdf
Upload PDF and extract crops
```bash
curl -X POST -F "file=@crops.pdf" http://localhost:5000/api/v1/upload-crop-pdf
```

### DELETE /api/v1/crops/:crop_id
Delete crop (soft delete)
```bash
curl -X DELETE http://localhost:5000/api/v1/crops/doc123
```

---

## Troubleshooting

### Error: "Firebase credentials file not found"
- ✅ Check `firebase-credentials.json` is in backend folder
- ✅ Run from backend directory: `cd backend`
- ✅ Set environment: `$env:FIREBASE_CREDENTIALS = "firebase-credentials.json"`

### Error: "Permission denied" in Firestore
- ✅ Check Firestore Rules are published
- ✅ Make sure credentials are for same project

### Error: "ModuleNotFoundError: No module named 'firebase_admin'"
```powershell
pip install firebase-admin==6.2.0
pip show firebase-admin  # Verify installation
```

### Backend running but Flutter can't connect
- ✅ Check: http://localhost:5000/api/v1/health in browser
- ✅ Update Flutter code with correct backend URL
- ✅ Allow network access in firewall if needed

---

## Next Steps

1. ✅ Download Firebase credentials JSON
2. ✅ Save to `backend/firebase-credentials.json`
3. ✅ Run: `pip install -r requirements.txt`
4. ✅ Run: `python app.py`
5. ✅ Test health: `Invoke-WebRequest http://localhost:5000/api/v1/health`
6. ✅ Upload test PDF to save crops
7. ✅ Update Flutter repository to fetch from API
8. ✅ Push to GitHub (Render will auto-deploy)

---

## File Structure After Setup

```
hydro_smart/backend/
├── app.py                          ✅ Updated with new endpoints
├── database.py                     ✅ NEW Firestore handler
├── pdf_extractor.py               ✅ Existing PDF extraction
├── requirements.txt               ✅ Updated with firebase-admin
├── firebase-credentials.json      ✅ ADD THIS (from Firebase)
└── uploads/                       ✅ Auto-created for PDFs
```

---

## Architecture Overview

```
[Flutter App]
    ↓
    ↓ HTTP Requests
    ↓
[Flask Backend (app.py)]
    ↓ ↓ ↓
[Database Handler] → [Firestore Database]
    ↓ ↓ ↓
[PDF Extractor]
```

---

Questions? Check:
- Firebase Console: https://console.firebase.google.com
- Backend logs: `python app.py` (see console output)
- Firestore Rules: Database → Rules tab
- Service Account: Project Settings → Service Accounts

