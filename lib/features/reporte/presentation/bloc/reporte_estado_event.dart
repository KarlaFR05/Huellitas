import 'dart:io';

abstract class ReporteEstadoEvent {}

class CargarEstadoReporte extends ReporteEstadoEvent {
  final int reporteId;
  CargarEstadoReporte(this.reporteId);
}

class ActualizarEstado extends ReporteEstadoEvent {
  final int reporteId;
  final int nuevaFaseId;
  final int? usuarioId;
  final File evidencia;
  final String? comentarios;

  ActualizarEstado({
    required this.reporteId,
    required this.nuevaFaseId,
    this.usuarioId,
    required this.evidencia,
    this.comentarios,
  });
}