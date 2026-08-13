import 'package:dio/dio.dart';
import 'dart:io';
import '../models/reporte_model.dart';
import 'reporte_remote_datasource.dart';
import '../models/respuesta_crear_reporte_model.dart';

class ReporteRemoteDataSourceImpl implements ReporteRemoteDataSource {
  final Dio dio;

  ReporteRemoteDataSourceImpl(this.dio);

  @override
  Future<RespuestaCrearReporteModel> crearReporte(
    ReporteModel reporte, {
    bool forzarCreacion = false,
  }) async {
    try {
      print('JSON A ENVIAR: ${reporte.toJson()}');
      final response = await dio.post(
        '/reportes',
        data: reporte.toJson(),
        queryParameters: {'forzar_creacion': forzarCreacion},
      );
      return RespuestaCrearReporteModel.fromJson(response.data);
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

  @override
  Future<List<ReporteModel>> obtenerReportes() async {
    try {
      final response = await dio.get('/reportes');
      return (response.data as List)
          .map((json) => ReporteModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('ERROR DETAIL: ${e.response?.data}');
      rethrow;
    }
  }
}
