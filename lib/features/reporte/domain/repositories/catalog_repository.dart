import '../entities/catalog.dart';

abstract class CatalogRepository {
  Future<List<Catalog>> getAnimalTypes();
  Future<List<Catalog>> getReportTypes();
  Future<List<Catalog>> getUrgencyLevels();
}
