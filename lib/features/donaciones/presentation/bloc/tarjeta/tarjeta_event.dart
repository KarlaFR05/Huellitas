abstract class TarjetaEvent {}

class CargarTarjetas extends TarjetaEvent {
  /*final int usuarioId;
  CargarTarjetas(this.usuarioId);*/
  CargarTarjetas();
}

class GuardarNuevaTarjeta extends TarjetaEvent {
  final int usuarioId;
  final String numeroTarjeta;
  final String titular;
  final String fechaVencimiento;
  final String cvv;
  final bool esPredeterminada;

  GuardarNuevaTarjeta({
    required this.usuarioId,
    required this.numeroTarjeta,
    required this.titular,
    required this.fechaVencimiento,
    required this.cvv,
    this.esPredeterminada = false,
  });
}

class EliminarTarjeta extends TarjetaEvent {
  final int tarjetaId;
  EliminarTarjeta(this.tarjetaId);
}

class ActualizarTarjeta extends TarjetaEvent {
  final int tarjetaId;
  final String? numeroTarjeta;
  final String? titular;
  final String? fechaVencimiento;
  final String? cvv;
  final bool? esPredeterminada;

  ActualizarTarjeta({
    required this.tarjetaId,
    this.numeroTarjeta,
    this.titular,
    this.fechaVencimiento,
    this.cvv,
    this.esPredeterminada,
  });
}

class EstablecerPredeterminada extends TarjetaEvent {
  final int tarjetaId;
  EstablecerPredeterminada(this.tarjetaId);
}
