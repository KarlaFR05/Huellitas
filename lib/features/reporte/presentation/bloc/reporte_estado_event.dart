import 'dart:io';

abstract class ReporteEstadoEvent {}

class CargarEstadoReporte extends ReporteEstadoEvent {
  final int reporteId;
  CargarEstadoReporte(this.reporteId);
}

class ActualizarEstado extends ReporteEstadoEvent {
  final int reporteId;
  final int nuevaFaseId;
  final File evidencia;

  ActualizarEstado({
    required this.reporteId,
    required this.nuevaFaseId,
    required this.evidencia,
  });
}