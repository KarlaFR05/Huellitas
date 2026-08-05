import '../../domain/entities/organizacion.dart';
import '../../domain/entities/categoria_organizacion.dart';

abstract class DonacionEvent {}

class CargarOrganizaciones extends DonacionEvent {
  final CategoriaOrganizacion categoria;
  CargarOrganizaciones(this.categoria);
}

class SeleccionarOrganizacion extends DonacionEvent {
  final Organizacion organizacion;
  SeleccionarOrganizacion(this.organizacion);
}

class SeleccionarMonto extends DonacionEvent {
  final double monto;
  SeleccionarMonto(this.monto);
}
class ProcesarPago extends DonacionEvent {
  final int usuarioId;
  final int organizacionId;
  final double monto;
  final int tarjetaId;            
  final String metodoPago;      

  ProcesarPago({
    required this.usuarioId,
    required this.organizacionId,
    required this.monto,
    required this.tarjetaId,
    this.metodoPago = 'tarjeta',
  });
}

/*class ProcesarPago extends DonacionEvent {
  final int usuarioId;
  final int organizacionId;
  final double monto;
  final String numeroTarjeta;
  final String titularTarjeta;
  final String cvv;
  final String fechaVencimiento;

  ProcesarPago({
    required this.usuarioId,
    required this.organizacionId,
    required this.monto,
    required this.numeroTarjeta,
    required this.titularTarjeta,
    required this.cvv,
    required this.fechaVencimiento,
  });
}*/