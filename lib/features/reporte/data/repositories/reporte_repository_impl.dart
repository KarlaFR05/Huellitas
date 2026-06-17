import '../../domain/entities/catalog.dart';
import '../../domain/repositories/reporte_repository.dart';
import '../datasources/reporte_remote_datasource.dart';
import '../../domain/entities/reporte.dart';

class ReporteRepositoryImpl implements ReporteRepository {
  final ReporteRemoteDataSource remoteDataSource;

  ReporteRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Catalog>> getAnimalTypes() => remoteDataSource.getAnimalTypes();

  @override
  Future<List<Catalog>> getReportTypes() => remoteDataSource.getReportTypes();

  @override
  Future<List<Catalog>> getUrgencyLevels() =>
      remoteDataSource.getUrgencyLevels();

  @override
  Future<void> crearReporte(Reporte reporte) {
    return remoteDataSource.crearReporte(reporte);
  }
}
