import '../models/usuario_model.dart';
import '../models/token_model.dart';
import '../models/usuario_publico_model.dart';

abstract class AuthRemoteDataSource {
  Future<UsuarioModel> register(UsuarioModel usuario, String password);
  Future<TokenModel> login(String identificador, String password);
  Future<UsuarioPublicoModel> obtenerPerfilPublico(int usuarioId);
  Future<void> enviarCodigo(String correo);
  Future<void> confirmarCodigo(String correo, String codigo);
}
