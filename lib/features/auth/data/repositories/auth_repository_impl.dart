import '../../domain/entities/usuario.dart';
import '../../domain/entities/token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/usuario_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Usuario> register(Usuario usuario, String password) async {
    final usuarioModel = UsuarioModel(
      usuarioIdPk: usuario.usuarioIdPk,
      correo: usuario.correo,
      nombre: usuario.nombre,
      apellidos: usuario.apellidos,
      numTelefono: usuario.numTelefono,
      fechaNacimiento: usuario.fechaNacimiento,
      verificado: usuario.verificado,
      fechaRegistroUsuario: usuario.fechaRegistroUsuario,
      rolUsuario: usuario.rolUsuario,
    );

    return await remoteDataSource.register(usuarioModel, password);
  }

  @override
  Future<Token> login(String correo, String password) async {
    return await remoteDataSource.login(correo, password);
  }

}