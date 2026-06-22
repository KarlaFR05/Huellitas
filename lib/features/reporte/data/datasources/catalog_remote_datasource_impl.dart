import 'package:dio/dio.dart';
import '../models/catalog_model.dart';
import 'catalog_remote_datasource.dart';

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final Dio dio;

  CatalogRemoteDataSourceImpl(this.dio);

  @override
  Future<List<CatalogModel>> getAnimalTypes() async {
    final response = await dio.get('/catalogos/tipos-animal');
    return (response.data as List)
        .map((e) => CatalogModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<CatalogModel>> getReportTypes() async {
    final response = await dio.get('/catalogos/tipos-reporte');
    return (response.data as List)
        .map((e) => CatalogModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<CatalogModel>> getUrgencyLevels() async {
    final response = await dio.get('/catalogos/urgencias');
    return (response.data as List)
        .map((e) => CatalogModel.fromJson(e))
        .toList();
  }
}