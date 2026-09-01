/*import 'package:dio/dio.dart';
import '../models/organizacion_perfil_model.dart';

abstract class OrganizacionPerfilRemoteDataSource {
  Future<OrganizacionPerfilModel> obtenerMiOrganizacion();
  Future<OrganizacionPerfilModel> actualizarMiOrganizacion(Map<String, dynamic> datos);
}

class OrganizacionPerfilRemoteDataSourceImpl implements OrganizacionPerfilRemoteDataSource {
  final Dio dio;

  OrganizacionPerfilRemoteDataSourceImpl(this.dio);

  @override
  Future<OrganizacionPerfilModel> obtenerMiOrganizacion() async {
    final response = await dio.get('/usuarios/mi-organizacion');
    return OrganizacionPerfilModel.fromJson(response.data);
  }

  @override
  Future<OrganizacionPerfilModel> actualizarMiOrganizacion(Map<String, dynamic> datos) async {
    final response = await dio.patch('/usuarios/mi-organizacion', data: datos);
    return OrganizacionPerfilModel.fromJson(response.data);
  }
}*/
import 'package:dio/dio.dart';
import '../models/organizacion_perfil_model.dart';

abstract class OrganizacionPerfilRemoteDataSource {
  Future<OrganizacionPerfilModel> obtenerMiOrganizacion();
  Future<OrganizacionPerfilModel> actualizarMiOrganizacion(Map<String, dynamic> datos);
  Future<OrganizacionPerfilModel> subirImagenes({
    MultipartFile? fotoPerfil,
    MultipartFile? fotoPortada,
  });
}

class OrganizacionPerfilRemoteDataSourceImpl implements OrganizacionPerfilRemoteDataSource {
  final Dio dio;

  OrganizacionPerfilRemoteDataSourceImpl(this.dio);

  @override
  Future<OrganizacionPerfilModel> obtenerMiOrganizacion() async {
    final response = await dio.get('/organizaciones/mi-organizacion');
    return OrganizacionPerfilModel.fromJson(response.data);
  }

  @override
  Future<OrganizacionPerfilModel> actualizarMiOrganizacion(Map<String, dynamic> datos) async {
    final response = await dio.patch('/usuarios/mi-organizacion', data: datos);
    return OrganizacionPerfilModel.fromJson(response.data);
  }

  @override
  Future<OrganizacionPerfilModel> subirImagenes({
    MultipartFile? fotoPerfil,
    MultipartFile? fotoPortada,
  }) async {
    final formData = FormData.fromMap({
      if (fotoPerfil != null) 'foto_perfil': fotoPerfil,
      if (fotoPortada != null) 'foto_portada': fotoPortada,
    });

    final response = await dio.patch(
      '/usuarios/mi-organizacion/imagenes',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return OrganizacionPerfilModel.fromJson(response.data);
  }
}