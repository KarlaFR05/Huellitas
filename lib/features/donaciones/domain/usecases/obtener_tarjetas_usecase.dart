import '../entities/tarjeta.dart';
import '../repositories/tarjeta_repository.dart';

class ObtenerTarjetasUseCase {
  final TarjetaRepository repository;

  ObtenerTarjetasUseCase(this.repository);

  Future<List<Tarjeta>> call(/*int usuarioId*/) async {
    return await repository.obtenerTarjetasUsuario(/*usuarioId*/);
  }
}
