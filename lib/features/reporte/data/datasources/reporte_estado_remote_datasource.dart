import 'dart:io';
import '../models/reporte_estado_model.dart';

abstract class ReporteEstadoRemoteDataSource {
  Future<ReporteEstadoModel> obtenerEstado(int reporteId);
  
  Future<void> actualizarEstado({
    required int reporteId,
    required int nuevaFaseId,
    int? usuarioId,
    required File evidencia,
    String? comentarios,
  });
}