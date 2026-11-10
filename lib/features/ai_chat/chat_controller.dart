import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'chat_model.dart';
import 'groq_service.dart';

// Compile-time key, injected via: flutter run --dart-define=GROQ_API_KEY=gsk_...
const String _kBuildTimeGroqKey =
    String.fromEnvironment('GROQ_API_KEY', defaultValue: '');

final groqServiceProvider = FutureProvider<GroqRagService>((ref) async {
  // 1. Build-time key wins (fastest path, no Firestore round-trip)
  if (_kBuildTimeGroqKey.isNotEmpty) {
    print('[GroqService] Using GROQ_API_KEY from dart-define');
    final service = GroqRagService(groqApiKey: _kBuildTimeGroqKey);
    // Fire-and-forget KB seed; do not block the first message.
    unawaited(service.initializeKnowledgeBase());
    return service;
  }

  // 2. Fall back to Firestore config document
  String reason;
  try {
    final doc = await FirebaseFirestore.instance
        .collection('config')
        .doc('gemini_config')
        .get();

    if (!doc.exists) {
      reason = 'Firestore document `config/gemini_config` does not exist';
      print('[GroqService] $reason');
    } else {
      final apiKey = (doc.data()?['groqApiKey'] as String?) ??
          (doc.data()?['apiKey'] as String?) ??
          '';
      if (apiKey.isNotEmpty) {
        print('[GroqService] Using key from Firestore config/gemini_config');
        final service = GroqRagService(groqApiKey: apiKey);
        unawaited(service.initializeKnowledgeBase());
        return service;
      }
      reason = 'Firestore doc exists but has no `groqApiKey` or `apiKey` field';
      print('[GroqService] $reason');
    }
  } on FirebaseException catch (e) {
    reason = 'Firestore blocked the read (${e.code}: ${e.message}). '
        'Your Firestore rules probably do not allow this user to read '
        '`config/gemini_config`.';
    print('[GroqService] $reason');
  } catch (e) {
    reason = 'Unexpected error reading Firestore: $e';
    print('[GroqService] $reason');
  }

  final service = GroqRagService(groqApiKey: '');
  service.lastFailureReason = reason;
  return service;
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
                'Hi! I\'m your Hydro Smart AI Assistant. Ask me anything about hydroponics, plant care, nutrient management, pest control, profitability, or farming techniques. I have access to a comprehensive knowledge base.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ]);

  /// Send message and get streaming response from the Groq RAG service
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
