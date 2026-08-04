import '../entities/publicacion.dart';
import '../entities/solicitudes_foro.dart';
import '../repositories/foro_repository.dart';

class CrearPublicacion {
  final ForoRepository repository;

  const CrearPublicacion(this.repository);

  Future<Publicacion> call(CrearPublicacionSolicitud solicitud) {
    return repository.crearPublicacion(solicitud);
  }
}
