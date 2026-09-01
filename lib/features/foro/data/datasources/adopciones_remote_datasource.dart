import 'package:dio/dio.dart';
import '../../domain/entities/adopcion.dart';
import '../../domain/entities/pregunta_adopcion.dart';
import '../../domain/repositories/crear_adopcion_solicitud.dart';

abstract class AdopcionesRemoteDataSource {
  Future<List<Adopcion>> obtenerAdopciones();
  Future<Adopcion> crearAdopcion(CrearAdopcionSolicitud solicitud);
  Future<Adopcion> obtenerAdopcion(int adopcionId);
  Future<void> eliminarAdopcion(int adopcionId);
  Future<List<String>> sugerirPreguntas({
    required String especie,
    required String edad,
    required String tamano,
    String? descripcion,
  });
  Future<void> crearPostulacion({
    required int adopcionId,
    required int usuarioId,
    required Map<int, String> respuestas,
  });
  Future<List<Map<String, dynamic>>> obtenerPostulaciones(int adopcionId);
  Future<List<Map<String, dynamic>>> calcularRanking(int adopcionId);
  Future<bool> yaPostulado(int adopcionId);
  Future<int> contarSolicitudes(int adopcionId);
  Future<void> aprobarPostulacion(int adopcionId, int postulacionId);
}

class AdopcionesRemoteDataSourceImpl implements AdopcionesRemoteDataSource {
  final Dio dio;

  AdopcionesRemoteDataSourceImpl(this.dio);

  Adopcion _adopcionDesdeJson(Map<String, dynamic> json) {
    return Adopcion(
      id: json['adopcion_id'] as int,
      usuarioId: json['usuario_id_fk'] as int?,
      nombre: json['nombre'] as String,
      especie: json['especie'] as String,
      edad: json['edad'] as String,
      tamano: json['tamano'] as String,
      ciudad: json['ciudad'] as String,
      sexo: json['sexo'] as String,
      vacunas: json['vacunas'] as String,
      descripcion: json['descripcion'] as String,
      imagenUrl: json['imagen_url'] as String?,
      fecha: json['fecha_adopcion'] != null
          ? DateTime.parse(json['fecha_adopcion'] as String)
          : null,
      preguntas: (json['preguntas'] as List<dynamic>? ?? [])
          .map((p) => PreguntaAdopcion.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<void> aprobarPostulacion(int adopcionId, int postulacionId) async {
    await dio.put(
      '/adopciones/$adopcionId/postulaciones/$postulacionId/aprobar',
    );
  }

  @override
  Future<bool> yaPostulado(int adopcionId) async {
    final response = await dio.get('/adopciones/$adopcionId/mi-postulacion');
    return response.data['ya_postulado'] as bool;
  }

  @override
  Future<int> contarSolicitudes(int adopcionId) async {
    final response = await dio.get(
      '/adopciones/$adopcionId/conteo-postulaciones',
    );
    return response.data['total'] as int;
  }

  @override
  Future<List<Adopcion>> obtenerAdopciones() async {
    final response = await dio.get('/adopciones');
    return (response.data as List<dynamic>)
        .map((json) => _adopcionDesdeJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Adopcion> crearAdopcion(CrearAdopcionSolicitud solicitud) async {
    final response = await dio.post(
      '/adopciones',
      data: {
        'usuario_id_fk': solicitud.usuarioId,
        'nombre': solicitud.nombre,
        'especie': solicitud.especie,
        'edad': solicitud.edad,
        'tamano': solicitud.tamano,
        'ciudad': solicitud.ciudad,
        'sexo': solicitud.sexo,
        'vacunas': solicitud.vacunas,
        'descripcion': solicitud.descripcion,
        'imagen_url': solicitud.imagenExistenteUrl,
        'preguntas': solicitud.preguntas.map((p) => p.toJson()).toList(),
      },
    );
    return _adopcionDesdeJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Adopcion> obtenerAdopcion(int adopcionId) async {
    final response = await dio.get('/adopciones/$adopcionId');
    return _adopcionDesdeJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminarAdopcion(int adopcionId) async {
    await dio.delete('/adopciones/$adopcionId');
  }

  @override
  Future<List<String>> sugerirPreguntas({
    required String especie,
    required String edad,
    required String tamano,
    String? descripcion,
  }) async {
    final response = await dio.post(
      '/adopciones/sugerir-preguntas',
      data: {
        'especie': especie,
        'edad': edad,
        'tamano': tamano,
        'descripcion': descripcion,
      },
    );
    return List<String>.from(response.data['preguntas_sugeridas'] as List);
  }

  @override
  Future<void> crearPostulacion({
    required int adopcionId,
    required int usuarioId,
    required Map<int, String> respuestas,
  }) async {
    await dio.post(
      '/adopciones/$adopcionId/postulaciones',
      data: {
        'usuario_id_fk': usuarioId,
        'respuestas': respuestas.entries
            .map((e) => {'pregunta_id': e.key, 'respuesta_texto': e.value})
            .toList(),
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> obtenerPostulaciones(
    int adopcionId,
  ) async {
    final response = await dio.get('/adopciones/$adopcionId/postulaciones');
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  @override
  Future<List<Map<String, dynamic>>> calcularRanking(int adopcionId) async {
    final response = await dio.post('/adopciones/$adopcionId/ranking');
    return List<Map<String, dynamic>>.from(response.data as List);
  }
}
