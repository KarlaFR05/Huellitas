import 'dart:io';
import '../models/reporte_model.dart';

abstract class ReporteRemoteDataSource {
  Future<void> crearReporte(ReporteModel reporte);
  Future<String> subirEvidencia(File imagen);
}