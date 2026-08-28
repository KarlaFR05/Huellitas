import 'package:dio/dio.dart';
import '../models/estadisticas_organizacion_model.dart';

abstract class DonacionOrganizacionRemoteDataSource {
  Future<EstadisticasOrganizacionModel> obtenerEstadisticas(int organizacionId);
  Future<EstadisticasOrganizacionModel> actualizarMeta(int organizacionId, double nuevaMeta);
}

class DonacionOrganizacionRemoteDataSourceImpl implements DonacionOrganizacionRemoteDataSource {
  final Dio dio;

  DonacionOrganizacionRemoteDataSourceImpl(this.dio);

  @override
  Future<EstadisticasOrganizacionModel> obtenerEstadisticas(int organizacionId) async {
    final response = await dio.get('/donaciones/organizacion/$organizacionId/estadisticas');
    return EstadisticasOrganizacionModel.fromJson(response.data);
  }

  @override
  Future<EstadisticasOrganizacionModel> actualizarMeta(int organizacionId, double nuevaMeta) async {
    final response = await dio.patch(
      '/donaciones/organizacion/$organizacionId/meta',
      data: {'meta_mensual': nuevaMeta},
    );
    return EstadisticasOrganizacionModel.fromJson(response.data);
  }
}