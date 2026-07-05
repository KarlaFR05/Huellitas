import '../entities/reporte_estado.dart';
import 'dart:io';

abstract class ReporteEstadoRepository {
  Future<ReporteEstado> obtenerEstado(int reporteId);
  Future<void> actualizarEstado({
    required int reporteId,
    required int nuevaFaseId,
    required File evidencia,
  });
}