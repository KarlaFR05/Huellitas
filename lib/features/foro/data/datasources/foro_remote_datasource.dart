import '../models/comentario_model.dart';
import '../models/grupo_model.dart';
import '../models/membresia_grupo_model.dart';
import '../models/pagina_model.dart';
import '../models/publicacion_model.dart';

abstract class ForoRemoteDataSource {
  // Publicaciones
  Future<PaginaModel<PublicacionModel>> obtenerFeed({
    String? categoria,
    int? grupoId,
    String? cursor,
    int limite,
  });
  Future<PublicacionModel> obtenerPublicacion(int id);
  Future<PublicacionModel> crearPublicacion({
    required String titulo,
    required String contenido,
    String? categoria,
    int? grupoId,
    String? imagenPath,
  });
  Future<PublicacionModel> actualizarPublicacion(
    int id, {
    String? titulo,
    String? contenido,
    String? categoria,
    String? imagenPath,
  });
  Future<void> eliminarPublicacion(int id);
  Future<PublicacionModel> toggleMeGusta(int id);

  // Comentarios
  Future<PaginaModel<ComentarioModel>> obtenerComentarios(
    int publicacionId, {
    String? cursor,
    int limite,
  });
  Future<ComentarioModel> crearComentario({
    required int publicacionId,
    required String contenido,
    int? comentarioPadreId,
  });
  Future<ComentarioModel> actualizarComentario(int id, String contenido);
  Future<void> eliminarComentario(int id);

  // Grupos
  Future<List<GrupoModel>> obtenerGrupos({
    String? busqueda,
    String? cursor,
    int limite,
  });
  Future<List<GrupoModel>> obtenerMisGrupos();
  Future<GrupoModel> obtenerGrupo(int id);
  Future<GrupoModel> crearGrupo({
    required String nombre,
    required String descripcion,
    String privacidad,
    String? fotoPerfilPath,
    String? fotoPortadaPath,
  });
  Future<GrupoModel> actualizarGrupo(
    int id, {
    String? nombre,
    String? descripcion,
    String? privacidad,
    String? fotoPerfilPath,
    String? fotoPortadaPath,
  });
  Future<GrupoModel> unirseAGrupo(int id);
  Future<GrupoModel> salirDeGrupo(int id);
  Future<GrupoModel> solicitarIngreso(int id);
  Future<void> cancelarSolicitud(int id);
  Future<List<MembresiaGrupoModel>> obtenerSolicitudes(int grupoId);
  Future<void> responderSolicitud({
    required int grupoId,
    required int usuarioId,
    required bool aceptar,
  });
  Future<void> eliminarMiembro({
    required int grupoId,
    required int usuarioId,
  });
}