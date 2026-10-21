import 'package:tuvalapp/infrastructure/services/biometric_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:tuvalapp/config/http/api_exception.dart';
import 'package:tuvalapp/domain/entities/user.dart';
import 'package:tuvalapp/infrastructure/datasources/sanctum_datasource.dart';
import 'package:tuvalapp/infrastructure/models/menu/app_menu_model.dart';
import 'package:tuvalapp/infrastructure/services/key_value_storage_service.dart';

enum AuthStatus {
  checking,
  authenticated,
  notAuthenticated,
  mustChangePassword,
}

class AuthProvider extends ChangeNotifier {
  final KeyValueStorageService keyValueStorageService;
  final SanctumDatasource sanctumDatasource;
  final BiometricAuthService biometricAuthService;
  static const biometricEnabledKey = 'biometric_enabled';
  bool biometricAvailable = false;
  bool biometricEnabled = false;
  bool _disposed = false;
  late final Future<void> initialization;
  bool get canLoginWithBiometrics => biometricEnabled && biometricAvailable;

  AuthStatus authStatus = AuthStatus.checking;
  User? user;
  AppMenu? appMenu;
  bool isPosting = false;
  String? errorMessage;

  AuthProvider({
    required this.keyValueStorageService,
    SanctumDatasource? sanctumDatasource,
    BiometricAuthService? biometricAuthService,
  }) : sanctumDatasource = sanctumDatasource ?? SanctumDatasource(),
       biometricAuthService = biometricAuthService ?? BiometricAuthService() {
    initialization = checkAuthStatus();
  }

  // Login
  Future<bool> login(String username, String password) async {
    if (isPosting) return false;
    isPosting = true;
    errorMessage = null;
    _notify();

    try {
      final loginResponse = await sanctumDatasource.login(username, password);

      if (loginResponse.token.isEmpty) {
        throw Exception('El backend no devolvió token');
      }

      // A new password login must not inherit another account's opt-in.
      await keyValueStorageService.removeKey(biometricEnabledKey);
      biometricEnabled = false;
      user = loginResponse.user;
      appMenu = loginResponse.appMenu;

      await keyValueStorageService.setKeyValue(
        'auth_token',
        loginResponse.token,
      );

      authStatus = loginResponse.user.mustChangePassword
          ? AuthStatus.mustChangePassword
          : AuthStatus.authenticated;

      isPosting = false;
      errorMessage = null;
      _notify();

      return true;
    } catch (e) {
      await keyValueStorageService.removeKey('auth_token');
      await keyValueStorageService.removeKey(biometricEnabledKey);
      biometricEnabled = false;

      isPosting = false;
      user = null;
      appMenu = null;
      authStatus = AuthStatus.notAuthenticated;
      errorMessage = _cleanError(e);
      _notify();

      return false;
    }
  }

  // Logout
  Future<void> logout([String? message]) async {
    await keyValueStorageService.removeKey('auth_token');
    await keyValueStorageService.removeKey(biometricEnabledKey);
    biometricEnabled = false;

    user = null;
    appMenu = null;
    isPosting = false;
    errorMessage = message;
    authStatus = AuthStatus.notAuthenticated;

    _notify();
  }

  // An opted-in session remains locked until the system verifies biometrics.
  Future<void> checkAuthStatus() async {
    authStatus = AuthStatus.checking;
    errorMessage = null;
    _notify();
    try {
      biometricAvailable = await biometricAuthService.isAvailable();
      biometricEnabled =
          await keyValueStorageService.getKeyValue<String>(
            biometricEnabledKey,
          ) ==
          'true';
      final token = await keyValueStorageService.getKeyValue<String>(
        'auth_token',
      );
      if (token == null || token.isEmpty) {
        await keyValueStorageService.removeKey(biometricEnabledKey);
        biometricEnabled = false;
        _lockSession();
      } else if (biometricEnabled) {
        _lockSession();
      } else {
        await _restoreSession(token);
      }
    } catch (e) {
      _lockSession(_cleanError(e));
    }
    _notify();
  }

  Future<void> _restoreSession(String token) async {
    try {
      final userResponse = await sanctumDatasource.getCurrentUser(token);
      final menuResponse = await sanctumDatasource.getMobileMenu(token);
      user = userResponse;
      appMenu = menuResponse;
      errorMessage = null;
      authStatus = userResponse.mustChangePassword
          ? AuthStatus.mustChangePassword
          : AuthStatus.authenticated;
    } on ApiException catch (e) {
      if (e.status == 401 || e.status == 403) {
        await logout(
          'Su sesión ya no es válida. Ingrese con usuario y contraseña.',
        );
      } else {
        _lockSession(e.message);
      }
    } catch (e) {
      _lockSession(_cleanError(e));
    }
  }

  void _lockSession([String? message]) {
    user = null;
    appMenu = null;
    authStatus = AuthStatus.notAuthenticated;
    errorMessage = message;
  }

  Future<bool> loginWithBiometrics() async {
    if (isPosting || !canLoginWithBiometrics) return false;
    isPosting = true;
    errorMessage = null;
    _notify();
    try {
      if (!await biometricAuthService.authenticate()) {
        _lockSession(
          'Verificación cancelada. Puede reintentar o usar sus credenciales.',
        );
        return false;
      }
      final token = await keyValueStorageService.getKeyValue<String>(
        'auth_token',
      );
      if (token == null || token.isEmpty) {
        await logout(
          'Ingrese con usuario y contraseña para activar nuevamente la biometría.',
        );
        return false;
      }
      await _restoreSession(token);
      return authStatus == AuthStatus.authenticated ||
          authStatus == AuthStatus.mustChangePassword;
    } catch (e) {
      _lockSession(_cleanError(e));
      return false;
    } finally {
      isPosting = false;
      _notify();
    }
  }

  Future<bool> setBiometricEnabled(bool enabled) async {
    if (isPosting || authStatus != AuthStatus.authenticated) return false;
    isPosting = true;
    errorMessage = null;
    _notify();
    try {
      if (enabled) {
        biometricAvailable = await biometricAuthService.isAvailable();
        if (!biometricAvailable) {
          errorMessage =
              'Configure una huella o biometría en los ajustes del dispositivo.';
          return false;
        }
        if (!await biometricAuthService.authenticate()) return false;
        final token = await keyValueStorageService.getKeyValue<String>(
          'auth_token',
        );
        if (token == null || token.isEmpty) return false;
        await keyValueStorageService.setKeyValue(biometricEnabledKey, 'true');
      } else {
        await keyValueStorageService.removeKey(biometricEnabledKey);
      }
      biometricEnabled = enabled;
      return true;
    } catch (e) {
      errorMessage = _cleanError(e);
      return false;
    } finally {
      isPosting = false;
      _notify();
    }
  }

  // Llamar esto después de cambiar correctamente la contraseña
  void markPasswordAsChanged() {
    _setPasswordAsChanged();
    _notify();
  }

  String _cleanError(Object e) {
    if (e is ApiException) {
      return e.message;
    }
    return e.toString().replaceFirst('Exception: ', '');
  }

  //cambiar contraseña
  Future<bool> changePassword({required String password}) async {
    isPosting = true;
    errorMessage = null;
    _notify();

    try {
      await sanctumDatasource.changePassword(password: password);

      _setPasswordAsChanged();

      isPosting = false;
      errorMessage = null;
      _notify();
      return true;
    } catch (e) {
      isPosting = false;
      errorMessage = _cleanError(e);
      _notify();

      return false;
    }
  }

  void _setPasswordAsChanged() {
    if (user == null) return;

    user = user!.copyWith(mustChangePassword: false);

    authStatus = AuthStatus.authenticated;
    errorMessage = null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
