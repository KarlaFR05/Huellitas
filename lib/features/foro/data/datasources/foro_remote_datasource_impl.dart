import 'package:dio/dio.dart';
import 'foro_remote_datasource.dart';
import '../models/comentario_model.dart';
import '../models/grupo_model.dart';
import '../models/membresia_grupo_model.dart';
import '../models/pagina_model.dart';
import '../models/publicacion_model.dart';

class ForoRemoteDataSourceImpl implements ForoRemoteDataSource {
  final Dio dio;
  ForoRemoteDataSourceImpl(this.dio);

  // ============ PUBLICACIONES ============

  @override
  Future<PaginaModel<PublicacionModel>> obtenerFeed({
    String? categoria,
    int? grupoId,
    int? usuarioId,
    String? cursor,
    int limite = 20,
  }) async {
    final res = await dio.get(
      '/publicaciones/feed',
      queryParameters: {
        if (categoria != null) 'categoria': categoria,
        if (grupoId != null) 'grupo_id': grupoId,
        if (usuarioId != null) 'usuario_id': usuarioId,
        if (cursor != null) 'cursor': cursor,
        'limite': limite,
      },
    );
    return PaginaModel.fromJson(res.data, (j) => PublicacionModel.fromJson(j));
  }

  @override
  Future<PublicacionModel> obtenerPublicacion(int id) async {
    final res = await dio.get('/publicaciones/$id');
    return PublicacionModel.fromJson(res.data);
  }

  @override
  Future<PublicacionModel> crearPublicacion({
    required String titulo,
    required String contenido,
    String? categoria,
    int? grupoId,
    String? imagenPath,
    Map<String, String>? datosAdopcion,
  }) async {
    final formData = FormData.fromMap({
      'titulo': titulo,
      'contenido': contenido,
      if (categoria != null) 'categoria': categoria,
      if (grupoId != null) 'grupo_id': grupoId,
      if (datosAdopcion != null) ...datosAdopcion,
      if (imagenPath != null && imagenPath.isNotEmpty)
        'imagen': await MultipartFile.fromFile(
          imagenPath,
          filename: imagenPath.split('/').last,
        ),
    });
    final res = await dio.post('/publicaciones', data: formData);
    return PublicacionModel.fromJson(res.data);
  }

  @override
  Future<PublicacionModel> actualizarPublicacion(
    int id, {
    String? titulo,
    String? contenido,
    String? categoria,
    String? imagenPath,
  }) async {
    final formData = FormData.fromMap({
      if (titulo != null) 'titulo': titulo,
      if (contenido != null) 'contenido': contenido,
      if (categoria != null) 'categoria': categoria,
      if (imagenPath != null && imagenPath.isNotEmpty)
        'imagen': await MultipartFile.fromFile(
          imagenPath,
          filename: imagenPath.split('/').last,
        ),
    });
    final res = await dio.patch('/publicaciones/$id', data: formData);
    return PublicacionModel.fromJson(res.data);
  }

  @override
  Future<void> eliminarPublicacion(int id) async {
    await dio.delete('/publicaciones/$id');
  }

  @override
  Future<PublicacionModel> toggleMeGusta(int id) async {
    final res = await dio.post('/publicaciones/$id/me-gusta');
    return PublicacionModel.fromJson(res.data);
  }

  // ============ COMENTARIOS ============

  @override
  Future<PaginaModel<ComentarioModel>> obtenerComentarios(
    int publicacionId, {
    String? cursor,
    int limite = 30,
  }) async {
    final res = await dio.get(
      '/publicaciones/$publicacionId/comentarios',
      queryParameters: {if (cursor != null) 'cursor': cursor, 'limite': limite},
    );
    return PaginaModel.fromJson(res.data, (j) => ComentarioModel.fromJson(j));
  }

  @override
  Future<ComentarioModel> crearComentario({
    required int publicacionId,
    required String contenido,
    int? comentarioPadreId,
  }) async {
    final res = await dio.post(
      '/comentarios',
      data: {
        'publicacion_id': publicacionId,
        'contenido': contenido,
        if (comentarioPadreId != null) 'comentario_padre_id': comentarioPadreId,
      },
    );
    return ComentarioModel.fromJson(res.data);
  }

  @override
  Future<ComentarioModel> actualizarComentario(int id, String contenido) async {
    final res = await dio.patch(
      '/comentarios/$id',
      data: {'contenido': contenido},
    );
    return ComentarioModel.fromJson(res.data);
  }

  @override
  Future<void> eliminarComentario(int id) async {
    await dio.delete('/comentarios/$id');
  }

  // ============ GRUPOS ============

  @override
  Future<List<GrupoModel>> obtenerGrupos({
    String? busqueda,
    String? cursor,
    int limite = 20,
  }) async {
    final res = await dio.get(
      '/grupos',
      queryParameters: {
        if (busqueda != null) 'busqueda': busqueda,
        if (cursor != null) 'cursor': cursor,
        'limite': limite,
      },
    );
    return (res.data as List).map((j) => GrupoModel.fromJson(j)).toList();
  }

  @override
  Future<List<GrupoModel>> obtenerMisGrupos() async {
    final res = await dio.get('/grupos/mis-grupos');
    return (res.data as List).map((j) => GrupoModel.fromJson(j)).toList();
  }

  @override
  Future<GrupoModel> obtenerGrupo(int id) async {
    final res = await dio.get('/grupos/$id');
    return GrupoModel.fromJson(res.data);
  }

  @override
  Future<GrupoModel> crearGrupo({
    required String nombre,
    required String descripcion,
    String privacidad = 'publico',
    String? fotoPerfilPath,
    String? fotoPortadaPath,
  }) async {
    final formData = FormData.fromMap({
      'nombre': nombre,
      'descripcion': descripcion,
      'privacidad': privacidad,
      if (fotoPerfilPath != null && fotoPerfilPath.isNotEmpty)
        'foto_perfil': await MultipartFile.fromFile(
          fotoPerfilPath,
          filename: fotoPerfilPath.split('/').last,
        ),
      if (fotoPortadaPath != null && fotoPortadaPath.isNotEmpty)
        'foto_portada': await MultipartFile.fromFile(
          fotoPortadaPath,
          filename: fotoPortadaPath.split('/').last,
        ),
    });
    final res = await dio.post('/grupos', data: formData);
    return GrupoModel.fromJson(res.data);
  }

  @override
  Future<GrupoModel> actualizarGrupo(
    int id, {
    String? nombre,
    String? descripcion,
    String? privacidad,
    String? fotoPerfilPath,
    String? fotoPortadaPath,
  }) async {
    final formData = FormData.fromMap({
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (privacidad != null) 'privacidad': privacidad,
      if (fotoPerfilPath != null && fotoPerfilPath.isNotEmpty)
        'foto_perfil': await MultipartFile.fromFile(
          fotoPerfilPath,
          filename: fotoPerfilPath.split('/').last,
        ),
      if (fotoPortadaPath != null && fotoPortadaPath.isNotEmpty)
        'foto_portada': await MultipartFile.fromFile(
          fotoPortadaPath,
          filename: fotoPortadaPath.split('/').last,
        ),
    });
    final res = await dio.patch('/grupos/$id', data: formData);
    return GrupoModel.fromJson(res.data);
  }

  @override
  Future<GrupoModel> unirseAGrupo(int id) async {
    final res = await dio.post('/grupos/$id/unirse');
    return GrupoModel.fromJson(res.data);
  }

  @override
  Future<GrupoModel> salirDeGrupo(int id) async {
    final res = await dio.post('/grupos/$id/salir');
    return GrupoModel.fromJson(res.data);
  }

  @override
  Future<void> eliminarGrupo(int id) async {
    await dio.delete('/grupos/$id');
  }

  @override
  Future<GrupoModel> solicitarIngreso(int id) async {
    final res = await dio.post('/grupos/$id/solicitar');
    return GrupoModel.fromJson(res.data);
  }

  @override
  Future<void> cancelarSolicitud(int id) async {
    await dio.delete('/grupos/$id/solicitud');
  }

  @override
  Future<List<MembresiaGrupoModel>> obtenerSolicitudes(int grupoId) async {
    final res = await dio.get('/grupos/$grupoId/solicitudes');
    final data = res.data is Map && res.data['solicitudes'] is List
        ? res.data['solicitudes'] as List
        : res.data as List;
    return data
        .map(
          (json) => MembresiaGrupoModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  @override
  Future<List<MembresiaGrupoModel>> obtenerMiembros(int grupoId) async {
    final res = await dio.get('/grupos/$grupoId/miembros');
    final data = res.data is Map && res.data['miembros'] is List
        ? res.data['miembros'] as List
        : res.data as List;
    return data
        .map(
          (json) => MembresiaGrupoModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  @override
  Future<void> responderSolicitud({
    required int grupoId,
    required int usuarioId,
    required bool aceptar,
  }) async {
    await dio.post(
      '/grupos/$grupoId/solicitudes/responder',
      data: {'usuario_id': usuarioId, 'aceptar': aceptar},
    );
  }

  @override
  Future<void> eliminarMiembro({
    required int grupoId,
    required int usuarioId,
  }) async {
    await dio.post(
      '/grupos/$grupoId/miembros/eliminar',
      data: {'usuario_id': usuarioId},
    );
  }
}
