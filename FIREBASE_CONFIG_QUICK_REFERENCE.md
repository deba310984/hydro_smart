# Firebase RAG Configuration - Quick Reference

## 🎯 Quick Setup Checklist

```
☐ STEP 1: Get Gemini API Key from makersuite.google.com/app/apikey
☐ STEP 2: Enable Generative Language API in Google Cloud Console  
☐ STEP 3: Create config/gemini_config document in Firestore with apiKey field
☐ STEP 4: Update Firestore Security Rules (copy-paste below)
☐ STEP 5: Run app - knowledge base auto-initializes
☐ STEP 6: Test with AI Assistant - try sample queries
☐ STEP 7: Monitor usage in Google Cloud Console
```

---

## 📋 Firestore Configuration Details

### Collection & Document Structure

```
firestore/
├── config/
│   └── gemini_config
│       └── Fields:
│           ├── apiKey (string): "sk-proj-xxxxx..." 
│           ├── status (string): "active"
│           ├── model (string): "gemini-1.5-flash"
│           ├── createdAt (timestamp): <auto-set>
│           └── updatedAt (timestamp): <auto-set>
│
└── ai_knowledge_base/
    └── Auto-created documents (6 total):
        ├── Nutrient Management
        ├── Temperature & Humidity
        ├── Pest & Disease Management
        ├── Cost & Profitability
        ├── Crop Selection & Cycles
        └── System Types & Equipment
```

### Exact Field Format for config/gemini_config

```json
{
  "apiKey": "YOUR_ACTUAL_API_KEY_STRING",
  "status": "active",
  "model": "gemini-1.5-flash",
  "createdAt": "2026-02-21T10:30:00Z",
  "updatedAt": "2026-02-21T10:30:00Z"
}
```

---

## 🔐 Copy-Paste Firestore Security Rules

Go to **Firestore → Rules** and paste this exactly:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read knowledge base
    match /ai_knowledge_base/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // Allow authenticated users to read config
    match /config/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // Default: deny all unless explicitly allowed above
    match /{document=**} {
      allow read: if false;
      allow write: if false;
    }
  }
}
```

---

## 🔧 Verification Checklist

After setup, verify each component:

### 1️⃣ Verify Gemini API Key Works
```bash
curl -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Hi, how are you?"
      }]
    }]
  }'
```

Expected: JSON response with generated text (not error)

### 2️⃣ Verify Firestore Collection Exists
- Open Firebase Console
- Go to Firestore
- You should see `config` collection
- You should see `gemini_config` document
- Click it and verify `apiKey` field is populated

### 3️⃣ Verify Firestore Rules Applied
- Firebase Console → Firestore → Rules
- Paste the rules above
- Click "Publish"
- You should see green checkmark ✅

### 4️⃣ Test App Startup
```bash
flutter clean
flutter pub get
flutter run
```

Watch for:
- ✅ No errors in console
- ✅ App loads normally
- ✅ Can navigate to AI Chat section
- ✅ Shows "Welcome" or greeting message

### 5️⃣ Test First Query
1. In AI Chat, type a question
2. Watch console for:
   - Request sent to Gemini
   - Firestore reads happening
   - Response streaming back

---

## 🚀 Common Configuration Issues & Fixes

### Issue: API Key Not Found in Firebase
**Error Message**: "No document found at config/gemini_config"
**Fix**: 
1. Go to Firebase Console → Firestore
2. Manually create collection `config`
3. Manually create document `gemini_config`
4. Add field `apiKey` with your API key string

### Issue: "Invalid API Key" Error
**Error Message**: "API key not valid. Please pass a valid API key"
**Fix**:
1. Go to makersuite.google.com/app/apikey
2. Generate a NEW API key
3. Update the key in Firestore `config/gemini_config`
4. Restart the app

### Issue: CORS/Origin Error
**Error Message**: "CORS error" or "Origin is not allowed"
**Fix**: This shouldn't happen with Flutter. Check:
1. Internet connection working
2. Firestore rules allow read of config and knowledge_base
3. API key has correct permissions in Google Cloud

### Issue: Rate Limit Exceeded
**Error Message**: "RESOURCE_EXHAUSTED" or "429 Too Many Requests"
**Fix**:
1. Free tier: 60 requests/minute
2. Wait a minute and try again
3. Or upgrade to paid plan

---

## 📊 Cloud Functions Setup (Advanced)

For extra security, you can hide the API key in Cloud Functions:

### Deploy Function
1. Go to Firebase Console → Functions
2. Click "Create Function"
3. Copy this code:

```javascript
const functions = require('firebase-functions');
const { GoogleGenerativeAI } = require('@google/generative-ai');

exports.streamAiResponse = functions.https.onCall(async (data, context) => {
  // Verify user authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be authenticated'
    );
  }

  try {
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
    
    const result = await model.generateContent(data.prompt);
    const response = await result.response;
    
    return {
      success: true,
      text: response.text()
    };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});
```

4. Set environment variable:
   - Click "Runtime settings"
   - Add `GEMINI_API_KEY` = your API key
5. Deploy

### Update Flutter Code
```dart
final response = await FirebaseFunctions.instance
  .httpsCallable('streamAiResponse')
  .call({'prompt': userMessage});
  
print(response.data['text']);
```

---

## 🧪 Test Queries for Knowledge Base

Once setup is complete, test these queries to verify RAG system:

### Nutrient Management Test
**Query**: "What should the EC level be for lettuce?"
**Expected**: Response mentions "1.2-1.5 dS/m" from knowledge base

### Temperature Test
**Query**: "How do I prevent mold in my hydroponic system?"
**Expected**: Response mentions "humidity below 70%", "ventilation", "sterilization"

### Cost Test  
**Query**: "How much profit can I make with hydroponics?"
**Expected**: Response mentions specific ₹ amounts, monthly costs

### Crop Test
**Query**: "What crops are best for beginners?"
**Expected**: Response mentions "lettuce", "herbs", "microgreens" with yields

### System Test
**Query**: "What's the difference between DFT and NFT?"
**Expected**: Response explains both systems with costs and benefits

---

## 📈 Monitoring & Usage

### View Gemini API Usage
1. Google Cloud Console → APIs & Services → Library
2. Search "Generative Language API"
3. Click it → Click "Metrics"
4. View requests, errors, latency

### View Firestore Usage
1. Firebase Console → Firestore → Usage
2. See reads (knowledge base queries)
3. See writes (knowledge base initialization)
4. Storage used by documents

### Expected Metrics
- **Per query**: 1 Firestore read (knowledge base) + 1 API request (Gemini)
- **Cost per query**: ~₹0.01 for Gemini + minimal Firestore
- **Typical response time**: 2-5 seconds

---

## 🎯 Knowledge Base Management

### Add Your Own Documents
To customize knowledge base, add documents to `ai_knowledge_base` collection:

```json
{
  "title": "Your Topic",
  "content": "Detailed content here...",
  "keywords": ["keyword1", "keyword2", "keyword3"],
  "createdAt": "2026-02-21T10:30:00Z",
  "updatedAt": "2026-02-21T10:30:00Z"
}
```

### Update Existing Documents
1. Firebase Console → Firestore
2. Go to `ai_knowledge_base` collection
3. Click any document
4. Click the edit icon
5. Update "content" field
6. Save

---

## 🆘 Getting Help

### Check Firebase Connections
```dart
// In Flutter/Dart console during debugging:
print('Auth status: ${FirebaseAuth.instance.currentUser}');
print('Firestore instance: ${FirebaseFirestore.instance}');
```

### View App Logs
```bash
flutter logs
```

### Check Firestore Activity
- Firebase Console → Firestore → Logs
- Filter by collection name
- See all reads/writes in realtime

---

## 📝 Credentials Checklist

Before going live, ensure:

```
☐ Gemini API Key safely stored in Firestore (not in code)
☐ API Key restricted to Generative Language API only
☐ Firestore rules prevent unauthorized access
☐ Knowledge base documents are complete and accurate  
☐ App tested with sample queries
☐ Rate limits understood (60 requests/min free tier)
☐ Error handling implemented for failures
☐ Monitoring setup in Google Cloud Console
☐ Crisis plan if API quota exceeded
```

---

## ✅ Status

**Configuration Status**: ✅ READY  
**Code Status**: ✅ COMPLETE  
**Testing Status**: 🟡 PENDING (awaiting Firebase setup)  
**Deployment Status**: 🟡 READY (after Firebase config)  

**Next Action Required**: Follow the 7-step setup guide to configure Firebase!
