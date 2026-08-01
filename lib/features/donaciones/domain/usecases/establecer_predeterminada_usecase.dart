import '../repositories/tarjeta_repository.dart';

class EstablecerPredeterminadaUseCase {
  final TarjetaRepository repository;

  EstablecerPredeterminadaUseCase(this.repository);

  Future<void> call(int tarjetaId) async {
    await repository.establecerPredeterminada(tarjetaId);
  }
}