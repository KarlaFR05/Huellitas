import '../entities/pagina.dart';
import '../entities/publicacion.dart';
import '../entities/solicitudes_foro.dart';
import '../repositories/foro_repository.dart';

class ObtenerFeedForo {
  final ForoRepository repository;

  const ObtenerFeedForo(this.repository);

  Future<Pagina<Publicacion>> call(FiltroPublicaciones filtro) {
    return repository.obtenerFeed(filtro);
  }
}
