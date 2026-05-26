import 'package:dio/dio.dart';
import 'package:tuvalapp/config/http/api_exception.dart';
import 'package:tuvalapp/config/http/api_handler.dart';
import 'package:tuvalapp/config/http/dio_client.dart';
import 'package:tuvalapp/config/http/endpoints/auth_endpoints.dart';
import 'package:tuvalapp/domain/datasources/auth_datasource.dart';
import 'package:tuvalapp/domain/entities/user.dart';
import 'package:tuvalapp/infrastructure/models/user_model.dart';

class SanctumDatasource extends AuthDatasource {
  final Dio _dio = DioClient.instance;

  @override
  Future<User> login(String username, String password) async {
    final responseData = await ApiHandler.run(() {
      return _dio.post(
        AuthEndpoints.login,
        data: {'username': username, 'password': password},
        options: Options(extra: {'requiresAuth': false}),
      );
    });

    final userModel = UserModel.fromJson(responseData);
    if (!userModel.appAccess) {
      throw const ApiException(
        message: 'No tienes permisos para acceder a la aplicación móvil.',
        status: 403,
      );
    }
    return userModel.toEntity();
  }

  Future<User> getCurrentUser(String token) async {
    final responseData = await ApiHandler.run(() {
      return _dio.get(
        AuthEndpoints.user,
        options: Options(extra: {'requiresAuth': true}),
      );
    });
    final userModel = UserModel.fromJson({...responseData, 'token': token});

    if (!userModel.appAccess) {
      throw const ApiException(
        message:
            'Acceso denegado: Tu usuario ya no tiene permisos para usar la app.',
        status: 403,
      );
    }
    return userModel.toEntity();
  }

  Future<void> changePassword({required String password}) async {
    await ApiHandler.run(() {
      return _dio.post(
        AuthEndpoints.changePassword,
        data: {'password': password},
      );
    });
  }
}
