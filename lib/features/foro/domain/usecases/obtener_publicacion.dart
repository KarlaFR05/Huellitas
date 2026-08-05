import '../entities/publicacion.dart';
import '../repositories/foro_repository.dart';

class ObtenerPublicacion {
  final ForoRepository repository;
  const ObtenerPublicacion(this.repository);
  Future<Publicacion> call(int publicacionId) =>
      repository.obtenerPublicacion(publicacionId);
}
