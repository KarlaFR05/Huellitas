import '../entities/reporte.dart';

abstract class ReporteRepository {
  Future<void> crearReporte(Reporte reporte);
  Future<List<Reporte>> obtenerReportes();
}
