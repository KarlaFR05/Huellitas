import '../entities/catalog.dart';
import '../repositories/catalog_repository.dart';

class GetUrgencyLevels {
  final CatalogRepository repository;

  GetUrgencyLevels(this.repository);

  Future<List<Catalog>> call() {
    return repository.getUrgencyLevels();
  }
}
