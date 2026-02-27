# Complete Cloud Deployment Guide - Hydro Smart

## Goal: Make Your App Work Everywhere (Even When PC is Off)

---

## **Phase 1: Deploy Backend to Cloud Run**

### Prerequisites
1. Google Cloud Account (free tier available)
2. Google Cloud CLI installed
3. Your Firebase project already set up

### Step-by-Step Deployment

#### 1. **Install Google Cloud CLI** (if not installed)
```bash
# Windows - using Chocolatey
choco install google-cloud-sdk

# Or download from: https://cloud.google.com/sdk/docs/install
```

#### 2. **Authenticate with Google Cloud**
```bash
# Login
gcloud auth login

# Follow the browser prompt to authorize

# List your projects
gcloud projects list

# Set your Hydro Smart project
gcloud config set project YOUR_PROJECT_ID
```

#### 3. **Navigate to Backend Directory**
```bash
cd c:\Users\Debjit\Music\hydro\hydroponics\hydro_smart\backend
```

#### 4. **Deploy to Cloud Run**
```bash
gcloud run deploy hydro-smart-backend --source . `
  --platform managed `
  --region us-central1 `
  --allow-unauthenticated `
  --set-env-vars FIREBASE_CREDENTIALS=/workspace/firebase-credentials.json

# Wait for deployment to complete...
```

**Important:** Copy the URL from the output. It will look like:
```
Service URL: https://hydro-smart-backend-xxxxx.run.app
```

---

## **Phase 2: Update Flutter App Configuration**

#### 1. **Open API Config File**
Edit: `lib/core/config/api_config.dart`

#### 2. **Replace the URL**
```dart
static const String API_BASE_URL = 
    'https://hydro-smart-backend-xxxxx.run.app/api/v1';
    // ↑ Replace xxxxx with your actual Cloud Run URL
```

Example:
```dart
static const String API_BASE_URL = 
    'https://hydro-smart-backend-abc123xyz.run.app/api/v1';
```

#### 3. **Rebuild Flutter App**
```bash
cd c:\Users\Debjit\Music\hydro\hydroponics\hydro_smart

flutter clean
flutter pub get
flutter run
```

---

## **Phase 3: Verify Everything Works**

### Test 1: Upload PDF
1. Open the app
2. Go to "Crop Recommendation"
3. Upload a PDF file
4. Should see crops extracted ✅

### Test 2: View Crops
1. Go to Crop screen
2. Should load crops from Firestore ✅

### Test 3: AI Chat
1. Go to AI Chat
2. Should respond to questions ✅

### Test 4: Mobile Device
1. Get app URL from Flutter output: `http://192.168.x.x:xxxxx`
2. Open on another device on same WiFi
3. Everything should work! ✅

---

## **What's Now Cloud-Based?**

| Service | Location | Status |
|---------|----------|--------|
| AI Chat (Gemini) | Google Cloud | ✅ Working |
| Database (Firestore) | Google Cloud | ✅ Working |
| Backend API | Cloud Run | ✅ Deployed |
| Flutter App | Your Device | ✅ Connected |

---

## **Key Benefits Now**

✅ **No localhost dependency** - PC can be off  
✅ **Global access** - Use from any device  
✅ **Auto-scaling** - Handles traffic automatically  
✅ **Free tier** - 2 million requests/month  
✅ **Secure** - HTTPS by default  

---

## **Cost Breakdown (Estimated)**

**Free Tier Includes:**
- Cloud Run: 2 million requests/month FREE
- Cloud Storage: 5GB FREE
- Firestore: 50,000 reads/day FREE

**If you exceed free tier:**
- Cloud Run: ~$0.40 per million requests
- Estimated cost for typical usage: **$0-5/month**

---

## **Troubleshooting**

### Issue: "Deployment Failed"
```bash
# Check logs
gcloud run logs read hydro-smart-backend --limit 50

# Check if Dockerfile exists in backend/
ls -la backend/Dockerfile
```

### Issue: "Service not responding after deployment"
- Wait 1-2 minutes for Cloud Run to fully initialize
- Check Firebase credentials are in backend folder
- Verify API_BASE_URL is correct without trailing slash

### Issue: "App says API endpoint not found"
- Make sure `API_BASE_URL` in `api_config.dart` is updated
- Run `flutter clean` and rebuild
- The URL should be: `https://service-name-xxxxx.run.app/api/v1`

### Issue: "PDF upload fails"
- Cloud Run has 32MB request limit (enough for PDFs)
- Ensure firebase-credentials.json exists in backend
- Check that Firestore is accessible from Cloud Run

---

## **Next Steps After Deployment**

1. **Monitor Cloud Run** - Use Cloud Console to view logs
2. **Enable billing** - Optional, for higher usage
3. **Set up CI/CD** - Auto-deploy on code push (optional)
4. **Custom domain** - Use your own domain (optional)

---

## **Quick Reference Commands**

```bash
# View deployment status
gcloud run services list

# View logs
gcloud run logs read hydro-smart-backend --limit 100

# Redeploy latest version
gcloud run deploy hydro-smart-backend --source .

# View service details
gcloud run services describe hydro-smart-backend --region us-central1

# Delete service (if needed)
gcloud run services delete hydro-smart-backend --region us-central1
```

---

## **Security Best Practices**

✅ Never commit API keys to GitHub  
✅ Use Firebase rules for data access  
✅ Enable authentication for production  
✅ Regularly update dependencies  
✅ Monitor Cloud Run logs for errors  

---

**Your app is now ready for production! 🚀**

**Quick test:** Open the app from any device on any network. It should work perfectly! ✨
