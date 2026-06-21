import 'package:dio/dio.dart';
import '../models/reporte_model.dart';
import 'reporte_remote_datasource.dart';

class ReporteRemoteDataSourceImpl implements ReporteRemoteDataSource {
  final Dio dio;

  ReporteRemoteDataSourceImpl(this.dio);

  @override
  Future<void> crearReporte(ReporteModel reporte) async {
    try {
      await dio.post('/reportes', data: reporte.toJson());
    } on DioException catch (e) {
      // Imprime el detalle exacto del error
      print('STATUS: ${e.response?.statusCode}');
      print('ERROR DETAIL: ${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<List<ReporteModel>> obtenerReportes() async {
    final response = await dio.get('/reportes');
    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ReporteModel.fromJson)
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final reportes = data['reportes'] ?? data['data'] ?? data['results'];
      if (reportes is List) {
        return reportes
            .whereType<Map<String, dynamic>>()
            .map(ReporteModel.fromJson)
            .toList();
      }
    }

    return [];
  }
}
