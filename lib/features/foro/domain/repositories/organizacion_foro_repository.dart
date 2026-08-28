/*import '../entities/organizacion_foro.dart';

abstract class OrganizacionForoRepository {
  Future<OrganizacionForo?> obtenerMiOrganizacion(int usuarioId);
  Future<List<OrganizacionForo>> obtenerOrganizacionesVerificadas();
}*/
import '../entities/organizacion_foro_entity.dart';

abstract class OrganizacionForoRepository {
  Future<OrganizacionForoEntity?> obtenerMiOrganizacion();
  Future<List<OrganizacionForoEntity>> obtenerOrganizacionesVerificadas();
  Future<Map<String, dynamic>> toggleSeguir(int organizacionId);
}