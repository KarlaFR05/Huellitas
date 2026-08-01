import '../repositories/tarjeta_repository.dart';

class ActualizarTarjetaUseCase {
  final TarjetaRepository repository;

  ActualizarTarjetaUseCase(this.repository);

  Future<void> call({
    required int tarjetaId,
    String? titular,
    String? fechaVencimiento,
    bool? esPredeterminada,
  }) async {
    await repository.actualizarTarjeta(
      tarjetaId: tarjetaId,
      titular: titular,
      fechaVencimiento: fechaVencimiento,
      esPredeterminada: esPredeterminada,
    );
  }
}