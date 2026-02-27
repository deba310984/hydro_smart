# RAG Implementation Deep Dive - Code Architecture

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    HydroSmart App (Flutter)                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│              UI Layer: ChatScreen (Real-time UI)              │
│  - Displays user messages                                    │
│  - Shows streaming AI responses                              │
│  - Input field with send button                              │
│  - Loading/thinking indicators                               │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│        State Management: ChatController (Riverpod)            │
│  - Manages chat messages list                                │
│  - Provides Gemini API key from Firebase                     │
│  - Initializes GeminiRagService                              │
│  - Streams responses from AI                                 │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│      RAG Layer: GeminiRagService (Core Intelligence)          │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐   │
│  │ 1. RETRIEVE Phase                                      │   │
│  │ ─────────────────────                                  │   │
│  │ - Query Firestore knowledge base                       │   │
│  │ - Keyword matching (title, content, keywords fields)   │   │
│  │ - Return top matching documents as context             │   │
│  │ - Each doc has: title, content, keywords, timestamp    │   │
│  └───────────────────────────────────────────────────────┘   │
│                              ↓                                │
│  ┌───────────────────────────────────────────────────────┐   │
│  │ 2. AUGMENT Phase                                       │   │
│  │ ─────────────────────                                  │   │
│  │ - Build comprehensive prompt with:                     │   │
│  │   * Retrieved context docs                             │   │
│  │   * User question                                      │   │
│  │   * System instructions for farming assistance         │   │
│  │ - Formatted as proper system + user message            │   │
│  └───────────────────────────────────────────────────────┘   │
│                              ↓                                │
│  ┌───────────────────────────────────────────────────────┐   │
│  │ 3. GENERATE Phase                                      │   │
│  │ ─────────────────────                                  │   │
│  │ - Send augmented prompt to Gemini API                  │   │
│  │ - Use streaming for real-time response                 │   │
│  │ - Yield tokens one-by-one as they arrive               │   │
│  │ - Handle errors gracefully                             │   │
│  └───────────────────────────────────────────────────────┘   │
│                              ↓                                │
│  ┌───────────────────────────────────────────────────────┐   │
│  │ 4. STREAM Phase                                        │   │
│  │ ─────────────                                          │   │
│  │ - Async generator yields response chunks               │   │
│  │ - Each chunk = new tokens from Gemini                  │   │
│  │ - Update UI in real-time as data arrives               │   │
│  └───────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  External Services: Google Gemini + Firebase                 │
│  - Gemini API: Generates intelligent responses               │
│  - Firestore: Stores knowledge base + config                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 📂 Code File Structure

```
lib/features/ai_chat/
├── chat_controller.dart      ← State management with Gemini integration
├── chat_model.dart           ← ChatMessage data model
├── chat_screen.dart          ← UI with real-time streaming
├── gemini_service.dart       ← Core RAG implementation
└── widgets/
    └── chat_bubble.dart      ← Reusable message bubble component
```

---

## 🔍 Code Walkthrough - Each Component

### 1. GeminiRagService (gemini_service.dart)

**Purpose**: Core RAG implementation that retrieves documents, builds context, and streams responses.

```dart
class GeminiRagService {
  final String geminiApiKey;
  late final GenerativeModel _model;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Initializes Google Gemini model
  GeminiRagService({required this.geminiApiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',  // Fast, cost-effective model
      apiKey: geminiApiKey,
      systemPrompt: '''You are HydroSmart AI, an expert in hydroponics farming.
        Provide practical, specific advice for hydroponics farmers in India.
        Include costs in Indian Rupees (₹), specific measurements, and timelines.
        Be concise but comprehensive.'''
    );
  }
  
  // RETRIEVE Phase: Find relevant documents
  Future<List<Map<String, dynamic>>> retrieveRelevantDocuments(
    String query
  ) async {
    try {
      final snapshot = await _firestore
        .collection('ai_knowledge_base')
        .get();
      
      List<Map<String, dynamic>> relevantDocs = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final title = data['title']?.toString().toLowerCase() ?? '';
        final content = data['content']?.toString().toLowerCase() ?? '';
        final keywords = (data['keywords'] as List?)
          ?.map((k) => k.toString().toLowerCase())
          .join(' ') ?? '';
        
        // Keyword matching: Check if query words appear in document
        final searchText = '$title $content $keywords';
        final queryWords = query.toLowerCase().split(' ');
        
        int matches = 0;
        for (var word in queryWords) {
          if (word.length > 3 && searchText.contains(word)) {
            matches++;
          }
        }
        
        // Include if at least one keyword matches
        if (matches > 0) {
          relevantDocs.add({
            'title': data['title'] ?? 'Untitled',
            'content': data['content'] ?? '',
            'score': matches,  // Relevance score
          });
        }
      }
      
      // Sort by relevance (highest score first)
      relevantDocs.sort((a, b) => b['score'].compareTo(a['score']));
      return relevantDocs.take(3).toList();  // Return top 3 docs
      
    } catch (e) {
      print('Error retrieving documents: $e');
      return [];
    }
  }
  
  // AUGMENT Phase: Build context-enriched prompt
  String _buildContextPrompt(String userQuery, List<Map<String, dynamic>> docs) {
    String context = 'KNOWLEDGE BASE CONTEXT:\n';
    
    for (var doc in docs) {
      context += '\n📚 ${doc['title']}\n';
      context += '${doc['content']}\n';
      context += '---\n';
    }
    
    return '''$context

FARMER'S QUESTION: $userQuery

Please answer based on the context above. Be specific with:
- Measurements (EC, pH, temperature values)
- Costs in Indian Rupees (₹)
- Timelines for results
- Practical action steps''';
  }
  
  // GENERATE Phase: Stream response from Gemini
  Stream<String> streamAiResponse(String userQuery) async* {
    try {
      // RETRIEVE relevant documents
      final relevantDocs = await retrieveRelevantDocuments(userQuery);
      
      // AUGMENT with context
      final prompt = _buildContextPrompt(userQuery, relevantDocs);
      
      // GENERATE with streaming
      final stream = _model.generateContentStream(
        [Content.text(prompt)]
      );
      
      // Yield each response chunk as it arrives
      await for (final response in stream) {
        final text = response.text;
        if (text != null && text.isNotEmpty) {
          yield text;  // Send to UI
        }
      }
    } catch (e) {
      yield 'Error generating response: $e';
    }
  }
  
  // Initialize knowledge base (called once during app startup)
  Future<void> initializeKnowledgeBase() async {
    final snapshot = await _firestore
      .collection('ai_knowledge_base')
      .get();
    
    // Only initialize if empty
    if (snapshot.docs.isEmpty) {
      final documents = [
        {
          'title': 'Nutrient Management',
          'content': '''EC Level Management:
            - Optimal EC: 1.2-1.5 dS/m for lettuce
            - NPK Ratio: 14:7:14 for vegetative growth
            
            pH Management:
            - Optimal pH: 5.5-6.5 for most crops
            - Check daily with calibrated meter
            
            Deficiency Signs:
            - Nitrogen: Yellow lower leaves, green veins
            - Phosphorus: Purple/dark leaves
            - Potassium: Brown leaf edges''',
          'keywords': ['nutrient', 'ec', 'ph', 'nitrogen', 'npp', 'deficiency']
        },
        // ... 5 more documents
      ];
      
      for (var doc in documents) {
        await _firestore.collection('ai_knowledge_base').add({
          ...doc,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}
```

**Key Methods**:
- `retrieveRelevantDocuments()` - Finds matching docs from Firestore
- `_buildContextPrompt()` - Builds prompt with context
- `streamAiResponse()` - Async generator yielding response tokens
- `initializeKnowledgeBase()` - Creates sample knowledge docs

---

### 2. ChatController (chat_controller.dart)

**Purpose**: Riverpod state management connecting UI to GeminiRagService.

```dart
// Riverpod provider: Fetches API key from Firebase
final geminiApiKeyProvider = FutureProvider<String>((ref) async {
  final config = await FirebaseFirestore.instance
    .collection('config')
    .doc('gemini_config')
    .get();
  
  final apiKey = config.data()?['apiKey'] as String?;
  if (apiKey == null || apiKey.isEmpty) {
    throw Exception('Gemini API key not configured in Firebase');
  }
  return apiKey;
});

// Riverpod provider: Initializes GeminiRagService
final geminiServiceProvider = FutureProvider<GeminiRagService>((ref) async {
  final apiKey = await ref.watch(geminiApiKeyProvider.future);
  final service = GeminiRagService(geminiApiKey: apiKey);
  await service.initializeKnowledgeBase();  // Initialize on first run
  return service;
});

// State notifier for managing chat messages
final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
  (ref) => ChatNotifier(ref)
);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref ref;
  
  ChatNotifier(this.ref) : super([]);
  
  // Called when user sends a message
  Future<void> addMessageWithStreaming(String userMessage) async {
    if (userMessage.trim().isEmpty) return;
    
    // Add user message to chat
    state = [...state, ChatMessage(text: userMessage, isUser: true)];
    
    try {
      // Get Gemini service
      final service = await ref.read(geminiServiceProvider.future);
      
      // Create empty AI message (will be filled with streaming)
      final aiMessage = ChatMessage(
        text: '',
        isUser: false,
        isStreaming: true,
      );
      state = [...state, aiMessage];
      
      // Stream response from Gemini
      final stream = service.streamAiResponse(userMessage);
      String fullResponse = '';
      
      await for (final chunk in stream) {
        fullResponse += chunk;
        
        // Update the AI message with accumulated response
        state = [
          ...state.sublist(0, state.length - 1),
          aiMessage.copyWith(
            text: fullResponse,
            isStreaming: false,  // Done streaming
          ),
        ];
      }
    } catch (e) {
      // Error fallback
      state = [
        ...state,
        ChatMessage(
          text: 'Sorry, AI assistant not configured. Please set up Gemini API key in Firebase.',
          isUser: false,
        ),
      ];
    }
  }
}
```

**Key Features**:
- `geminiApiKeyProvider` - Fetches API key from Firebase config
- `geminiServiceProvider` - Lazily initializes service on first use
- `ChatNotifier.addMessageWithStreaming()` - Handles streaming responses
- Real-time UI updates as response arrives

---

### 3. ChatScreen (chat_screen.dart)

**Purpose**: Flutter UI displaying chat with streaming indicators.

```dart
class ChatScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider);
    final isLoading = ref.watch(_isLoadingProvider);  // Loading state
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 Hydro Smart AI Assistant'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
              ? Center(
                  child: Text(
                    'Ask me about hydroponics farming!\n\n'
                    '💧 Nutrients & pH\n'
                    '🌡️ Temperature control\n'
                    '🐛 Pest management\n'
                    '💰 Profitability\n'
                    '🥬 Crop selection',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _ChatBubble(message: messages[index]);
                  },
                ),
          ),
          _ChatInputField(
            onSubmit: (text) async {
              await ref.read(chatProvider.notifier)
                .addMessageWithStreaming(text);
            },
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

// Message bubble widget
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.green[600] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black,
              ),
            ),
            // Show streaming indicator if response is being generated
            if (message.isStreaming && !message.isUser)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          Colors.green[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Thinking...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Input field widget
class _ChatInputField extends StatefulWidget {
  final Function(String) onSubmit;
  final bool isLoading;
  
  @override
  State<_ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<_ChatInputField> {
  final _controller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !widget.isLoading,  // Disable while loading
              decoration: InputDecoration(
                hintText: 'Ask about hydroponics...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                widget.onSubmit(value);
                _controller.clear();
              },
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: widget.isLoading
              ? null
              : () {
                  widget.onSubmit(_controller.text);
                  _controller.clear();
                },
            backgroundColor: Colors.green[600],
            child: widget.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**Key UI Elements**:
- `_ChatBubble` - Displays messages with streaming indicator
- `_ChatInputField` - Input with loading state management
- Green theme for user messages, grey for AI
- Streaming animation shows "Thinking..." while response generates

---

## 🔄 Data Flow Example

```
User Input
    ↓
"How do I prevent mold?"
    ↓
ChatInputField captures text
    ↓
Calls: ref.read(chatProvider.notifier).addMessageWithStreaming(text)
    ↓
ChatNotifier.addMessageWithStreaming():
    1. Add user message to state
    2. Get GeminiRagService from ref.read()
    3. Call service.streamAiResponse(userMessage)
    ↓
GeminiRagService.streamAiResponse():
    1. retrieveRelevantDocuments("How do I prevent mold?")
       - Searches Firestore knowledge base
       - Finds: "Pest & Disease Management" doc
    2. _buildContextPrompt() - Creates augmented prompt:
       "KNOWLEDGE BASE CONTEXT:
        📚 Pest & Disease Management
        [content about mold prevention...]
        
        FARMER'S QUESTION: How do I prevent mold?
        
        Please answer..."
    3. _model.generateContentStream() - Sends to Gemini API
    4. Yields each chunk of response as it arrives
    ↓
Back to ChatNotifier:
    Each chunk is accumulated into fullResponse
    State is updated with growing response
    ↓
ChatScreen watches state changes:
    TextField shows message in real-time
    CircularProgressIndicator stops when done
    ↓
User sees complete response like:
"Mold growth indicates high humidity. Here's how to prevent:
1. Increase ventilation...
2. Reduce humidity below 70%...
3. Use neem oil spray..."
```

---

## 🧠 RAG Magic Explained

### Why RAG Works

Without RAG:
```
User: "How do I prevent mold?"
Gemini (no knowledge): "General mold prevention tips from its training data"
Result: Generic advice, may not be hydroponics-specific
```

With RAG:
```
User: "How do I prevent mold?"
    ↓
Retrieve from knowledge base: "Pest & Disease Management" doc
    ↓
Augment prompt: "Here's what we know about mold in hydroponics: [doc content]. User asks: [question]"
    ↓
Gemini (with context): "In hydroponics, mold is caused by high humidity. To prevent:
1. Reduce humidity below 70%...
2. Increase airflow..."
Result: Hydroponics-specific advice from knowledge base + AI reasoning
```

### Knowledge Base Structure

Each document has:
```json
{
  "title": "Nutrient Management",
  "content": "EC Level Management:\n- Optimal EC: 1.2-1.5 dS/m...",
  "keywords": ["nutrient", "ec", "ph", ...],
  "createdAt": "2026-02-21T10:30:00Z",
  "updatedAt": "2026-02-21T10:30:00Z"
}
```

When user asks a question:
1. Keywords extracted: ["prevent", "mold"]
2. Search knowledge base for matches
3. Title, content, and keyword fields all searched
4. Top 3 matching docs returned
5. Their content inserted into prompt sent to Gemini

---

## 🔌 Integration Points

### Firebase Connection Points

1. **Config Collection** (read on startup)
   - Path: `config/gemini_config`
   - Field: `apiKey`
   - Used by: `geminiApiKeyProvider`

2. **Knowledge Base Collection** (read for every query)
   - Path: `ai_knowledge_base/{doc}`
   - Fields: `title`, `content`, `keywords`
   - Used by: `retrieveRelevantDocuments()`

3. **Auto-Initialization** (write on first app load)
   - Populates 6 knowledge documents if empty
   - One-time only (subsequent loads skip)

### Gemini API Connection Points

1. **Model**: `gemini-1.5-flash`
   - Fast responses
   - Lower cost than pro models
   - Perfect for farming Q&A

2. **Streaming**: `generateContentStream()`
   - Yields response chunks in real-time
   - Better UX than waiting for full response

3. **Rate Limits**: 60 requests/min (free tier)
   - Each user query = 1 API call
   - Sufficient for most use cases

---

## ✅ Testing Checklist

- [ ] Firebase config exists with apiKey
- [ ] Firestore knowledge base populated (6 docs)
- [ ] Gemini API key valid and enabled
- [ ] App can fetch API key from Firebase
- [ ] App can query knowledge base
- [ ] Gemini returns responses in streaming
- [ ] UI shows response appearing in real-time
- [ ] Error handling works if API key invalid

---

## 📊 Performance Metrics

Expected metrics for a typical query:

```
Time to first token: 1-2 seconds
Time to full response: 3-5 seconds
Firestore reads per query: 1 (knowledge base)
API calls per query: 1 (Gemini)
Cost per query: ₹0.01-0.05
```

---

## 🚀 Production Checklist

- [ ] API key NOT hardcoded in app
- [ ] API key stored securely in Firestore
- [ ] Firestore rules restrict knowledge access to authenticated users
- [ ] Error messages user-friendly (not tech jargon)
- [ ] Rate limiting implemented (if > 60 requests/min)
- [ ] Knowledge base regularly updated with farm data
- [ ] Admin UI for managing knowledge documents
- [ ] Monitoring set up for API usage and errors
- [ ] User feedback mechanism for improving responses

---

**Status**: ✅ Architecture complete and ready for deployment!
