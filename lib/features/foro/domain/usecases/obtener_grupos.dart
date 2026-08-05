import '../entities/grupo.dart';
import '../entities/pagina.dart';
import '../repositories/foro_repository.dart';

class ObtenerGrupos {
  final ForoRepository repository;
  const ObtenerGrupos(this.repository);
  Future<Pagina<Grupo>> call({
    String? busqueda,
    String? cursor,
    int limite = 20,
  }) => repository.obtenerGrupos(
    busqueda: busqueda,
    cursor: cursor,
    limite: limite,
  );
}
