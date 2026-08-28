import '../entities/estadisticas_organizacion_entity.dart';

abstract class DonacionOrganizacionRepository {
  Future<EstadisticasOrganizacionEntity> obtenerEstadisticas(int organizacionId);
  Future<EstadisticasOrganizacionEntity> actualizarMeta(int organizacionId, double nuevaMeta);
}