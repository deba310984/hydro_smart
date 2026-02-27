import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeminiRagService {
  late final GenerativeModel _model;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String apiKey;
  bool isConfigured = false;

  // Constructor
  GeminiRagService({required String geminiApiKey}) {
    apiKey = geminiApiKey;
    isConfigured = geminiApiKey.isNotEmpty;
    if (isConfigured) {
      _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: geminiApiKey,
      );
    }
  }

  /// Retrieve relevant documents from Firestore knowledge base
  /// Based on user query
  Future<List<String>> retrieveRelevantDocuments(String query) async {
    try {
      final queryLower = query.toLowerCase();
      final knowledgeBase =
          await _firestore.collection('ai_knowledge_base').limit(10).get();

      final relevantDocs = <String>[];

      for (var doc in knowledgeBase.docs) {
        final content = doc['content'] as String? ?? '';
        final keywords = (doc['keywords'] as List<dynamic>? ?? [])
            .cast<String>()
            .map((k) => k.toLowerCase())
            .toList();

        // Check if any keywords match the query
        bool isRelevant =
            keywords.any((keyword) => queryLower.contains(keyword));

        // Also check content relevance
        if (!isRelevant) {
          isRelevant = content.toLowerCase().contains(queryLower);
        }

        if (isRelevant) {
          relevantDocs.add(content);
        }
      }

      return relevantDocs;
    } catch (e) {
      print('Error retrieving documents: $e');
      return [];
    }
  }

  /// Get AI response using RAG (Retrieval-Augmented Generation)
  /// Combines Gemini with Firestore knowledge base
  Future<String> getAiResponse(String userQuery) async {
    try {
      // Step 1: Retrieve relevant documents from Firestore
      final relevantDocs = await retrieveRelevantDocuments(userQuery);

      // Step 2: Build context from retrieved documents
      String context = '';
      if (relevantDocs.isNotEmpty) {
        context =
            'Context from knowledge base:\n${relevantDocs.join('\n\n')}\n\n';
      }

      // Step 3: Create prompt with context (RAG approach)
      final prompt =
          '''You are an expert hydroponics farm management AI assistant. 
Help farmers optimize their hydroponic systems, manage crops, and maximize yields.

$context

User Question: $userQuery

Instructions:
- Provide practical, actionable advice for hydroponics farming
- Include specific measurements and timeframes
- Mention cost-effective solutions
- Suggest preventive measures
- Be supportive and encouraging
- Use simple language
- Focus on sustainability

Answer:''';

      // Step 4: Generate response from Gemini
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      return response.text ?? 'Unable to generate response. Please try again.';
    } catch (e) {
      return 'Error: Unable to fetch response. ${e.toString()}';
    }
  }

  /// Stream AI response for real-time replies
  Stream<String> streamAiResponse(String userQuery) async* {
    if (!isConfigured) {
      yield '''I'm currently offline. To enable the AI Assistant:

1. Go to Firebase Console (console.firebase.google.com)
2. Select your "hydro_smart" project
3. Go to Firestore Database
4. Create a collection named "config"
5. Add a document with ID "gemini_config"
6. Add a field: apiKey = your-gemini-api-key

To get your Gemini API key:
1. Visit https://aistudio.google.com/app/apikeys
2. Click "Create API Key"
3. Copy and save it

Once configured, restart the app and I'll be ready to help! 🚀''';
      return;
    }

    try {
      // Step 1: Retrieve relevant documents
      final relevantDocs = await retrieveRelevantDocuments(userQuery);

      // Step 2: Build context
      String context = '';
      if (relevantDocs.isNotEmpty) {
        context =
            'Context from knowledge base:\n${relevantDocs.join('\n\n')}\n\n';
      }

      // Step 3: Create prompt with context
      final prompt =
          '''You are an expert hydroponics farm management AI assistant. 
Help farmers optimize their hydroponic systems, manage crops, and maximize yields.

$context

User Question: $userQuery

Instructions:
- Provide practical, actionable advice for hydroponics farming
- Include specific measurements and timeframes
- Mention cost-effective solutions
- Suggest preventive measures
- Be supportive and encouraging
- Use simple language
- Focus on sustainability and profitability

Answer:''';

      // Step 4: Stream response from Gemini
      final response = _model.generateContentStream([
        Content.text(prompt),
      ]);

      await for (var chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      yield 'Error: ${e.toString()}';
    }
  }

  /// Initialize knowledge base with sample hydroponics data
  Future<void> initializeKnowledgeBase() async {
    try {
      final knowledgeBaseRef = _firestore.collection('ai_knowledge_base');

      // Check if already initialized
      final count = await knowledgeBaseRef.count().get();
      if (count.count != null && count.count! > 0) {
        print('Knowledge base already initialized');
        return;
      }

      // Add sample knowledge base documents
      final documents = [
        {
          'title': 'Nutrient Management',
          'content': '''
For hydroponic systems, maintain these nutrient levels:
- EC (Electrical Conductivity): 1.2-2.0 dS/m depending on crop
- pH: 5.5-6.5 for most crops
- Nitrogen: 150-200 ppm
- Phosphorus: 40-60 ppm
- Potassium: 150-200 ppm

Change nutrient solution every 2-3 weeks. Monitor daily with EC and pH meters.
Yellowing leaves often indicate nitrogen deficiency - increase nitrogen by 20-30%.
Purple leaves suggest phosphorus deficiency or cold temperatures below 15°C.
''',
          'keywords': [
            'nutrient',
            'ec',
            'ph',
            'nitrogen',
            'yellowing',
            'solution',
            'deficiency'
          ],
        },
        {
          'title': 'Temperature & Humidity Management',
          'content': '''
Optimal growing conditions:
- Daytime temperature: 18-24°C (ideal 21°C)
- Night temperature: 15-18°C
- Humidity: 60-70% (prevent mold above 75%)
- Light hours: 12-16 hours daily
- Root zone temperature: 18-20°C

High humidity + poor circulation = fungal diseases. Increase ventilation.
Use evaporative coolers or misters when temperature exceeds 24°C.
LED lights produce less heat than HPS bulbs, ideal for small spaces.
''',
          'keywords': [
            'temperature',
            'humidity',
            'mold',
            'light',
            'ventilation',
            'cooling',
            'root'
          ],
        },
        {
          'title': 'Pest & Disease Management',
          'content': '''
Common hydroponics problems:
- Powdery Mildew: Reduce humidity, improve air circulation, Neem oil spray
- Root Rot: Lower water temperature to 18°C, use beneficial bacteria
- Whiteflies: Yellow sticky traps, spray neem oil or insecticidal soap
- Aphids: Remove by hand, spray with water, use neem oil
- Algae/Green Water: Cover reservoir, reduce light exposure, use UV filter

Prevention is better than cure:
- Sterilize equipment between crops with 10% bleach solution
- Use disease-resistant varieties
- Maintain clean growing environment
- Monitor plants daily for early signs
- Quarantine new plants for 2 weeks
''',
          'keywords': [
            'pest',
            'disease',
            'mold',
            'rot',
            'algae',
            'infection',
            'neem',
            'spray'
          ],
        },
        {
          'title': 'Cost & Profitability',
          'content': '''
Typical monthly costs for 50m² hydroponic farm:
- Electricity: ₹3,000-5,000 (LED lights, pumps, cooling)
- Nutrients: ₹2,000-3,000
- Water & additives: ₹500-1,000
- Labor: ₹5,000-8,000
- Miscellaneous: ₹500-1,000
Total: ₹11,000-18,000/month

Revenue (Lettuce example):
- Yield: 200-300 kg per month
- Market price: ₹30-50 per kg
- Revenue: ₹6,000-15,000/month
- Profit: ₹(-)5,000 to ₹4,000/month after optimization

Improving profitability:
- Choose high-value crops (herbs, microgreens, specialty lettuce)
- Reduce electricity costs with solar + batteries
- Direct marketing to restaurants (premium pricing)
- Multi-harvest systems (staggered planting)
- Water recycling systems reduce water costs by 60%
''',
          'keywords': [
            'cost',
            'profit',
            'money',
            'revenue',
            'price',
            'electricity',
            'nutrient',
            'income'
          ],
        },
        {
          'title': 'Crop Selection & Growing Cycles',
          'content': '''
Quick-growing profitable crops:
- Lettuce & greens: 30-35 days, ₹40/kg
- Spinach: 40-45 days, ₹35/kg
- Basil & herbs: 40-50 days, ₹60-80/kg
- Microgreens: 10-14 days, ₹200-300/kg
- Cherry tomatoes: 60-70 days, ₹60-80/kg
- Cucumbers: 60-90 days, ₹30-40/kg
- Strawberries: 60-90 days, ₹100-150/kg

Optimal spacing for lettuce: 20x20 cm
Optimal spacing for tomatoes: 40x60 cm
Light requirements: 200-300 μmol/(m²·s) for leafy greens

Staggered planting system:
- Plant 1/4 of lettuce bed every 8 days
- Continuous harvest every 30 days
- Maximize space utilization and revenue
''',
          'keywords': [
            'crop',
            'lettuce',
            'tomato',
            'basil',
            'yield',
            'growing',
            'cycle',
            'harvest',
            'days'
          ],
        },
        {
          'title': 'System Types & Equipment',
          'content': '''
DFT (Deep Flow Technique):
- Best for: Leafy greens, herbs
- Power requirement: Low (1kW for 50m²)
- Cost: ₹30,000-50,000 for 50m²
- Yield: 8-12 kg/m²/year

NFT (Nutrient Film Technique):
- Best for: Lettuce, basil
- Power requirement: Low (0.5kW)
- Cost: ₹25,000-40,000
- Yield: 10-15 kg/m²/year

Drip System:
- Best for: All crops
- Power requirement: Medium (2-3kW)
- Cost: ₹40,000-70,000
- Yield: 15-20 kg/m²/year

Essential equipment:
- pH meter: ₹1,000-2,000
- EC meter: ₹800-1,500
- Air pump: ₹500-1,000 per bed
- Water pump: ₹2,000-5,000
- Temperature gauge: ₹200-500
- LED grow lights: ₹5,000-10,000 per unit
''',
          'keywords': [
            'system',
            'dft',
            'nft',
            'drip',
            'equipment',
            'pump',
            'meter',
            'light'
          ],
        },
      ];

      // Add documents to Firestore
      for (var doc in documents) {
        await knowledgeBaseRef.add({
          ...doc,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      print('Knowledge base initialized with ${documents.length} documents');
    } catch (e) {
      print('Error initializing knowledge base: $e');
    }
  }

  /// Get response with streaming support
  Stream<String> getStreamingResponse(String query) {
    return streamAiResponse(query);
  }

  /// Check if service is properly configured
  bool isServiceConfigured() {
    return isConfigured;
  }
}
