import 'package:tuvalapp/domain/datasources/auth_datasource.dart';
import 'package:tuvalapp/domain/entities/user.dart';
import 'package:tuvalapp/domain/repositories/auth_repository.dart';

class AuthRepositoryImp extends AuthRepository {
  final AuthDatasource datasource;
  AuthRepositoryImp(this.datasource);

  // @override
  Future<User> login(String username, String password) {
    return datasource.login(username, password);
  }
}
