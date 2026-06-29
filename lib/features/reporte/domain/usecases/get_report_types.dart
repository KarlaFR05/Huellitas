import '../entities/catalog.dart';
import '../repositories/catalog_repository.dart';

class GetReportTypes {
  final CatalogRepository repository;

  GetReportTypes(this.repository);

  Future<List<Catalog>> call() {
    return repository.getReportTypes();
  }
}