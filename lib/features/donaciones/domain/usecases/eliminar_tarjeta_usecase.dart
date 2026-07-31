import '../repositories/tarjeta_repository.dart';

class EliminarTarjetaUseCase {
  final TarjetaRepository repository;

  EliminarTarjetaUseCase(this.repository);

  Future<void> call(int tarjetaId) async {
    await repository.eliminarTarjeta(tarjetaId);
  }
}