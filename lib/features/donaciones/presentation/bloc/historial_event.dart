enum TipoHistorial { donaciones }

abstract class HistorialEvent {}

class CargarHistorial extends HistorialEvent {
  final TipoHistorial tipo;
  CargarHistorial(this.tipo);
}