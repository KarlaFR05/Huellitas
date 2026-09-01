/*import '../../domain/entities/organizacion_perfil_entity.dart';
import '../../domain/repositories/organizacion_perfil_repository.dart';
import '../datasources/organizacion_perfil_remote_datasource.dart';

class OrganizacionPerfilRepositoryImpl implements OrganizacionPerfilRepository {
  final OrganizacionPerfilRemoteDataSource remoteDataSource;

  OrganizacionPerfilRepositoryImpl(this.remoteDataSource);

  @override
  Future<OrganizacionPerfilEntity> obtenerMiOrganizacion() async {
    return await remoteDataSource.obtenerMiOrganizacion();
  }

  @override
  Future<OrganizacionPerfilEntity> actualizarMiOrganizacion(Map<String, dynamic> datos) async {
    return await remoteDataSource.actualizarMiOrganizacion(datos);
  }
}*/

import '../../domain/entities/organizacion_perfil_entity.dart';
import '../../domain/repositories/organizacion_perfil_repository.dart';
import '../datasources/organizacion_perfil_remote_datasource.dart';
import 'package:dio/dio.dart';

class OrganizacionPerfilRepositoryImpl implements OrganizacionPerfilRepository {
  final OrganizacionPerfilRemoteDataSource remoteDataSource;

  OrganizacionPerfilRepositoryImpl(this.remoteDataSource);

  @override
  Future<OrganizacionPerfilEntity> obtenerMiOrganizacion() async {
    return await remoteDataSource.obtenerMiOrganizacion();
  }

  @override
  Future<OrganizacionPerfilEntity> actualizarMiOrganizacion(Map<String, dynamic> datos) async {
    return await remoteDataSource.actualizarMiOrganizacion(datos);
  }

  @override
  Future<OrganizacionPerfilEntity> subirImagenes({
    MultipartFile? fotoPerfil,
    MultipartFile? fotoPortada,
  }) async {
    return await remoteDataSource.subirImagenes(
      fotoPerfil: fotoPerfil,
      fotoPortada: fotoPortada,
    );
  }
}