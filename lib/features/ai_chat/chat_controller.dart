import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_model.dart';

final chatMessagesProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier()
      : super([
          ChatMessage(
            id: '1',
            text:
                'Hi! I\'m your Hydro Smart AI Assistant. How can I help you today?',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ]);

  final Map<String, String> _responses = {
    'yellow':
        'Yellowing leaves could indicate nitrogen deficiency. Check your nutrient levels and ensure proper EC levels.',
    'ph':
        'The optimal pH for most hydroponic crops is between 5.5 and 6.5. Check your pH meter regularly.',
    'temperature':
        'Most leafy greens prefer temperatures between 15-22°C. Maintain stable temperature for best results.',
    'water':
        'Change your water reservoir every 2-3 weeks to prevent nutrient imbalance and disease.',
    'light':
        'Provide 12-16 hours of light daily for most crops. Use full spectrum LED lights for best growth.',
    'mold':
        'Mold or algae growth indicates high humidity and poor circulation. Increase ventilation and reduce humidity.',
    'cost':
        'Typical monthly costs include electricity, nutrients, water, and labor. Your current expenses are around ₹2800.',
    'profit':
        'With proper management, you can achieve 40-50% profit margins on leafy greens in hydroponics.',
  };

  void addMessage(String text) {
    final userMessage = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = [...state, userMessage];

    // Generate AI response
    final response = _generateResponse(text);
    final aiMessage = ChatMessage(
      id: DateTime.now().toString(),
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );

    state = [...state, aiMessage];
  }

  String _generateResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    for (var key in _responses.keys) {
      if (lowerMessage.contains(key)) {
        return _responses[key]!;
      }
    }

    return 'That\'s a great question! I\'m still learning about that topic. Try asking about yellowing leaves, pH levels, temperature, water changes, lighting, mold prevention, costs, or expected profits.';
  }
}
