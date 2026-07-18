import '../entities/usuario.dart';
import '../entities/token.dart';
import '../entities/usuario_publico.dart';

abstract class AuthRepository {
  Future<Usuario> register(Usuario usuario, String password);
  Future<Token> login(String identificador, String password);
  Future<UsuarioPublico> obtenerPerfilPublico(int usuarioId);
}
