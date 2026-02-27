# Firebase Console Setup - Crops Database

## You Already Have: ✅
- Firebase Project created
- Authentication working (login)

## Now Add: 📦
- **Firestore Database** (for storing crops)
- **Service Account** (for backend to access database)

---

## STEP 1: Create Firestore Database

### In Firebase Console:

1. **Open Firebase Console**
   - Go to: https://console.firebase.google.com
   - Select your project (the one with login working)

2. **Navigate to Firestore**
   - Left menu → **"Build"** section
   - Click **"Firestore Database"**

3. **Create Database**
   - Click blue button: **"Create Database"**

4. **Choose Location**
   - Select region: **asia-southeast1** (Singapore - closest to India)
   - Click **"Next"**

5. **Choose Security Rules**
   - Select: **"Production mode"** (you'll set rules next)
   - Click **"Create"**

⏳ **Wait 1-2 minutes** for database to initialize...

---

## STEP 2: Set Up Security Rules

Once Firestore is ready:

1. Go to **"Firestore Database"** → **"Rules"** tab

2. **Replace ALL content** with this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Allow everyone to read crops
    match /crops/{document=**} {
      allow read: if true;
      allow write: if false;  // Block public writes
    }
    
    // Allow everyone to read users (basic info)
    match /users/{document=**} {
      allow read: if true;
      allow write: if request.auth.uid == document;
    }
    
    // Default: deny all
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

3. Click **"Publish"** button (blue)

✅ Now your rules are live!

---

## STEP 3: Create Crops Collection (Manual)

### Option A: Add Crops Manually in Firebase Console (Recommended for testing)

1. Go to **"Firestore Database"** → **"Data"** tab

2. Click **"Start collection"**

3. **Collection name:** `crops` (exactly)

4. **Add first document:**
   - Click **"Auto ID"** (to generate random ID)
   - Add these fields:

| Field | Type | Value |
|-------|------|-------|
| `name` | String | `Cherry Tomato` |
| `emoji` | String | `🍅` |
| `days_to_harvest` | Number | `60` |
| `yield_per_sqm` | Number | `25` |
| `profit_margin` | Number | `65` |
| `difficulty_level` | String | `beginner` |
| `temperature_range` | Map | `{min: 15, max: 28, optimal: 22}` |
| `ph_range` | Map | `{min: 6.0, max: 6.8, optimal: 6.5}` |
| `active` | Boolean | `true` |
| `created_at` | Timestamp | (current time) |

5. Click **"Save"**

✅ Now you have 1 crop in database!

### Option B: Add More Crops (Repeat Step 4-5 for each):

**Butterhead Lettuce:**
- name: `Butterhead Lettuce`
- emoji: `🥬`
- days_to_harvest: `45`
- yield_per_sqm: `18`
- profit_margin: `55`
- difficulty_level: `beginner`

**Spinach:**
- name: `Spinach`
- emoji: `🥬`
- days_to_harvest: `40`
- yield_per_sqm: `20`
- profit_margin: `60`
- difficulty_level: `beginner`

**Bell Pepper:**
- name: `Bell Pepper`
- emoji: `🌶️`
- days_to_harvest: `90`
- yield_per_sqm: `20`
- profit_margin: `70`
- difficulty_level: `intermediate`

---

## STEP 4: Download Service Account (For Backend)

This allows your **Python backend** to read/write crops to database.

### Get the JSON Credentials:

1. Click **⚙️ (Settings)** → Top right corner

2. Select **"Project Settings"**

3. Click **"Service Accounts"** tab

4. Click **"Python"** (or Node.js if you prefer)

5. Click blue button: **"Generate New Private Key"**

6. **JSON file downloads automatically** ✅
   - Save with this exact name: `firebase-credentials.json`
   - Put in: `C:\Users\Debjit\Music\hydro\hydroponics\hydro_smart\backend\`

### The file looks like:
```json
{
  "type": "service_account",
  "project_id": "hydro-smart-xxxxx",
  "private_key_id": "...",
  "private_key": "...",
  "client_email": "firebase-adminsdk-...",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  ...
}
```

⚠️ **IMPORTANT:**
- Keep this file **SECRET** (never commit to GitHub)
- Add to `.gitignore`:
  ```
  backend/firebase-credentials.json
  backend/.env
  ```

---

## STEP 5: Verify Your Setup

### In Firebase Console:

1. **Firestore Database exists?** ✅
   - Menu → Build → Firestore Database
   - You should see your crops data

2. **Rules published?** ✅
   - Firestore Database → Rules tab
   - Status shows "Deploy successful"

3. **Service Account JSON downloaded?** ✅
   - File: `backend/firebase-credentials.json` exists
   - Contains project details

---

## Next: Install Backend & Test

Once you have done above, run these commands:

```powershell
# Navigate to backend
cd C:\Users\Debjit\Music\hydro\hydroponics\hydro_smart\backend

# Install Python dependencies
pip install -r requirements.txt

# Run backend
python app.py

# You should see:
# ✓ Firebase initialized with credentials from firebase-credentials.json
# ✓ Firestore database connected
# Running on http://127.0.0.1:5000
```

---

## Test Backend API

```powershell
# In new PowerShell window
# Test 1: Health check
curl http://localhost:5000/api/v1/health

# Test 2: Get all crops
curl http://localhost:5000/api/v1/crops

# Should return your crops data!
```

---

## Summary: What You Did in Firebase Console

| ✅ Done | What | Where |
|--------|------|-------|
| ✅ | Created Firestore Database | Build → Firestore Database → Create |
| ✅ | Set Security Rules | Firestore Database → Rules → Publish |
| ✅ | Created "crops" Collection | Firestore Database → Data → Start collection |
| ✅ | Added Sample Crops | Firestore Database → Data → Add documents |
| ✅ | Downloaded Service Account JSON | Project Settings → Service Accounts → Generate Key |

---

## Troubleshooting in Firebase Console

**Problem:** "Firestore Database" option not visible
- **Solution:** Go to Project Settings → Verify project is correctly selected

**Problem:** Can't publish rules
- **Solution:** Check syntax - look for red error messages below rule editor

**Problem:** Service Accounts tab missing
- **Solution:** Go to ⚙️ → "Project Settings" (not your user settings)

**Problem:** Can't create new collection
- **Solution:** Make sure Firestore Database is created first (you did this in Step 1)

---

## Your Database Structure

```
Firestore Database
└── crops (Collection)
    ├── doc_001 (Document - Cherry Tomato)
    │   ├── name: "Cherry Tomato"
    │   ├── emoji: "🍅"
    │   ├── days_to_harvest: 60
    │   ├── yield_per_sqm: 25
    │   ├── profit_margin: 65
    │   ├── difficulty_level: "beginner"
    │   └── active: true
    ├── doc_002 (Document - Butterhead Lettuce)
    │   └── ...
    └── doc_003 (Document - Spinach)
        └── ...
```

---

## Quick Reference

| Step | Location | Action |
|------|----------|--------|
| 1️⃣  | https://console.firebase.google.com | Create Firestore Database |
| 2️⃣  | Firestore → Rules | Set security rules |
| 3️⃣  | Firestore → Data | Create "crops" collection |
| 4️⃣  | Firestore → Data | Add crop documents |
| 5️⃣  | Project Settings → Service Accounts | Download JSON key |

---

That's it! Your database is ready for the backend to use. 🚀
