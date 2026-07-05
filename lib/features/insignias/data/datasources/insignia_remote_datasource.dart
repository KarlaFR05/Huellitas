import 'package:dio/dio.dart';
import '../models/insignia_model.dart';

abstract class InsigniaRemoteDataSource {
  Future<List<InsigniaModel>> obtenerInsignias(int usuarioId);
}

class InsigniaRemoteDataSourceImpl implements InsigniaRemoteDataSource {
  final Dio dio;

  InsigniaRemoteDataSourceImpl(this.dio);

  @override
  Future<List<InsigniaModel>> obtenerInsignias(int usuarioId) async {
    try {
      final response = await dio.get('/insignias/usuario/$usuarioId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => InsigniaModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener insignias');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}