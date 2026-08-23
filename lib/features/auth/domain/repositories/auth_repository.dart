import '../entities/usuario.dart';
import '../entities/token.dart';
import '../entities/usuario_publico.dart';

abstract class AuthRepository {
  Future<Usuario> register(
    Usuario usuario,
    String password, {
    Map<String, dynamic>? organizacion, 
  });
  Future<Token> login(String identificador, String password);
  Future<UsuarioPublico> obtenerPerfilPublico(int usuarioId);
  Future<void> enviarCodigo(String correo);
  Future<void> confirmarCodigo(String correo, String codigo);
}