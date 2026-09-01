import '../entities/estadisticas_organizacion_entity.dart';
import '../entities/donacion_recibida_entity.dart';

abstract class DonacionOrganizacionRepository {
  Future<EstadisticasOrganizacionEntity> obtenerEstadisticas(int organizacionId);
  Future<EstadisticasOrganizacionEntity> actualizarMeta(int organizacionId, double nuevaMeta);
  Future<List<DonacionRecibidaEntity>> obtenerMisDonaciones();
}