import 'dart:io';
import '../entities/reporte.dart';

abstract class ReporteRepository {
  Future<void> crearReporte(Reporte reporte);
  Future<String> subirEvidencia(File imagen);
  Future<List<Reporte>> obtenerReportes();
}
