import 'dart:io';
import '../repositories/reporte_estado_repository.dart';

class ActualizarEstadoReporteUseCase {
  final ReporteEstadoRepository repository;

  ActualizarEstadoReporteUseCase(this.repository);

  Future<void> call({
    required int reporteId,
    required int nuevaFaseId,
    required File evidencia,
  }) {
    return repository.actualizarEstado(
      reporteId: reporteId,
      nuevaFaseId: nuevaFaseId,
      evidencia: evidencia,
    );
  }
}