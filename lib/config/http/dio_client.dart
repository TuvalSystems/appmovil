import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tuvalapp/config/environment/app_environment.dart';
import 'package:tuvalapp/infrastructure/services/key_value_storage_service.dart';

class DioClient {
  DioClient._();
  static final Dio instance = create();

  static Dio create({
    KeyValueStorageService? storage,
    Future<void> Function(String token)? onUnauthorized,
    void Function(String message)? log,
  }) {
    final tokenStorage = storage ?? KeyValueStorageService();
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEnvironment.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresAuth = options.extra['requiresAuth'] as bool? ?? true;

          if (requiresAuth) {
            final token = await tokenStorage.getKeyValue<String>('auth_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;
          final requiresAuth = request.extra['requiresAuth'] as bool? ?? true;
          final authorization = request.headers['Authorization'];
          if (error.response?.statusCode == 401 &&
              requiresAuth &&
              authorization is String &&
              authorization.startsWith('Bearer ')) {
            try {
              await onUnauthorized?.call(authorization.substring(7));
            } catch (_) {
              // Preserve the original HTTP error even if local cleanup fails.
            }
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode && AppEnvironment.enableHttpLogs) {
      final writeLog = log ?? (String message) => debugPrint(message);
      // Only fixed metadata: never headers, URLs/queries, payloads or exceptions.
      dio.interceptors.add(
        InterceptorsWrapper(
          onResponse: (response, handler) {
            writeLog('HTTP ${response.statusCode}');
            handler.next(response);
          },
          onError: (error, handler) {
            writeLog(
              'HTTP ${error.response?.statusCode ?? 0} (${error.type.name})',
            );
            handler.next(error);
          },
        ),
      );
    }

    return dio;
  }
}
