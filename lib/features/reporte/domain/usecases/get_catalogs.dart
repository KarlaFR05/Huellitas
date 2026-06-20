import '../entities/catalog.dart';
import '../repositories/catalog_repository.dart';

class GetAnimalTypes {
  final CatalogRepository repository;

  GetAnimalTypes(this.repository);

  Future<List<Catalog>> call() {
    return repository.getAnimalTypes();
  }
}
