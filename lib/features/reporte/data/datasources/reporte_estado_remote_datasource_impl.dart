import 'package:dio/dio.dart';
import 'dart:io';
import '../models/reporte_estado_model.dart';
import 'reporte_estado_remote_datasource.dart';

class ReporteEstadoRemoteDataSourceImpl
    implements ReporteEstadoRemoteDataSource {
  final Dio dio;

  ReporteEstadoRemoteDataSourceImpl(this.dio);

  @override
  Future<ReporteEstadoModel> obtenerEstado(int reporteId) async {
    try {
      final response = await dio.get('/reportes/$reporteId/estado');
      return ReporteEstadoModel.fromJson(response.data);
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('ERROR DETAIL: ${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<void> tomarReporte(int reporteId) async {
    try {
      await dio.put('/reportes/$reporteId/tomar');
    } on DioException catch (e) {
      final data = e.response?.data;
      final detail = (data is Map && data['detail'] != null)
          ? data['detail']
          : null;
      throw Exception(detail ?? 'No se pudo tomar el reporte');
    }
  }

  @override
  Future<void> actualizarEstado({
    required int reporteId,
    required int nuevaFaseId,
    int? usuarioId,
    required File evidencia,
    String? comentarios,
  }) async {
    try {
      String fileName = evidencia.path.split('/').last;

      FormData formData = FormData.fromMap({
        'nueva_fase_id': nuevaFaseId,
        if (usuarioId != null) 'usuario_id': usuarioId,
        'evidencia': await MultipartFile.fromFile(
          evidencia.path,
          filename: fileName,
        ),
        if (comentarios != null) 'comentarios': comentarios,
      });

      await dio.put('/reportes/$reporteId/estado', data: formData);
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('ERROR DETAIL: ${e.response?.data}');
      rethrow;
    }
  }
}
