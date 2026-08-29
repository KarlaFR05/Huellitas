/*import '../../domain/entities/organizacion_foro.dart';
import '../../domain/repositories/organizacion_foro_repository.dart';
import '../datasources/organizacion_foro_datasource.dart';

class OrganizacionForoRepositoryImpl implements OrganizacionForoRepository {
  final OrganizacionForoDataSource dataSource;
  OrganizacionForoRepositoryImpl(this.dataSource);

  @override
  Future<OrganizacionForo?> obtenerMiOrganizacion(int usuarioId) =>
      dataSource.obtenerMiOrganizacion(usuarioId);

  @override
  Future<List<OrganizacionForo>> obtenerOrganizacionesVerificadas() =>
      dataSource.obtenerOrganizacionesVerificadas();
}*/
import '../../domain/entities/organizacion_foro.dart';
import '../../domain/repositories/organizacion_foro_repository.dart';
import '../datasources/organizacion_foro_datasource.dart'; 

class OrganizacionForoRepositoryImpl implements OrganizacionForoRepository {
  final OrganizacionForoRemoteDataSource remoteDataSource;

  OrganizacionForoRepositoryImpl(this.remoteDataSource);

  @override
  Future<OrganizacionForo?> obtenerMiOrganizacion() async {
    return await remoteDataSource.obtenerMiOrganizacion();
  }

  @override
  Future<List<OrganizacionForo>> obtenerOrganizacionesVerificadas() async {
    return await remoteDataSource.obtenerOrganizacionesVerificadas();
  }

  @override
  Future<Map<String, dynamic>> toggleSeguir(int organizacionId) async {
    return await remoteDataSource.toggleSeguir(organizacionId);
  }
}