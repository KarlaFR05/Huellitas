import '../entities/insignia.dart';
import '../entities/categoria_insignia.dart';
import '../repositories/insignia_repository.dart';

class GetInsigniasUsuarioUseCase {
  final InsigniaRepository repository;

  GetInsigniasUsuarioUseCase(this.repository);

  Future<Map<CategoriaInsignia, List<Insignia>>> call(int usuarioId) {
    return repository.obtenerTodasLasInsignias(usuarioId);
  }
}