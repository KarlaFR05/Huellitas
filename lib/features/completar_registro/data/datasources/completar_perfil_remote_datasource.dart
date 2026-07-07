import 'dart:io';
import 'package:dio/dio.dart';

class CompletarPerfilRemoteDataSourceImpl {
  final Dio dio;
  CompletarPerfilRemoteDataSourceImpl(this.dio);

  Future<void> completarPerfil({
    required String calle,
    required String colonia,
    required String cp,
    required String ciudad,
    required String estado,
    required File frontal,
    required File trasera,
    required File selfie,
  }) async {
    final formData = FormData.fromMap({
      'calle': calle,
      'colonia': colonia,
      'cp': cp,
      'ciudad': ciudad,
      'estado': estado,
      'identificacion_frontal': await MultipartFile.fromFile(
        frontal.path,
        filename: 'frontal.jpg',
      ),
      'identificacion_trasera': await MultipartFile.fromFile(
        trasera.path,
        filename: 'trasera.jpg',
      ),
      'selfie': await MultipartFile.fromFile(
        selfie.path,
        filename: 'selfie.jpg',
      ),
    });

    try {
      await dio.patch('/usuarios/completar-perfil', data: formData);
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('ERROR DETAIL: ${e.response?.data}');
      rethrow;
    }
  }
}
