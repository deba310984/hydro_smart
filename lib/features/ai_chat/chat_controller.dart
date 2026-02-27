import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_model.dart';
import 'groq_service.dart';

// Initialize Groq service
final groqServiceProvider = FutureProvider<GroqRagService>((ref) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('config')
        .doc('gemini_config')
        .get();

    // Try to get groqApiKey, fallback to apiKey field
    final apiKey = doc.data()?['groqApiKey'] as String? ??
        doc.data()?['apiKey'] as String? ??
        '';
    final service = GroqRagService(groqApiKey: apiKey);

    // Initialize knowledge base only if configured
    if (apiKey.isNotEmpty) {
      await service.initializeKnowledgeBase();
    }
    return service;
  } catch (e) {
    print('Error initializing Groq service: $e');
    // Return unconfigured service instead of null
    return GroqRagService(groqApiKey: '');
  }
});

final chatMessagesProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;

  ChatNotifier(this._ref)
      : super([
          ChatMessage(
            id: '0',
            text:
                'Hi! I\'m your Hydro Smart AI Assistant powered by Google Gemini. Ask me anything about hydroponics, plant care, nutrient management, pest control, profitability, or farming techniques. I have access to a comprehensive knowledge base.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ]);

  /// Send message and get streaming response from Gemini
  Future<void> addMessageWithStreaming(String text) async {
    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = [...state, userMessage];

    // Get Groq service
    final groqService = await _ref.read(groqServiceProvider.future);

    // Create placeholder for streaming response
    final aiMessageId = DateTime.now().toString();
    final aiMessage = ChatMessage(
      id: aiMessageId,
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    state = [...state, aiMessage];

    // Stream response from Groq
    try {
      var fullResponse = '';

      await for (var chunk in groqService.getStreamingResponse(text)) {
        fullResponse += chunk;

        // Update message with streaming text
        state = state.map((msg) {
          if (msg.id == aiMessageId) {
            return msg.copyWith(text: fullResponse);
          }
          return msg;
        }).toList();
      }

      // Mark streaming as complete
      state = state.map((msg) {
        if (msg.id == aiMessageId) {
          return msg.copyWith(isStreaming: false);
        }
        return msg;
      }).toList();
    } catch (e) {
      // Error handling
      state = state.map((msg) {
        if (msg.id == aiMessageId) {
          return msg.copyWith(
            text: 'Error: Unable to get response. ${e.toString()}',
            isStreaming: false,
          );
        }
        return msg;
      }).toList();
    }
  }

  /// Legacy method for backward compatibility
  void addMessage(String text) async {
    await addMessageWithStreaming(text);
  }
}
