# Gemini RAG AI Assistant - Troubleshooting & Support Guide

## 🆘 Common Issues & Solutions

### Issue 1: "Gemini service is not configured"

**When It Happens**: App shows error message instead of starting AI assistant

**Root Cause**: Firebase `config/gemini_config` doesn't exist or apiKey field is missing

**Fix Steps**:
1. Open Firebase Console → https://console.firebase.google.com
2. Select your HydroSmart project
3. Go to **Firestore Database**
4. Click **Create Collection**
   - Name: `config`
   - Click **Next**
5. Click **Auto ID** to create first document
6. Add these fields:
   ```
   apiKey = "your-gemini-api-key" (string)
   status = "active" (string)
   model = "gemini-1.5-flash" (string)
   ```
7. Click **Save**
8. Close and reopen the app

**Verify**: Go back to app. Error should be gone.

---

### Issue 2: "API key not valid. Please pass a valid API key"

**When It Happens**: Error when trying to send a message to AI

**Root Cause**: API key is invalid, expired, or not enabled

**Fix Steps**:

#### Option A: Regenerate API Key
1. Go to: https://makersuite.google.com/app/apikey
2. Click on your API key
3. If you see "Delete" option, click it
4. Click **Create API Key**
5. Choose **Create new API key in Google Cloud**
6. Select your project
7. Copy the NEW key
8. Update in Firestore: `config/gemini_config/apiKey`
9. Restart the app

#### Option B: Check API Key in Google Cloud
1. Go to: https://console.cloud.google.com
2. Search **"Generative Language API"** in search bar
3. Click on it
4. Click **ENABLE**
5. Wait for it to enable (orange loading bar)
6. The API is now active for your API key

**Verify**: Try sending a message again

---

### Issue 3: "Collection not found: ai_knowledge_base"

**When It Happens**: Error when trying to get AI response

**Root Cause**: Knowledge base was deleted or never initialized

**Fix Steps**:
1. The app should **auto-create** the knowledge base on first run
2. If not, manually do this in Firebase:
3. Go to **Firestore Database**
4. Click **Create Collection**
   - Name: `ai_knowledge_base`
   - Click **Next**
5. Click **Auto ID** 
6. Paste this document:
```json
{
  "title": "Nutrient Management",
  "content": "EC Level Management:\n- Optimal EC: 1.2-1.5 dS/m for lettuce\n- NPK Ratio: 14:7:14 for vegetative growth\n\nPH Management:\n- Optimal pH: 5.5-6.5 for most crops\n- Check daily with calibrated meter\n\nDeficiency Signs:\n- Nitrogen: Yellow lower leaves, green veins\n- Phosphorus: Purple/dark leaves\n- Potassium: Brown leaf edges\n\nCost of nutrients: ₹500-1000/month",
  "keywords": ["nutrient", "ec", "ph", "nitrogen", "npk", "deficiency", "cost"],
  "createdAt": "2026-02-21T10:30:00Z",
  "updatedAt": "2026-02-21T10:30:00Z"
}
```
7. Click **Save**
8. Restart app

**Verify**: Knowledge base now exists

---

### Issue 4: "RESOURCE_EXHAUSTED" or "429 Too Many Requests"

**When It Happens**: After many messages, getting error about rate limit

**Root Cause**: Free tier allows 60 requests/minute. You've exceeded it.

**Fix Steps**:
1. **Wait 60 seconds** and try again
2. To increase limit, upgrade to paid tier:
   - Go to https://makersuite.google.com/app/apikey
   - Click on API key
   - Click **Settings**
   - Upgrade billing plan
3. Or **reduce usage** in app

**Prevention**:
- Each message = 1 API call
- Limit to 50 messages/hour per user
- Show warning if approaching limit

---

### Issue 5: Response is too generic / not about hydroponics

**When It Happens**: AI gives general advice instead of farm-specific tips

**Root Cause**: Knowledge base documents are too short or generic

**Fix Steps**:
1. Go to Firebase → **Firestore Database**
2. Go to `ai_knowledge_base` collection
3. Click each document and update the **content** field
4. Add more specific farming information:
   ```
   More specific content:
   - Exact EC levels for each crop
   - Cost of specific fertilizers (e.g., "Urea: ₹250/bag")
   - Problem: "Leaves curling up" → Solution: "Check humidity, reduce water"
   - Include timeframes: "Results in 3-5 days"
   ```
5. Restart app
6. Try same question again

**Better Knowledge Base Content**:
- Be specific with measurements
- Include costs in ₹
- Include timeframes
- Include exact product names
- Include step-by-step procedures

---

### Issue 6: App crashes when opening AI Chat

**When It Happens**: App closes suddenly when tapping AI Assistant

**Root Cause**: Usually Firebase initialization issue

**Fix Steps**:
1. Check console for error message:
   ```bash
   flutter logs
   ```
   Look for any red error text

2. Common fixes:
   - **Firebase not initialized**: Make sure Firebase is set up
     ```
     flutter pub get
     flutter clean
     flutter run
     ```
   - **Dependencies missing**: Add to pubspec.yaml:
     ```yaml
     dependencies:
       google_generative_ai: ^0.4.0
       cloud_firestore: ^4.14.0
       firebase_core: ^2.24.0
     ```
   - **Wrong Flutter version**: Use Flutter 3.13+
     ```bash
     flutter --version
     ```

---

### Issue 7: "No response received from Gemini"

**When It Happens**: Stuck on "Thinking..." forever

**Root Cause**: Network issue or API timeout

**Fix Steps**:
1. Check internet connection
   - Open any website to verify
   
2. Check API status:
   - Go to https://status.cloud.google.com
   - Search for "Generative Language API"
   - If red, Google services are down. Wait.

3. Check Firestore connection:
   - Firebase Console → Firestore → try to read any document
   - If fails, Firebase connection issue

4. Restart app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

5. Try a simpler question:
   - Instead of long question, try: "What is EC?"
   - If that works, knowledge base issue
   - If that fails, API issue

---

### Issue 8: TextBox error "fullWidth not recognized"

**When It Happens**: Error about TextField or ElevatedButton

**Root Cause**: Code using outdated Flutter parameter

**Fix Steps**:
1. Update Flutter:
   ```bash
   flutter upgrade
   ```

2. Regenerate UI code:
   - Delete the file causing error
   - Copy working code from git
   - Run `flutter pub get`

3. If still failing, replace this:
   ```dart
   // OLD (broken)
   ElevatedButton(
     fullWidth: true,  // ❌ Not valid
     child: Text('Send'),
   )
   
   // NEW (correct)
   SizedBox(
     width: double.infinity,  // Full width
     child: ElevatedButton(
       child: const Text('Send'),
       onPressed: () {},
     ),
   )
   ```

---

## 🔍 Debugging Tips

### Enable Debug Logging

Add to your Flutter code:
```dart
// In main.dart or initialization
import 'dart:developer' as developer;

// Log API calls
developer.log('Sending query to Gemini: $userMessage');

// Check Firestore operations
FirebaseFirestore.instance
  .collection('ai_knowledge_base')
  .get()
  .then((snapshot) {
    developer.log('Found ${snapshot.docs.length} knowledge documents');
  });
```

### View Logs with Flutter Tools

```bash
# Start app with dev tools
flutter run --dev-tools

# Or just view logs in terminal
flutter logs

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Monitor Firebase in Real-time

1. Firebase Console → Firestore → **Logs**
2. See all database operations in real-time
3. If knowledge base being queried, you'll see reads
4. If API fails, check error logs here

### Check API Calls in Google Cloud

1. Go to: https://console.cloud.google.com
2. Search for "Cloud Trace" or "Error Reporting"
3. See all recent API calls and any errors

---

## ✨ Performance Optimization

### If Responses Are Slow

**Check 1: Reduce Knowledge Base Size**
- If knowledge base has 100+ documents, trim to top 10
- Each document adds time to response

**Check 2: Adjust Firestore Query**
- Current: Returns top 3 matching docs
- Can reduce to top 1 for faster response

**Check 3: Use Faster Model**
- Current: `gemini-1.5-flash`
- Already the fastest model
- Changing to `-pro` will be SLOWER

**Check 4: Reduce Context**
- Each character in knowledge base = slower response
- Trim documents to essential info only

---

## 📊 Monitoring Checklist

**Daily**:
- [ ] Check if AI responses are helpful
- [ ] Monitor API costs (should be minimal)
- [ ] Look for user complaints

**Weekly**:
- [ ] Review top questions users ask
- [ ] Update knowledge base with new info
- [ ] Check error logs in Google Cloud

**Monthly**:
- [ ] Update knowledge base with seasonal info
- [ ] Review API usage trends
- [ ] Optimize documents for common questions

---

## 🏥 Health Check: Run This Test

```dart
// Add this function to your app
Future<void> healthCheck() async {
  print('🏥 HydroSmart AI Health Check');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  
  try {
    // Test 1: Firebase Connection
    print('✓ Test 1: Firebase Connection...');
    await FirebaseFirestore.instance.collection('test').limit(1).get();
    print('  ✅ Firebase connected');
    
    // Test 2: Config Document
    print('✓ Test 2: Gemini Config...');
    final config = await FirebaseFirestore.instance
      .collection('config')
      .doc('gemini_config')
      .get();
    if (config.exists) {
      final apiKey = config.data()?['apiKey'];
      if (apiKey != null && apiKey.toString().isNotEmpty) {
        print('  ✅ API Key found: ${apiKey.toString().substring(0, 10)}...');
      } else {
        print('  ❌ API Key missing');
      }
    } else {
      print('  ❌ Config document not found');
    }
    
    // Test 3: Knowledge Base
    print('✓ Test 3: Knowledge Base...');
    final kb = await FirebaseFirestore.instance
      .collection('ai_knowledge_base')
      .limit(1)
      .get();
    print('  ✅ Knowledge base has ${kb.docs.length} documents');
    
    // Test 4: API Call
    print('✓ Test 4: Gemini API...');
    final apiKey = config.data()?['apiKey'];
    if (apiKey != null) {
      final service = GeminiRagService(geminiApiKey: apiKey);
      // This will make actual API call
      final response = await service.getAiResponse('Test');
      print('  ✅ API responded: "${response.substring(0, 50)}..."');
    }
    
  } catch (e) {
    print('  ❌ Error: $e');
  }
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('Health check complete!');
}

// Call it from your app
// await healthCheck();
```

---

## 🎯 Quick Reference: Common Fixes

| Issue | Quick Fix |
|-------|-----------|
| API key error | Regenerate at makersuite.google.com/app/apikey |
| Not finding docs | Check Firebase has `ai_knowledge_base` collection |
| Rate limited | Wait 60 seconds, then try again |
| Generic responses | Update knowledge base content in Firestore |
| App crashes | Run `flutter clean && flutter pub get && flutter run` |
| Streaming not working | Check internet, verify API key, restart app |
| API costs high | Reduce message frequency, trim knowledge base |
| Response too slow | Reduce number of knowledge documents (top 1-3) |

---

## 📞 Getting Help

### Before Asking for Help, Check:
1. Is Firebase set up correctly? (Check Firestore console)
2. Is API key valid? (Try at makersuite.google.com)
3. Is API enabled? (Check Google Cloud console)
4. Is internet working? (Try opening a website)
5. Are logs showing any errors? (Run `flutter logs`)

### Resources:
- **Gemini API Docs**: https://ai.google.dev/
- **Firebase FAQs**: https://firebase.google.com/support
- **Google Cloud Limits**: https://cloud.google.com/generative-ai/quotas
- **Flutter Debugging**: https://flutter.dev/docs/testing/debugging

---

## 🎉 Success Indicators

If all of these work, your system is healthy:

✅ App loads without errors  
✅ AI Chat screen opens  
✅ User message appears in chat  
✅ "Thinking..." indicator shows  
✅ AI response streams in real-time  
✅ Response is relevant to question  
✅ Multiple questions work  
✅ No API errors in console  

---

**Last Updated**: February 21, 2026  
**Status**: ✅ Production Ready  
**Support Level**: Community Supported
