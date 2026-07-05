import '../entities/reporte_estado.dart';
import '../repositories/reporte_estado_repository.dart';

class GetReporteEstadoUseCase {
  final ReporteEstadoRepository repository;

  GetReporteEstadoUseCase(this.repository);

  Future<ReporteEstado> call(int reporteId) {
    return repository.obtenerEstado(reporteId);
  }
}