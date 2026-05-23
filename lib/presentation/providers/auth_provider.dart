import 'package:flutter/material.dart';
import 'package:tuvalapp/domain/entities/user.dart';
import 'package:tuvalapp/infrastructure/datasources/sanctum_datasource.dart';
import 'package:tuvalapp/infrastructure/services/key_value_storage_service.dart';

enum AuthStatus {
  checking,
  authenticated,
  notAuthenticated,
  mustChangePassword,
}

class AuthProvider extends ChangeNotifier {
  final KeyValueStorageService keyValueStorageService;
  final SanctumDatasource sanctumDatasource = SanctumDatasource();

  AuthStatus authStatus = AuthStatus.checking;
  User? user;
  bool isPosting = false;
  String? errorMessage;

  AuthProvider({required this.keyValueStorageService}) {
    checkAuthStatus();
  }

  // Login
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

      authStatus = userResponse.mustChangePassword
          ? AuthStatus.mustChangePassword
          : AuthStatus.authenticated;

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

  // Logout
  Future<void> logout([String? message]) async {
    await keyValueStorageService.removeKey('auth_token');

    user = null;
    isPosting = false;
    errorMessage = message;
    authStatus = AuthStatus.notAuthenticated;

    notifyListeners();
  }

  // Check Auth Status
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

      authStatus = userResponse.mustChangePassword
          ? AuthStatus.mustChangePassword
          : AuthStatus.authenticated;

      notifyListeners();
    } catch (e) {
      await logout();
    }
  }

  // Llamar esto después de cambiar correctamente la contraseña
  void markPasswordAsChanged() {
    if (user == null) return;

    user = User(
      id: user!.id,
      loginId: user!.loginId,
      fullName: user!.fullName,
      appProfileId: user!.appProfileId,
      appProfileName: user!.appProfileName,
      status: user!.status,
      token: user!.token,
      appAccess: user!.appAccess,
      mustChangePassword: false,
    );

    authStatus = AuthStatus.authenticated;
    errorMessage = null;

    notifyListeners();
  }

  String _cleanError(Object e) {
    return e.toString().replaceFirst('Exception: ', '');
  }


//cambiar contraseña
Future<bool> changePassword({
  required String currentPassword,
  required String password,
  required String passwordConfirmation,
}) async {
  isPosting = true;
  errorMessage = null;
  notifyListeners();

  try {
    await sanctumDatasource.changePassword(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    if (user != null) {
      user = User(
        id: user!.id,
        loginId: user!.loginId,
        fullName: user!.fullName,
        appProfileId: user!.appProfileId,
        appProfileName: user!.appProfileName,
        status: user!.status,
        token: user!.token,
        appAccess: user!.appAccess,
        mustChangePassword: false,
      );
    }

    authStatus = AuthStatus.authenticated;
    isPosting = false;
    errorMessage = null;
    notifyListeners();

    return true;
  } catch (e) {
    isPosting = false;
    errorMessage = _cleanError(e);
    notifyListeners();

    return false;
  }
}

}
