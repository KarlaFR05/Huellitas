import 'dart:io';
import '../entities/reporte_estado.dart';

abstract class ReporteEstadoRepository {
  Future<ReporteEstado> obtenerEstado(int reporteId);

  Future<void> tomarReporte(int reporteId);

  Future<void> actualizarEstado({
    required int reporteId,
    required int nuevaFaseId,
    int? usuarioId,
    required File evidencia,
    String? comentarios,
  });
}
