import 'package:tuvalapp/domain/entities/user.dart';

abstract class AuthDatasource {
  Future<User> login(String username, String password);
}