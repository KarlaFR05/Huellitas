import '../entities/reporte.dart';
import '../repositories/reporte_repository.dart';

class GetReportesUseCase {
  final ReporteRepository repository;

  GetReportesUseCase(this.repository);

  Future<List<Reporte>> call() {
    return repository.obtenerReportes();
  }
}
