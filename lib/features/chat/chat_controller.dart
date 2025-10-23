import 'package:flutter/material.dart';
import '../../core/models.dart';
import 'chat_repository.dart';
import '../../core/api_client.dart';

class ChatController with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  final ChatRepository _chatRepository;

  ChatController({required ApiClient apiClient})
      : _chatRepository = ChatRepository(apiClient: apiClient);

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty || _isLoading) return;

    // Limpiar error previo
    _error = null;
    notifyListeners();

    // Agregar mensaje del usuario
    final userMessage = ChatMessage(
      role: 'user',
      content: message.trim(),
    );
    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      // Llamar a la API
      final response = await _chatRepository.ask(message, _messages);

      // Agregar respuesta del asistente
      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: response,
      );
      _messages.add(assistantMessage);
    } catch (e) {
      _error = e.toString();

      // Agregar mensaje de error
      final errorMessage = ChatMessage(
        role: 'assistant',
        content:
            'Lo siento, hubo un error al procesar tu solicitud. Por favor, intenta de nuevo.',
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}
