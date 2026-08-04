import 'dart:io';
import '../models/reporte_model.dart';
import '../models/respuesta_crear_reporte_model.dart';

abstract class ReporteRemoteDataSource {
  Future<RespuestaCrearReporteModel> crearReporte(
    ReporteModel reporte, {
    bool forzarCreacion = false,
  });
  Future<String> subirEvidencia(File imagen);
  Future<List<ReporteModel>> obtenerReportes();
}
