import 'package:flutter/material.dart';
import 'package:tuvalapp/domain/entities/user.dart';
import 'package:tuvalapp/infrastructure/datasources/sanctum_datasource.dart';
import 'package:tuvalapp/infrastructure/services/key_value_storage_service.dart';

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthProvider extends ChangeNotifier {
  final KeyValueStorageService keyValueStorageService;
  final sanctumDatasource = SanctumDatasource();
  AuthStatus authStatus = AuthStatus.checking;
  User? user;
  bool isPosting = false;
  String? errorMessage;

  AuthProvider({required this.keyValueStorageService}) {
    checkAuthStatus();
  }
  //login
  Future<bool> login(String username, String password) async {
    isPosting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final userResponse = await sanctumDatasource.login(username, password);

      if (userResponse.token.isEmpty) {
        throw Exception('El backend no devolvió token');
      }

      user = userResponse;
      await keyValueStorageService.setKeyValue(
        'auth_token',
        userResponse.token,
      );

      authStatus = AuthStatus.authenticated;
      isPosting = false;
      errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      await keyValueStorageService.removeKey('auth_token');

      isPosting = false;
      user = null;
      authStatus = AuthStatus.notAuthenticated;
      errorMessage = _cleanError(e);
      notifyListeners();
      return false;
    }
  }

  //logout
  Future<void> logout([String? message]) async {
    await keyValueStorageService.removeKey('auth_token');
    user = null;
    isPosting = false;
    errorMessage = message;
    authStatus = AuthStatus.notAuthenticated;
    notifyListeners();
  }

  //checkAuthStatus
  Future<void> checkAuthStatus() async {
    authStatus = AuthStatus.checking;
    errorMessage = null;
    notifyListeners();

    final token = await keyValueStorageService.getKeyValue<String>(
      'auth_token',
    );

    if (token == null || token.isEmpty) {
      user = null;
      isPosting = false;
      authStatus = AuthStatus.notAuthenticated;
      notifyListeners();
      return;
    }
    try {
      final userResponse = await sanctumDatasource.getCurrentUser(token);
      user = userResponse;
      isPosting = false;
      errorMessage = null;
      authStatus = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      await logout();
    }
  }

  String _cleanError(Object e) {
    return e.toString().replaceFirst('Exception: ', '');
  }
}
