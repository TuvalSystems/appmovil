import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyValueStorageService {
  final _storage = FlutterSecureStorage();

  //guardar el token
  Future<void> setKeyValue<T>(String key, T value) async {
    await _storage.write(key: key, value: value.toString());
  }

  //leer el token
  Future<T?> getKeyValue<T>(String key) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return value as T;
  }

  //borrar el token
  Future<void> removeKey(String key) async {
    await _storage.delete(key: key);
  }
}
