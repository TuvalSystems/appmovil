import 'package:dio/dio.dart';
import 'package:tuvalapp/config/environment/app_environment.dart';
import 'package:tuvalapp/infrastructure/services/key_value_storage_service.dart';

class DioClient {
  DioClient._();
  static final Dio instance = create();

  static Dio create({KeyValueStorageService? storage}) {
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
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );

    if (AppEnvironment.enableHttpLogs) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
    }

    return dio;
  }
}
