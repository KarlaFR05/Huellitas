import '../models/usuario_model.dart';
import '../models/token_model.dart';

abstract class AuthRemoteDataSource {
  Future<UsuarioModel> register(UsuarioModel usuario, String password);
  Future<TokenModel> login(String identificador, String password);
}