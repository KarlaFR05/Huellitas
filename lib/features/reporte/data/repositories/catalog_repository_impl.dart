import '../../domain/entities/catalog.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_datasource.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remote;

  CatalogRepositoryImpl(this.remote);

  @override
  Future<List<Catalog>> getAnimalTypes() {
    return remote.getAnimalTypes();
  }

  @override
  Future<List<Catalog>> getReportTypes() {
    return remote.getReportTypes();
  }

  @override
  Future<List<Catalog>> getUrgencyLevels() {
    return remote.getUrgencyLevels();
  }
}