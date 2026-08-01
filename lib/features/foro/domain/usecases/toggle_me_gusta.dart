import '../entities/publicacion.dart';
import '../repositories/foro_repository.dart';

class ToggleMeGusta {
  final ForoRepository repository;
  const ToggleMeGusta(this.repository);
  Future<Publicacion> call(int publicacionId) =>
      repository.cambiarMeGusta(publicacionId);
}