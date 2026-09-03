import 'package:dio/dio.dart';
import '../../domain/entities/adopcion.dart';
import '../../domain/entities/mi_postulacion_adopcion.dart';
import '../../domain/entities/pregunta_adopcion.dart';
import '../../domain/repositories/crear_adopcion_solicitud.dart';
import 'dart:io';

abstract class AdopcionesRemoteDataSource {
  Future<List<Adopcion>> obtenerAdopciones();
  Future<Adopcion> crearAdopcion(CrearAdopcionSolicitud solicitud);
  Future<Adopcion> actualizarAdopcion(CrearAdopcionSolicitud solicitud);
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
    required String contacto,
    required Map<int, String> respuestas,
  });
  Future<List<Map<String, dynamic>>> obtenerPostulaciones(int adopcionId);
  Future<List<Map<String, dynamic>>> calcularRanking(int adopcionId);
  Future<MiPostulacionAdopcion> obtenerMiPostulacion(int adopcionId);
  Future<int> contarSolicitudes(int adopcionId);
  Future<void> aprobarPostulacion(
    int adopcionId,
    int postulacionId,
    String contactoResponsable,
  );
  Future<String> subirImagen(File imagen);
}

class AdopcionesRemoteDataSourceImpl implements AdopcionesRemoteDataSource {
  final Dio dio;

  AdopcionesRemoteDataSourceImpl(this.dio);

  Adopcion _adopcionDesdeJson(Map<String, dynamic> json) {
    final seleccion = json['postulacion_aprobada'] is Map
        ? Map<String, dynamic>.from(json['postulacion_aprobada'] as Map)
        : const <String, dynamic>{};
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
      estado: json['estado']?.toString() ?? 'activa',
      adoptanteId: _enteroOpcional(
        json['adoptante_id'] ??
            json['usuario_adoptante_id'] ??
            json['usuario_seleccionado_id'] ??
            seleccion['usuario_id_fk'],
      ),
      contactoResponsable:
          (json['contacto_responsable'] ?? seleccion['contacto_responsable'])
              ?.toString(),
      contactoAdoptante: (json['contacto_adoptante'] ?? seleccion['contacto'])
          ?.toString(),
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
  Future<String> subirImagen(File imagen) async {
    final nombreArchivo = imagen.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imagen.path,
        filename: nombreArchivo,
      ),
    });
    final response = await dio.post(
      '/adopciones/upload-imagen',
      data: formData,
    );
    return response.data['url'] as String;
  }

  @override
  Future<void> aprobarPostulacion(
    int adopcionId,
    int postulacionId,
    String contactoResponsable,
  ) async {
    await dio.put(
      '/adopciones/$adopcionId/postulaciones/$postulacionId/aprobar',
      data: {'contacto_responsable': contactoResponsable},
    );
  }

  int? _enteroOpcional(Object? valor) {
    if (valor is int) return valor;
    return int.tryParse(valor?.toString() ?? '');
  }

  @override
  Future<MiPostulacionAdopcion> obtenerMiPostulacion(int adopcionId) async {
    final response = await dio.get('/adopciones/$adopcionId/mi-postulacion');
    final raiz = Map<String, dynamic>.from(response.data as Map);
    final postulacion = raiz['postulacion'] is Map
        ? Map<String, dynamic>.from(raiz['postulacion'] as Map)
        : raiz;
    return MiPostulacionAdopcion(
      yaPostulado:
          raiz['ya_postulado'] == true ||
          raiz['yaPostulado'] == true ||
          raiz['postulacion'] is Map,
      estado:
          (postulacion['estado'] ?? raiz['estado_postulacion'])?.toString() ??
          (raiz['fue_aceptada'] == true ? 'aceptada' : null),
      contactoResponsable:
          (postulacion['contacto_responsable'] ??
                  raiz['contacto_responsable'] ??
                  raiz['medio_contacto'])
              ?.toString(),
    );
  }

  @override
  Future<int> contarSolicitudes(int adopcionId) async {
    final response = await dio.get(
      '/adopciones/$adopcionId/postulaciones/conteo',
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
  Future<Adopcion> actualizarAdopcion(CrearAdopcionSolicitud solicitud) async {
    final id = solicitud.id;
    if (id == null) {
      throw ArgumentError('La adopción a actualizar no tiene id.');
    }
    final response = await dio.put(
      '/adopciones/$id',
      data: _datosSolicitud(solicitud),
    );
    return _adopcionDesdeJson(response.data as Map<String, dynamic>);
  }

  Map<String, dynamic> _datosSolicitud(CrearAdopcionSolicitud solicitud) => {
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
  };

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
    required String contacto,
    required Map<int, String> respuestas,
  }) async {
    await dio.post(
      '/adopciones/$adopcionId/postulaciones',
      data: {
        'usuario_id_fk': usuarioId,
        'contacto': contacto,
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
    final response = await dio.get('/adopciones/$adopcionId/ranking');
    return List<Map<String, dynamic>>.from(response.data as List);
  }
}
