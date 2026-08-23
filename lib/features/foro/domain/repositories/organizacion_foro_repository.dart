import '../entities/organizacion_foro.dart';

abstract class OrganizacionForoRepository {
  Future<OrganizacionForo?> obtenerMiOrganizacion(int usuarioId);
  Future<List<OrganizacionForo>> obtenerOrganizacionesVerificadas();
}