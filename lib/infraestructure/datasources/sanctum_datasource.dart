import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:tuvalapp/domain/datasources/auth_datasource.dart';
import 'package:tuvalapp/domain/entities/user.dart';
import 'package:tuvalapp/infraestructure/models/user_model.dart';

class SanctumDatasource extends AuthDatasource {
  // final _storage = KeyValueStorageService();
  final _dio = Dio(
    BaseOptions(
      baseUrl: 'http://tuvalapi.cosenco.ec/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-type': 'application/json',
      },
    ),
  )..interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  @override
  Future<User> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );
      debugPrint('--- DATA RECIBIDA ---');
      debugPrint(response.data.toString());
      if (response.data['success'] == true) {
        final bool hasAccess =
            response.data['data']['user']['app_access'] ?? false;
        if (!hasAccess) {
          throw 'No tienes permisos para acceder a la aplicación móvil.';
        }
        final userModel = UserModel.fromJson(response.data);
        return userModel.toEntity();
      } else {
        throw response.data['message'] ?? 'Error desconocido';
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw 'Credenciales incorrectas';
      }
      throw 'Error de red: ${e.message}';
    } catch (e) {
      final errorMessage =
          e
              is Exception 
          ? e.toString().replaceAll('Exception: ', '')
          : e.toString(); 
      throw errorMessage;
    }
  }

  Future<User> getCurrentUser(String token) async {
    try {
      final response = await _dio.get(
        '/user',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      final data = response.data is Map && response.data['user'] != null
          ? response.data['user']
          : response.data;

      final userModel = UserModel.fromJson({...data, 'token': token});
      if (userModel.appAccess == false) {
        throw Exception(
          'Acceso denegado: Tu usuario ya no tiene permisos para usar la app.',
        );
      }
      return userModel.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Token inválido o expirado');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('Usuario sin permisos o requiere cambio de contraseña');
      }

      throw Exception(
        'Error verificando sesión: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Error verificando sesión: $e');
    }
  }
}
