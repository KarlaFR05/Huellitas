import 'dart:io';
import 'package:dio/dio.dart';
import '../models/reporte_estado_model.dart';
import 'reporte_estado_remote_datasource.dart';

class ReporteEstadoRemoteDataSourceImpl implements ReporteEstadoRemoteDataSource {
  final Dio dio;

  ReporteEstadoRemoteDataSourceImpl(this.dio);

  @override
  Future<ReporteEstadoModel> obtenerEstado(int reporteId) async {
    try {
      final response = await dio.get('/reportes/$reporteId/estado');
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        return ReporteEstadoModel.fromJson(response.data);
      } else {
        throw Exception('Error al obtener estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerEstado: $e');
      throw Exception('Error de conexion: ${e.toString()}');
    }
  }

  @override
  Future<void> tomarReporte(int reporteId) async {
    try {
      final response = await dio.post('/reportes/$reporteId/tomar');
      
      print('Tomar reporte - Status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception('Error al tomar reporte: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en tomarReporte: $e');
      throw Exception('Error de conexion: ${e.toString()}');
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
      // Subir imagen primero
      print('Subiendo evidencia...');
      final evidenciaUrl = await _subirEvidencia(evidencia);
      print('Evidencia subida: $evidenciaUrl');
      
      final payload = {
        'nueva_fase_id': nuevaFaseId,
        'evidencia_url': evidenciaUrl,
        'comentarios': comentarios,
      };

      if (usuarioId != null) {
        payload['usuario_id'] = usuarioId;
      }

      print('Actualizando estado del reporte $reporteId...');
      print('Payload: $payload');

      final response = await dio.put(
        '/reportes/$reporteId/estado',
        data: payload,
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      // Aceptar tanto 200 como 201 como éxito
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Estado actualizado exitosamente');
        return;
      } else {
        final errorMessage = response.data['detail'] ?? 'Error desconocido';
        print('Error del servidor: $errorMessage');
        throw Exception('Error al actualizar estado: $errorMessage');
      }
    } catch (e) {
      print('Error en actualizarEstado: $e');
      if (e is DioException && e.response != null) {
        print('DioException - Status: ${e.response?.statusCode}');
        print('Response error: ${e.response?.data}');
      }
      throw Exception('Error de conexion: ${e.toString()}');
    }
  }

  Future<String> _subirEvidencia(File imagen) async {
    try {
      String fileName = imagen.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagen.path,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        '/upload/evidencia',
        data: formData,
      );

      print('Upload response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Ajusta según la estructura de tu respuesta
        return response.data['url'] ?? response.data['evidencia_url'];
      } else {
        throw Exception('Error al subir imagen');
      }
    } catch (e) {
      print('Error al subir evidencia: $e');
      throw Exception('Error al subir evidencia: ${e.toString()}');
    }
  }
}