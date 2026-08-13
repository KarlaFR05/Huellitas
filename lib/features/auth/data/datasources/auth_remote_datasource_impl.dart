import 'package:dio/dio.dart';
import '../models/usuario_model.dart';
import '../models/token_model.dart';
import 'auth_remote_datasource.dart';
import '../models/usuario_publico_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UsuarioModel> register(UsuarioModel usuario, String password) async {
    try {
      final body = {
        'correo': usuario.correo,
        'nombre_usuario': usuario.nombreUsuario,
        'contrasenia': password,
        'nombre': usuario.nombre,
        'apellidos': usuario.apellidos,
        'num_telefono': usuario.numTelefono,
        'fecha_nacimiento': usuario.fechaNacimiento.toIso8601String().split(
          'T',
        )[0],
        'calle': null,
        'colonia': null,
        'cp': null,
        'ciudad': null,
        'identificacion_frontal': null,
        'identificacion_trasera': null,
      };

      final response = await dio.post('/usuarios/register', data: body);
      return UsuarioModel.fromJson(response.data);
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('ERROR DETAIL: ${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<TokenModel> login(String identificador, String password) async {
    try {
      final body = {'identificador': identificador, 'contrasenia': password};

      final response = await dio.post('/usuarios/login', data: body);
      return TokenModel.fromJson(response.data);
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('ERROR DETAIL: ${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<UsuarioPublicoModel> obtenerPerfilPublico(int usuarioId) async {
    try {
      final response = await dio.get('/usuarios/$usuarioId');
      return UsuarioPublicoModel.fromJson(response.data);
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('ERROR DETAIL: ${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<void> enviarCodigo(String correo) async {
    try {
      await dio.post('/usuarios/enviar-codigo', data: {'correo': correo});
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('ERROR DETAIL: ${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<void> confirmarCodigo(String correo, String codigo) async {
    try {
      await dio.post(
        '/usuarios/confirmar-codigo',
        data: {'correo': correo, 'codigo': codigo},
      );
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('ERROR DETAIL: ${e.response?.data}');
      rethrow;
    }
  }
}
