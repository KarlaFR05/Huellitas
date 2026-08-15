import '../entities/grupo.dart';
import '../repositories/foro_repository.dart';

class ObtenerMisGrupos {
  final ForoRepository repository;
  const ObtenerMisGrupos(this.repository);
  Future<List<Grupo>> call() => repository.obtenerMisGrupos();
}
