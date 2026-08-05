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
      print('Solicitando insignias para usuario $usuarioId...');
      
      final response = await dio.get('/insignias/usuario/$usuarioId');
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('Insignias recibidas: ${data.length}');
        return data.map((json) => InsigniaModel.fromJson(json)).toList();
      } else {
        print('Error al obtener insignias: ${response.statusCode}');
        throw Exception('Error al obtener insignias');
      }
    } catch (e) {
      print('Error en obtenerInsignias: $e');
      throw Exception('Error de conexion: ${e.toString()}');
    }
  }
}