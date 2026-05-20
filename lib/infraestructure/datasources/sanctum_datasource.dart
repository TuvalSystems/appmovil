import 'package:dio/dio.dart';
import 'package:tuvalapp/config/http/api_endpoints.dart';
import 'package:tuvalapp/config/http/dio_client.dart';
import 'package:tuvalapp/domain/datasources/auth_datasource.dart';
import 'package:tuvalapp/domain/entities/user.dart';
import 'package:tuvalapp/infraestructure/models/user_model.dart';

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
      final errorMessage = e is Exception
          ? e.toString().replaceAll('Exception: ', '')
          : e.toString();
      throw errorMessage;
    }
  }

  Future<User> getCurrentUser(String token) async {
    try {
      final response = await _dio.get(AuthEndpoints.user);

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
