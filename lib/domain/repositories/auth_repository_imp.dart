import 'package:tuvalapp/domain/datasources/auth_datasource.dart';
import 'package:tuvalapp/domain/repositories/auth_repository.dart';
import 'package:tuvalapp/infrastructure/models/auth/login_response_model.dart';

class AuthRepositoryImp extends AuthRepository {
  final AuthDatasource datasource;
  AuthRepositoryImp(this.datasource);

  // @override
  Future<LoginResponseModel> login(String username, String password) {
    return datasource.login(username, password);
  }
}
