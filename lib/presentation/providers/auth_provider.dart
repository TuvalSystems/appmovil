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
  final Future<void> Function()? onSessionEnded;
  int _sessionEpoch = 0;
  bool _passwordLogin = false;
  Future<void>? _endingSession;
  Future<void> _storageQueue = Future<void>.value();
  Future<void> _persist(Future<void> Function() action) {
    final operation = _storageQueue.then((_) => action());
    _storageQueue = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  bool _current(int epoch) => !_disposed && epoch == _sessionEpoch;
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
    this.onSessionEnded,
    SanctumDatasource? sanctumDatasource,
    BiometricAuthService? biometricAuthService,
  }) : sanctumDatasource = sanctumDatasource ?? SanctumDatasource(),
       biometricAuthService = biometricAuthService ?? BiometricAuthService() {
    initialization = checkAuthStatus();
  }

  // Login
  Future<bool> login(String username, String password) async {
    if (isPosting || _endingSession != null) return false;
    final epoch = ++_sessionEpoch;
    _passwordLogin = true;
    isPosting = true;
    errorMessage = null;
    _notify();

    try {
      final loginResponse = await sanctumDatasource.login(username, password);
      if (!_current(epoch)) return false;
      await onSessionEnded?.call();
      if (!_current(epoch)) return false;

      if (loginResponse.token.isEmpty) {
        throw Exception('El backend no devolvió token');
      }

      // A new password login must not inherit another account's opt-in.
      await _persist(() async {
        if (!_current(epoch)) return;
        await keyValueStorageService.removeKey(biometricEnabledKey);
        if (!_current(epoch)) return;
        await keyValueStorageService.setKeyValue(
          'auth_token',
          loginResponse.token,
        );
      });

      if (!_current(epoch)) return false;
      biometricEnabled = false;
      user = loginResponse.user;
      appMenu = loginResponse.appMenu;
      authStatus = loginResponse.user.mustChangePassword
          ? AuthStatus.mustChangePassword
          : AuthStatus.authenticated;

      isPosting = false;
      errorMessage = null;
      _notify();

      return true;
    } catch (e) {
      if (!_current(epoch)) return false;
      await _persist(() async {
        if (!_current(epoch)) return;
        await keyValueStorageService.removeKey('auth_token');
        await keyValueStorageService.removeKey(biometricEnabledKey);
      });
      if (!_current(epoch)) return false;
      biometricEnabled = false;

      isPosting = false;
      user = null;
      appMenu = null;
      authStatus = AuthStatus.notAuthenticated;
      errorMessage = _cleanError(e);
      _notify();

      return false;
    } finally {
      if (_current(epoch)) {
        _passwordLogin = false;
        isPosting = false;
        _notify();
      }
    }
  }

  // Invalidate in-memory state immediately; finish cleanup before another login.
  Future<void> logout([String? message]) =>
      _endingSession ??= _endSession(message);

  Future<void> _endSession(String? message) async {
    _sessionEpoch++;
    _passwordLogin = false;
    biometricEnabled = false;
    user = null;
    appMenu = null;
    isPosting = true;
    errorMessage = message;
    authStatus = AuthStatus.notAuthenticated;
    _notify();
    try {
      await Future.wait([
        if (onSessionEnded != null) onSessionEnded!(),
        _persist(
          () => Future.wait([
            keyValueStorageService.removeKey('auth_token'),
            keyValueStorageService.removeKey(biometricEnabledKey),
          ]),
        ),
      ]);
    } finally {
      isPosting = false;
      _endingSession = null;
      _notify();
    }
  }

  Future<void> expireSession(String rejectedToken) async {
    if (_disposed || _passwordLogin || rejectedToken.isEmpty) return;
    final epoch = _sessionEpoch;
    final currentToken = await keyValueStorageService.getKeyValue<String>(
      'auth_token',
    );
    if (!_current(epoch) || currentToken != rejectedToken) return;
    await logout('Su sesión ha vencido. Ingrese nuevamente.');
  }

  // An opted-in session remains locked until the system verifies biometrics.
  Future<void> checkAuthStatus() async {
    final epoch = _sessionEpoch;
    authStatus = AuthStatus.checking;
    errorMessage = null;
    _notify();
    try {
      final available = await biometricAuthService.isAvailable();
      if (!_current(epoch)) return;
      biometricAvailable = available;
      final enabled =
          await keyValueStorageService.getKeyValue<String>(
            biometricEnabledKey,
          ) ==
          'true';
      if (!_current(epoch)) return;
      biometricEnabled = enabled;
      final token = await keyValueStorageService.getKeyValue<String>(
        'auth_token',
      );
      if (!_current(epoch)) return;
      if (token == null || token.isEmpty) {
        await _persist(() async {
          if (_current(epoch)) {
            await keyValueStorageService.removeKey(biometricEnabledKey);
          }
        });
        if (!_current(epoch)) return;
        biometricEnabled = false;
        _lockSession();
      } else if (biometricEnabled) {
        _lockSession();
      } else {
        await _restoreSession(token);
      }
    } catch (e) {
      if (_current(epoch)) _lockSession(_cleanError(e));
    }
    _notify();
  }

  Future<void> _restoreSession(String token) async {
    final epoch = _sessionEpoch;
    try {
      final userResponse = await sanctumDatasource.getCurrentUser(token);
      if (!_current(epoch)) return;
      final menuResponse = await sanctumDatasource.getMobileMenu(token);
      if (!_current(epoch)) return;
      user = userResponse;
      appMenu = menuResponse;
      errorMessage = null;
      authStatus = userResponse.mustChangePassword
          ? AuthStatus.mustChangePassword
          : AuthStatus.authenticated;
    } on ApiException catch (e) {
      if (!_current(epoch)) return;
      if (e.status == 401 || e.status == 403) {
        await logout(
          'Su sesión ya no es válida. Ingrese con usuario y contraseña.',
        );
      } else {
        _lockSession(e.message);
      }
    } catch (e) {
      if (_current(epoch)) _lockSession(_cleanError(e));
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
    final epoch = _sessionEpoch;
    isPosting = true;
    errorMessage = null;
    _notify();
    try {
      final authenticated = await biometricAuthService.authenticate();
      if (!_current(epoch)) return false;
      if (!authenticated) {
        _lockSession(
          'Verificación cancelada. Puede reintentar o usar sus credenciales.',
        );
        return false;
      }
      final token = await keyValueStorageService.getKeyValue<String>(
        'auth_token',
      );
      if (!_current(epoch)) return false;
      if (token == null || token.isEmpty) {
        await logout(
          'Ingrese con usuario y contraseña para activar nuevamente la biometría.',
        );
        return false;
      }
      await _restoreSession(token);
      if (!_current(epoch)) return false;
      return authStatus == AuthStatus.authenticated ||
          authStatus == AuthStatus.mustChangePassword;
    } catch (e) {
      if (_current(epoch)) _lockSession(_cleanError(e));
      return false;
    } finally {
      if (_current(epoch)) {
        isPosting = false;
        _notify();
      }
    }
  }

  Future<bool> setBiometricEnabled(bool enabled) async {
    if (isPosting || authStatus != AuthStatus.authenticated) return false;
    final epoch = _sessionEpoch;
    isPosting = true;
    errorMessage = null;
    _notify();
    try {
      if (enabled) {
        biometricAvailable = await biometricAuthService.isAvailable();
        if (!_current(epoch)) return false;
        if (!biometricAvailable) {
          errorMessage =
              'Configure una huella o biometría en los ajustes del dispositivo.';
          return false;
        }
        if (!await biometricAuthService.authenticate()) return false;
        if (!_current(epoch)) return false;
        final token = await keyValueStorageService.getKeyValue<String>(
          'auth_token',
        );
        if (!_current(epoch)) return false;
        if (token == null || token.isEmpty) return false;
        await _persist(() async {
          if (_current(epoch)) {
            await keyValueStorageService.setKeyValue(
              biometricEnabledKey,
              'true',
            );
          }
        });
      } else {
        await _persist(() async {
          if (_current(epoch)) {
            await keyValueStorageService.removeKey(biometricEnabledKey);
          }
        });
      }
      if (!_current(epoch)) return false;
      biometricEnabled = enabled;
      return true;
    } catch (e) {
      if (_current(epoch)) errorMessage = _cleanError(e);
      return false;
    } finally {
      if (_current(epoch)) {
        isPosting = false;
        _notify();
      }
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
    if (isPosting) return false;
    final epoch = _sessionEpoch;
    isPosting = true;
    errorMessage = null;
    _notify();

    try {
      await sanctumDatasource.changePassword(password: password);
      if (!_current(epoch)) return false;

      _setPasswordAsChanged();

      isPosting = false;
      errorMessage = null;
      _notify();
      return true;
    } catch (e) {
      if (!_current(epoch)) return false;
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
