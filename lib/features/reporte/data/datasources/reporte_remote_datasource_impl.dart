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
}
