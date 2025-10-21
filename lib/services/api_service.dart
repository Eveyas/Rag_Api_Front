import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  // Para producción, cambia a tu URL real:
  // static const String baseUrl = 'https://tu-api.com';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  Future<ChatResponse> sendMessage(ChatRequest request) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return ChatResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Error de conexión: $e');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}