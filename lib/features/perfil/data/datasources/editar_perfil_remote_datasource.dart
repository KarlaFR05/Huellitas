import 'dart:io';
import 'package:dio/dio.dart';
import '../../../auth/data/models/usuario_model.dart';

class EditarPerfilRemoteDataSource {
  final Dio dio;
  EditarPerfilRemoteDataSource(this.dio);

  Future<UsuarioModel> editarPerfil({
    String? nombre,
    String? apellidos,
    String? numTelefono,
    String? calle,
    String? colonia,
    String? cp,
    String? ciudad,
  }) async {
    final body = {
      if (nombre != null) 'nombre': nombre,
      if (apellidos != null) 'apellidos': apellidos,
      if (numTelefono != null) 'num_telefono': numTelefono,
      if (calle != null) 'calle': calle,
      if (colonia != null) 'colonia': colonia,
      if (cp != null) 'cp': cp,
      if (ciudad != null) 'ciudad': ciudad,
    };

    final response = await dio.patch('/usuarios/editar-perfil', data: body);
    return UsuarioModel.fromJson(response.data);
  }

  Future<void> cambiarContrasenia({
    required String actual,
    required String nueva,
  }) async {
    await dio.patch(
      '/usuarios/cambiar-contrasenia',
      data: {'contrasenia_actual': actual, 'contrasenia_nueva': nueva},
    );
  }

  Future<UsuarioModel> actualizarFotoPerfilCatalogo(String nombreAvatar) async {
    final response = await dio.patch(
      '/usuarios/foto-perfil-catalogo',
      data: {'foto_perfil': nombreAvatar},
    );
    return UsuarioModel.fromJson(response.data);
  }

  Future<UsuarioModel> subirFotoPerfilPersonalizada(File imagen) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagen.path, filename: 'perfil.jpg'),
    });

    final response = await dio.patch(
      '/usuarios/foto-perfil-personalizada',
      data: formData,
    );
    return UsuarioModel.fromJson(response.data);
  }
}
