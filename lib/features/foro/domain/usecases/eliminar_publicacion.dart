import '../repositories/foro_repository.dart';

class EliminarPublicacion {
  final ForoRepository repository;
  const EliminarPublicacion(this.repository);
  Future<void> call(int publicacionId) =>
      repository.eliminarPublicacion(publicacionId);
}