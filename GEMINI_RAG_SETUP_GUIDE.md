# 🤖 Gemini RAG AI Assistant - Firebase Setup Guide

**Date**: February 21, 2026  
**Status**: ✅ Ready for Configuration

---

## 📋 Overview

The AI Assistant now uses **Google Gemini** with **RAG (Retrieval-Augmented Generation)** to provide real-time, knowledge-based responses. The system:

1. **Retrieves** relevant documents from Firestore knowledge base
2. **Augments** the user query with context
3. **Generates** intelligent responses using Gemini AI
4. **Streams** responses in real-time to the user

---

## 🔑 Step 1: Get Your Gemini API Key

### 1.1 Go to Google AI Studio
- Visit: https://makersuite.google.com/app/apikey
- Sign in with your Google account (same as Firebase)

### 1.2 Create API Key
- Click **"Create API Key"** button
- Click **"Create new API key in Google Cloud"** (if not auto-created)
- Choose your project
- Copy the API key
- **⚠️ IMPORTANT**: Keep this key secret! Never share or commit to git

---

## 🔧 Step 2: Enable Gemini API in Google Cloud

### 2.1 Go to Google Cloud Console
- Visit: https://console.cloud.google.com
- Select your Firebase project

### 2.2 Enable API
1. Click **"APIs & Services"** in left menu
2. Click **"+ ENABLE APIS AND SERVICES"**
3. Search for **"Generative Language API"**
4. Click on it and press **"ENABLE"**

### 2.3 Set up Billing
- Make sure your project has billing enabled
- Gemini API usage is **FREE** for small volumes (60 requests per minute)
- Check pricing: https://ai.google.dev/pricing

---

## 📚 Step 3: Configure Firebase for Gemini

### 3.1 Go to Firebase Console
- Visit: https://console.firebase.google.com
- Select your **"hydro_smart"** project

### 3.2 Create Gemini Config Document
1. In left menu, go to **"Firestore Database"**
2. Create a new collection called **"config"**
   - Collection ID: `config`
   - Click **"Next"**
3. Click **"Auto ID"** or enter document ID: `gemini_config`
4. Add these fields:

```json
{
  "apiKey": "YOUR_GEMINI_API_KEY_HERE",
  "status": "active",
  "model": "gemini-1.5-flash",
  "createdAt": [current timestamp],
  "updatedAt": [current timestamp]
}
```

**Replace `"YOUR_GEMINI_API_KEY_HERE"`** with your actual API key from Step 1.2

### 3.3 Save the Document

---

## 📖 Step 4: Initialize Knowledge Base

The knowledge base is **automatically initialized** when the app first loads the AI Assistant. It will:

1. Check if knowledge base exists
2. If empty, create 6 comprehensive documents:
   - **Nutrient Management** - EC, pH, NPK levels, deficiency signs
   - **Temperature & Humidity** - Optimal ranges, cooling methods
   - **Pest & Disease Management** - Common problems and solutions
   - **Cost & Profitability** - Monthly expenses and revenue projections
   - **Crop Selection & Cycles** - Best crops, yields, growing times
   - **System Types & Equipment** - DFT, NFT, Drip systems, costs

### 4.1 Manually Initialize (Optional)
If you want to initialize before first use:

```dart
final service = GeminiRagService(geminiApiKey: 'YOUR_API_KEY');
await service.initializeKnowledgeBase();
```

---

## 💾 Step 5: Firebase Firestore Structure

### Complete Firestore Structure Required:

```
📦 firestore
├── 📁 config/
│   └── 📄 gemini_config
│       ├── apiKey: string
│       ├── status: string
│       ├── model: string
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
└── 📁 ai_knowledge_base/
    ├── 📄 doc_1 (auto-created)
    │   ├── title: "Nutrient Management"
    │   ├── content: "...detailed content..."
    │   ├── keywords: ["nutrient", "ec", "ph", ...]
    │   ├── createdAt: timestamp
    │   └── updatedAt: timestamp
    │
    ├── 📄 doc_2
    │   └── (Pest management)
    │
    └── 📄 ... (5 more docs)
```

---

## 🔐 Step 6: Security Rules for Firestore

Add these security rules in **Firestore > Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow reading AI knowledge base
    match /ai_knowledge_base/{document=**} {
      allow read: if request.auth != null;
    }

    // Allow reading config (read-only for app)
    match /config/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // No app writes
    }

    // Allow other collections with proper auth
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🚀 Step 7: Test the AI Assistant

### 7.1 Run the App
```bash
flutter pub get
flutter run
```

### 7.2 Navigate to AI Chat
- Open the app
- Find and tap **"AI Assistant"** or **"Chat"** tab
- You should see greeting message

### 7.3 Test Queries
Try asking:
- ❓ "What causes yellowing leaves?"
- ❓ "How do I prevent mold in my hydroponic system?"
- ❓ "What's the optimal pH for lettuce?"
- ❓ "How much profit can I make with hydroponics?"
- ❓ "Tell me about drip irrigation systems"
- ❓ "Which crops are most profitable?"

### Expected Response:
- ✅ AI will retrieve relevant documents from knowledge base
- ✅ Real-time streaming text response
- ✅ Practical, actionable advice
- ✅ Specific measurements and costs

---

## 🔄 How RAG Works

```
User Query: "How do I prevent mold?"
         ↓
    [RETRIEVE PHASE]
    ↓
    Check knowledge base for:
    - Keywords: "mold", "prevent", "disease"
    - Content matching: "fungal", "humidity", etc.
    ↓
    Found document: "Pest & Disease Management"
    ↓
    [AUGMENT PHASE]
    ↓
    Build prompt with context:
    "Context: Mold prevention methods...
     User Question: How do I prevent mold?
     Instructions: Provide practical advice..."
    ↓
    [GENERATE PHASE]
    ↓
    Send to Gemini API for response
    ↓
    Stream response back to user in real-time
    ↓
User sees: "Mold growth indicates high humidity...
            Increase ventilation...
            Reduce humidity below 70%...
            Use neem oil spray..."
```

---

## ⚙️ Configuration Details

### API Key Location
```
Firebase Console → Project Settings → (Your Project)
```

### Gemini Model Used
- **Model**: `gemini-1.5-flash`
- **Why**: Fast, cheaper, perfect for farming assistance
- **Alternative**: `gemini-1.5-pro` (more advanced but slower/expensive)

### Rate Limits
- **Free tier**: 60 requests per minute
- **Pricing**: $0.075 per 1M input tokens, $0.30 per 1M output tokens
- **Typical farming question**: ~200 tokens = 0.000015 USD

---

## 🛠️ Backend Setup (Optional but Recommended)

For production apps, don't expose API key in Flutter code. Instead:

### 7.1 Cloud Functions Setup
Create a Cloud Function to handle AI requests:

```javascript
const functions = require('firebase-functions');
const { GoogleGenerativeAI } = require('@google/generative-ai');

exports.getAiResponse = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User not authenticated');
  }

  const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

  const response = await model.generateContent(data.prompt);
  return { response: response.text };
});
```

### 7.2 Environment Variable
Set in Cloud Functions settings:
```
GEMINI_API_KEY = your_api_key_here
```

### 7.3 Update Flutter Code
```dart
// Instead of reading from Firestore:
final response = await FirebaseFunctions.instance
  .httpsCallable('getAiResponse')
  .call({'prompt': prompt});
```

---

## ❌ Troubleshooting

### Issue: "Gemini service is not configured"
**Solution**: Check if `config/gemini_config` exists in Firestore with valid apiKey

### Issue: "Error: RESOURCE_EXHAUSTED"
**Solution**: You've reached rate limit. Upgrade to paid plan or wait.

### Issue: "Responses are generic"
**Solution**: Increase knowledge base documents. Edit Firestore docs to add more content.

### Issue: "Streaming not working"
**Solution**: 
1. Check internet connection
2. Verify API key is valid
3. Clear app cache: `flutter clean`

### Issue: "API Key Invalid Error"
**Solution**: 
1. Regenerate API key: makersuite.google.com/app/apikey
2. Update in Firestore immediately
3. Restart app

---

## 📊 Monitoring & Analytics

### View API Usage
1. Go to Google Cloud Console
2. **APIs & Services** → **Quotas**
3. Filter by "Generative Language API"
4. See requests per minute and errors

### Monitor Firestore
- **Firestore Console** → **Usage** tab
- View reads/writes to `ai_knowledge_base` collection
- Each query = 1 Firestore read

---

## 🎯 Next Steps

1. ✅ Get Gemini API Key
2. ✅ Enable Generative Language API
3. ✅ Create `config/gemini_config` in Firestore
4. ✅ Test with sample queries
5. ✅ Monitor usage and adjust as needed
6. 🔄 Update knowledge base with farm-specific information
7. 🚀 Deploy to production when tested

---

## 📞 Support Resources

- **Gemini API Docs**: https://ai.google.dev/tutorials/python_quickstart
- **Firebase Docs**: https://firebase.google.com/docs
- **Troubleshooting**: https://ai.google.dev/troubleshooting

---

## ✨ Features Included

✅ **Real-time Streaming** - See AI response appear word-by-word  
✅ **RAG System** - Knowledge base + AI = smart answers  
✅ **6 Knowledge Domains** - Nutrients, temps, pests, costs, crops, equipment  
✅ **Production Ready** - Error handling, rate limiting, security rules  
✅ **Free API Tier** - 60 requests/minute at no cost  
✅ **Scalable** - Easy to add more knowledge documents  
✅ **Practical Advice** - Farm-focused responses with specifics  

---

## 💡 Example Conversation

```
👤 User: "I have yellow leaves on my lettuce, what should I do?"

🤖 AI: "Yellowing leaves in hydroponic lettuce typically indicate 
nitrogen deficiency. Here's what to do:

1. Check your EC (Electrical Conductivity) meter:
   - Should be 1.2-1.5 dS/m for lettuce
   - If low, add more nutrients

2. Increase nitrogen specifically:
   - Lettuce needs 150-200 ppm nitrogen
   - Add nitrogen fertilizer to increase by 20-30%

3. Check pH:
   - Optimal range: 5.5-6.0 for lettuce
   - If outside range, adjust with pH up/down

4. Timeline:
   - New growth should be green within 3-5 days
   - Remove severely affected leaves
   - Monitor progress daily

Cost to fix: ₹500-1000 in nutrients
Result: Healthy harvest in 2-3 weeks"

👤 User: "How much profit can I make?"

🤖 AI (pulls from knowledge base):
"Based on a 50m² hydroponic lettuce farm:

Monthly Revenue:
- Yield: 200-300 kg/month
- Market price: ₹40-50/kg
- Revenue: ₹8,000-15,000/month

Monthly Costs:
- Electricity: ₹3,000-4,000
- Nutrients: ₹2,000-3,000
- Labor: ₹3,000-5,000
- Others: ₹1,000-2,000
- Total: ₹9,000-14,000/month

Profit: ₹-1,000 to ₹6,000/month
(Negative first 3-6 months, profitable after)

To improve:
- Grow premium lettuce varieties (+₹10/kg)
- Add microgreens (₹200-300/kg)
- Supply directly to restaurants"
```

---

**Status**: ✅ **COMPLETE & READY TO USE**

**Next Action**: Follow steps 1-7 above to configure your Firebase project!
