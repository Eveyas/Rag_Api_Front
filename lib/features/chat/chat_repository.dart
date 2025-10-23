import '../../core/api_client.dart';
import '../../core/models.dart';

class ChatRepository {
  final ApiClient apiClient;

  ChatRepository({required this.apiClient});

  Future<String> ask(String message, List<ChatMessage> history) async {
    try {
      final request = ChatRequest(message: message, history: history);

      final response = await apiClient.post(
        '/chat',
        request.toJson(),
      );

      if (response.statusCode == 200) {
        final chatResponse = ChatResponse.fromJson(response.data);
        return chatResponse.answer;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> healthCheck() async {
    try {
      final response = await apiClient.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
