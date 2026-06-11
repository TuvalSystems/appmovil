import 'package:tuvalapp/infrastructure/models/auth/login_response_model.dart';

abstract class AuthDatasource {
  Future<LoginResponseModel> login(String username, String password);
}