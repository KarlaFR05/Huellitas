import '../entities/usuario.dart';
import '../entities/token.dart';

abstract class AuthRepository {
  Future<Usuario> register(Usuario usuario, String password);
  Future<Token> login(String correo, String password);
}