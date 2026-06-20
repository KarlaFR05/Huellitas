import '../entities/reporte.dart';
import '../repositories/reporte_repository.dart';

class CreateReporteUseCase {
  final ReporteRepository repository;

  CreateReporteUseCase(this.repository);

  Future<void> call(Reporte reporte) {
    return repository.crearReporte(reporte);
  }
}
