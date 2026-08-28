import '../../domain/entities/estadisticas_organizacion_entity.dart';
import '../../domain/repositories/donacion_organizacion_repository.dart';
import '../datasources/donacion_organizacion_remote_datasource.dart';

class DonacionOrganizacionRepositoryImpl implements DonacionOrganizacionRepository {
  final DonacionOrganizacionRemoteDataSource remoteDataSource;

  DonacionOrganizacionRepositoryImpl(this.remoteDataSource);

  @override
  Future<EstadisticasOrganizacionEntity> obtenerEstadisticas(int organizacionId) async {
    return await remoteDataSource.obtenerEstadisticas(organizacionId);
  }

  @override
  Future<EstadisticasOrganizacionEntity> actualizarMeta(int organizacionId, double nuevaMeta) async {
    return await remoteDataSource.actualizarMeta(organizacionId, nuevaMeta);
  }
}