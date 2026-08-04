import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _usuarioKey = 'usuario_data';

  Future<void> guardarToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> obtenerToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> guardarUsuario(String usuarioJson) async {
    await _storage.write(key: _usuarioKey, value: usuarioJson);
  }

  Future<String?> obtenerUsuarioJson() async {
    return await _storage.read(key: _usuarioKey);
  }

  Future<void> borrarToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usuarioKey);
  }
}
