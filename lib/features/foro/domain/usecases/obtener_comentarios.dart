import '../entities/comentario.dart';
import '../entities/pagina.dart';
import '../repositories/foro_repository.dart';

class ObtenerComentarios {
  final ForoRepository repository;
  const ObtenerComentarios(this.repository);
  Future<Pagina<Comentario>> call(int publicacionId, {String? cursor, int limite = 30}) =>
      repository.obtenerComentarios(publicacionId, cursor: cursor, limite: limite);
}