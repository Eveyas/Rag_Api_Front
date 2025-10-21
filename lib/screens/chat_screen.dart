import 'package:flutter/material.dart';
import '../models/chat_models.dart';
import '../services/api_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/loading_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _addWelcomeMessage();
  }

  void _checkConnection() async {
    final isConnected = await _apiService.checkHealth();
    setState(() {
      _isConnected = isConnected;
    });
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      role: 'assistant',
      content:
          '¡Hola! Soy tu asistente virtual del menú. '
          'Pregúntame sobre cualquier plato, ingrediente o precio del menú.',
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final request = ChatRequest(
        message: text,
        history: _messages
            .where((msg) => msg.role == 'user' || msg.role == 'assistant')
            .toList(),
      );

      final response = await _apiService.sendMessage(request);

      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: response.answer,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(assistantMessage);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      _showErrorDialog('Error al enviar mensaje: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar chat'),
        content: const Text(
          '¿Estás seguro de que quieres limpiar toda la conversación?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _messages.clear();
              });
              _addWelcomeMessage();
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.restaurant_menu, size: 24),
            SizedBox(width: 8),
            Text('Asistente de Menú'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearChat,
            tooltip: 'Limpiar chat',
          ),
          IconButton(
            icon: Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            onPressed: _checkConnection,
            tooltip: 'Estado de conexión',
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.orange[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: Colors.orange[800],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sin conexión con el servidor',
                    style: TextStyle(color: Colors.orange[800], fontSize: 12),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Pregunta sobre nuestro menú',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _messages.length) {
                        final message = _messages[index];
                        return MessageBubble(message: message);
                      } else {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: LoadingIndicator(),
                        );
                      }
                    },
                  ),
          ),
          ChatInput(onSendMessage: _sendMessage, isLoading: _isLoading),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _apiService.dispose();
    super.dispose();
  }
}

