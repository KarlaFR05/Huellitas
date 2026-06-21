import 'package:dio/dio.dart';
import 'dart:io';
import '../models/reporte_model.dart';
import 'reporte_remote_datasource.dart';

class ReporteRemoteDataSourceImpl implements ReporteRemoteDataSource {
  final Dio dio;

  ReporteRemoteDataSourceImpl(this.dio);

  @override
  Future<void> crearReporte(ReporteModel reporte) async {
    try {
      print('JSON A ENVIAR: ${reporte.toJson()}');
      await dio.post('/reportes', data: reporte.toJson());
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('ERROR DETAIL: ${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<String> subirEvidencia(File imagen) async {
    try {
      String fileName = imagen.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagen.path, filename: fileName),
      });

      final response = await dio.post(
        '/reportes/upload_evidencia',
        data: formData,
      );

      return response.data['url'];
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('ERROR DETAIL: ${e.response?.data}');
      rethrow;
    }
  }
}
