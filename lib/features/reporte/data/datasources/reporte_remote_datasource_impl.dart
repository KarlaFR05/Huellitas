import 'package:dio/dio.dart';
import '../models/reporte_model.dart';
import 'reporte_remote_datasource.dart';

class ReporteRemoteDataSourceImpl implements ReporteRemoteDataSource {
  final Dio dio;

  ReporteRemoteDataSourceImpl(this.dio);

  @override
  Future<void> crearReporte(ReporteModel reporte) async {
    await dio.post('/reportes', data: reporte.toJson());
  }
}
