import '../entities/tarjeta.dart';

abstract class TarjetaRepository {
  Future<List<Tarjeta>> obtenerTarjetasUsuario(/*int usuarioId*/);
  Future<Tarjeta> guardarTarjeta({
    /*required int usuarioId,*/
    required String numeroTarjeta,
    required String titular,
    required String fechaVencimiento,
    required String cvv,
    bool esPredeterminada = false,
  });
  Future<void> eliminarTarjeta(int tarjetaId);
  Future<void> actualizarTarjeta({
    required int tarjetaId,
    String? numeroTarjeta,
    String? titular,
    String? fechaVencimiento,
    /*String? cvv,*/
    bool? esPredeterminada,
  });
  Future<void> establecerPredeterminada(int tarjetaId);
}