import '../entities/insignia.dart';
import '../entities/categoria_insignia.dart';

abstract class InsigniaRepository {
  Future<Map<CategoriaInsignia, List<Insignia>>> obtenerTodasLasInsignias(int usuarioId);
}