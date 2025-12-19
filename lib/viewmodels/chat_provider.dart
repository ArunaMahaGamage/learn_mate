import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]);

  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  bool isLoading = false;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add User Message to UI immediately
    state = [...state, ChatMessage(text: text, isUser: true)];

    // Check Connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());

    // connectivity_plus returns a list in newer versions
    if (connectivityResult.contains(ConnectivityResult.none)) {
      state = [
        ...state,
        ChatMessage(
          text:
              "🚫 You are offline. Please check your internet connection to talk to the AI.",
          isUser: false,
        ),
      ];
      return; // Stop execution here
    }

    isLoading = true;
    state = [...state];

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

      final prompt =
          "You are a helpful educational assistant. Explain simply: $text";
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      state = [
        ...state,
        ChatMessage(text: response.text ?? "No response.", isUser: false),
      ];
    } catch (e) {
      state = [...state, ChatMessage(text: "Actual Error: $e", isUser: false)];
    } finally {
      isLoading = false;
      state = [...state];
    }
  }

  void clearChat() {
    state = [];
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((
  ref,
) {
  return ChatNotifier();
});
