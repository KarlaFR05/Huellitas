import '../entities/donacion.dart';
import '../repositories/donacion_repository.dart';

class CrearDonacionUseCase {
  final DonacionRepository repository;

  CrearDonacionUseCase(this.repository);

  Future<Donacion> call({
    required int usuarioId,
    required int organizacionId,
    required double monto,
    /*required String numeroTarjeta,
    required String titularTarjeta,
    required String cvv,
    required String fechaVencimiento,*/
    required int tarjetaId,
    String metodoPago = 'tarjeta',
  }) async {
    return await repository.crearDonacion(
      usuarioId: usuarioId,
      organizacionId: organizacionId,
      monto: monto,
      /*numeroTarjeta: numeroTarjeta,
      titularTarjeta: titularTarjeta,
      cvv: cvv,
      fechaVencimiento: fechaVencimiento,*/
      tarjetaId: tarjetaId,
      metodoPago: metodoPago,
    );
  }
}