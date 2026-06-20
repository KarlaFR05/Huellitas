import '../../domain/entities/reporte.dart';

abstract class ReporteEvent {}

class LoadCatalogsEvent extends ReporteEvent {}

class SubmitReporte extends ReporteEvent {
  final Reporte reporte;

  SubmitReporte(this.reporte);
}
