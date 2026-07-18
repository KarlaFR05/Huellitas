import '../repositories/reporte_estado_repository.dart';

class TomarReporteUseCase {
  final ReporteEstadoRepository repository;

  TomarReporteUseCase(this.repository);

  Future<void> call(int reporteId) {
    return repository.tomarReporte(reporteId);
  }
}
