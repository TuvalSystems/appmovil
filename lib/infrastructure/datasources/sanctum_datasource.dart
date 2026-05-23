import 'package:dio/dio.dart';
import 'package:tuvalapp/config/http/dio_client.dart';
import 'package:tuvalapp/config/http/endpoints/auth_endpoints.dart';
import 'package:tuvalapp/domain/datasources/auth_datasource.dart';
import 'package:tuvalapp/domain/entities/user.dart';
import 'package:tuvalapp/infrastructure/models/user_model.dart';

class SanctumDatasource extends AuthDatasource {
  final Dio _dio = DioClient.instance;

  @override
  Future<User> login(String username, String password) async {
    try {
      final response = await _dio.post(
        AuthEndpoints.login,
        data: {'username': username, 'password': password},
        options: Options(extra: {'requiresAuth': false}),
      );

      final Map<String, dynamic> responseData = Map<String, dynamic>.from(
        response.data,
      );

      if (responseData['success'] != true) {
        throw responseData['message'] ?? 'Error desconocido';
      }

      final userModel = UserModel.fromJson(responseData);

      if (!userModel.appAccess) {
        throw 'No tienes permisos para acceder a la aplicación móvil.';
      }

      return userModel.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw 'Credenciales incorrectas';
      }

      if (e.response?.statusCode == 403) {
        throw e.response?.data['message'] ??
            'Usuario sin permisos para acceder a la aplicación móvil.';
      }

      throw 'Error de red: ${e.message}';
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceAll('Exception: ', '')
          : e.toString();

      throw errorMessage;
    }
  }

  Future<User> getCurrentUser(String token) async {
    try {
      final response = await _dio.get(AuthEndpoints.user);

      final responseData = Map<String, dynamic>.from(response.data);

      if (responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Error verificando sesión');
      }

      final userModel = UserModel.fromJson({...responseData, 'token': token});

      if (!userModel.appAccess) {
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
        throw Exception(
          e.response?.data['message'] ??
              'Usuario sin permisos o requiere cambio de contraseña',
        );
      }

      throw Exception(
        'Error verificando sesión: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Error verificando sesión: $e');
    }
  }
}
