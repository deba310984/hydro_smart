# Hydro Smart AI Chatbot Setup Guide

## ✅ Chatbot is Now Fixed!

The chatbot will now work perfectly once you configure the Gemini API key.

## Quick Setup (2 minutes)

### Step 1: Get Your Gemini API Key
1. Go to [Google AI Studio](https://aistudio.google.com/app/apikeys)
2. Click **"Create API Key"**
3. Copy the generated API key

### Step 2: Configure Firebase
1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your **"hydro_smart"** project
3. Go to **Firestore Database** (in the left sidebar)
4. Create a collection named **`config`** (if it doesn't exist)
5. Add a new document with ID: **`gemini_config`**
6. Add this field:
   - Field name: `apiKey`
   - Value: *(paste your Gemini API key here)*

### Step 3: Restart the App
1. Close the app completely
2. Run `flutter run` again
3. The chatbot will now work! 🎉

## What the Chatbot Can Help With

The AI Assistant can answer questions about:
- **Hydroponics Systems** - DFT, NFT, Drip systems
- **Nutrient Management** - EC, pH, nutrient levels
- **Temperature & Humidity** - Optimal growing conditions
- **Pest & Disease Control** - Prevention and treatment
- **Cost & Profitability** - Revenue optimization
- **Crop Selection** - Best crops for your system
- **Equipment** - Pumps, meters, lights, sensors

## Features

✨ **Real-time Streaming** - Responses appear as the AI thinks
🎓 **Smart Knowledge Base** - Powered by hydroponics expertise
⚡ **Fast & Responsive** - Uses Gemini 1.5 Flash model
📱 **Clean UI** - Beautiful chat interface

## Troubleshooting

### "Gemini service is not configured" message
- ✅ Double-check your API key is in Firebase
- ✅ Make sure the field name is exactly `apiKey`
- ✅ Restart the app after adding the API key

### "Error unable to get response"
- Check your Gemini API key is valid
- Make sure you have internet connection
- Check Firebase permissions are correct

### API Key not working
- Generate a new API key from [Google AI Studio](https://aistudio.google.com/app/apikeys)
- Delete the old one and add the new key to Firebase

## Custom Knowledge Base

The chatbot comes with built-in knowledge about:
- Nutrient management for 6 crop types
- Temperature & humidity optimization
- Pest and disease identification
- Cost and profitability analysis
- System types and equipment specs

This knowledge is automatically loaded from Firestore when the app starts.

## Need Help?

1. Check the Firebase Console for collection structure
2. Verify the API key is valid at [Google AI Studio](https://aistudio.google.com/app/apikeys)
3. Check console logs for detailed error messages

---

**Your chatbot assistant is ready to help farmers 24/7!** 🚀
