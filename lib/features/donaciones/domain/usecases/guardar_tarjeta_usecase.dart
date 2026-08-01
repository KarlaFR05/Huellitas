import '../entities/tarjeta.dart';
import '../repositories/tarjeta_repository.dart';

class GuardarTarjetaUseCase {
  final TarjetaRepository repository;

  GuardarTarjetaUseCase(this.repository);

  Future<Tarjeta> call({
    required int usuarioId,
    required String numeroTarjeta,
    required String titular,
    required String fechaVencimiento,
    required String cvv,
    bool esPredeterminada = false,
  }) async {
    return await repository.guardarTarjeta(
      usuarioId: usuarioId,
      numeroTarjeta: numeroTarjeta,
      titular: titular,
      fechaVencimiento: fechaVencimiento,
      cvv: cvv,
      esPredeterminada: esPredeterminada,
    );
  }
}