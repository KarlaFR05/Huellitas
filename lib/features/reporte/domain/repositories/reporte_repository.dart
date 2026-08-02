import 'dart:io';
import '../entities/reporte.dart';
import '../entities/respuesta_crear_reporte.dart';

abstract class ReporteRepository {
  Future<RespuestaCrearReporte> crearReporte(
    Reporte reporte, {
    bool forzarCreacion = false,
  });
  Future<String> subirEvidencia(File imagen);
  Future<List<Reporte>> obtenerReportes();
}
