import '../../domain/entities/usuario.dart';
import '../../domain/entities/token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/usuario_model.dart';
import '../../domain/entities/usuario_publico.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Usuario> register(
    Usuario usuario,
    String password, {
    Map<String, dynamic>? organizacion, 
  }) async {
    final usuarioModel = UsuarioModel(
      usuarioIdPk: usuario.usuarioIdPk,
      correo: usuario.correo,
      nombre: usuario.nombre,
      apellidos: usuario.apellidos,
      nombreUsuario: usuario.nombreUsuario,
      numTelefono: usuario.numTelefono,
      fechaNacimiento: usuario.fechaNacimiento,
      verificado: usuario.verificado,
      fechaRegistroUsuario: usuario.fechaRegistroUsuario,
      rolUsuario: usuario.rolUsuario,
    );

    return await remoteDataSource.register(
      usuarioModel,
      password,
      organizacion: organizacion,
    );
  }

  @override
  Future<Token> login(String identificador, String password) async {
    return await remoteDataSource.login(identificador, password);
  }

  @override
  Future<UsuarioPublico> obtenerPerfilPublico(int usuarioId) async {
    return await remoteDataSource.obtenerPerfilPublico(usuarioId);
  }

  @override
  Future<void> enviarCodigo(String correo) =>
      remoteDataSource.enviarCodigo(correo);

  @override
  Future<void> confirmarCodigo(String correo, String codigo) =>
      remoteDataSource.confirmarCodigo(correo, codigo);
}