import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthException implements Exception {
  final String message;
  const BiometricAuthException(this.message);
  @override
  String toString() => message;
}

class BiometricAuthService {
  final LocalAuthentication _authentication;
  BiometricAuthService({LocalAuthentication? authentication})
    : _authentication = authentication ?? LocalAuthentication();

  Future<bool> isAvailable() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return false;
    }
    try {
      return await _authentication.canCheckBiometrics &&
          (await _authentication.getAvailableBiometrics()).isNotEmpty;
    } on LocalAuthException {
      return false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _authentication.authenticate(
        localizedReason: 'Verifique su identidad para acceder a TUVAL',
        biometricOnly: true,
        persistAcrossBackgrounding: false,
      );
    } on LocalAuthException catch (e) {
      if (e.code == LocalAuthExceptionCode.userCanceled ||
          e.code == LocalAuthExceptionCode.systemCanceled ||
          e.code == LocalAuthExceptionCode.userRequestedFallback) {
        return false;
      }
      throw const BiometricAuthException(
        'La biometría no está disponible o está bloqueada. Use usuario y contraseña.',
      );
    } on PlatformException {
      throw const BiometricAuthException(
        'No se pudo verificar su identidad. Use usuario y contraseña.',
      );
    } on MissingPluginException {
      throw const BiometricAuthException(
        'Este dispositivo no permite acceso biométrico.',
      );
    }
  }
}
