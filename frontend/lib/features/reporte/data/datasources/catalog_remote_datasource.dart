import '../models/catalog_model.dart';

abstract class CatalogRemoteDataSource {
  Future<List<CatalogModel>> getAnimalTypes();
  Future<List<CatalogModel>> getReportTypes();
  Future<List<CatalogModel>> getUrgencyLevels();
}
