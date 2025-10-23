import 'package:dio/dio.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      // Para Flutter web
      baseUrl: _getBaseUrl(),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // Interceptor para logs
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  String _getBaseUrl() {
    // Detectar si estamos en web
    bool isWeb = identical(0, 0.0); // Hack para detectar web en Flutter

    if (isWeb) {
      return 'http://localhost:8000'; // Para desarrollo web
    } else {
      return 'http://10.0.2.2:8000'; // Para Android
    }
  }

  Future<Response> post(String path, dynamic data) async {
    try {
      return await _dio.post(
        path,
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Timeout de conexión');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Error de conexión con el servidor');
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception('Error del servidor: ${e.response?.statusCode}');
      } else {
        throw Exception('Error: ${e.message}');
      }
    }
  }

  Future<Response> get(String path) async {
    try {
      return await _dio.get(path);
    } on DioException catch (e) {
      throw Exception('Error: ${e.message}');
    }
  }

  // Método para cambiar la URL base manualmente
  void updateBaseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
  }
}
