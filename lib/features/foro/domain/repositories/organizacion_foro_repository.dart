/*import '../entities/organizacion_foro.dart';

abstract class OrganizacionForoRepository {
  Future<OrganizacionForo?> obtenerMiOrganizacion(int usuarioId);
  Future<List<OrganizacionForo>> obtenerOrganizacionesVerificadas();
}*/

import '../entities/organizacion_foro.dart';

abstract class OrganizacionForoRepository {
  Future<OrganizacionForo?> obtenerMiOrganizacion();
  Future<List<OrganizacionForo>> obtenerOrganizacionesVerificadas();
  Future<ResultadoSeguimientoOrganizacion> toggleSeguir(int organizacionId);
}
