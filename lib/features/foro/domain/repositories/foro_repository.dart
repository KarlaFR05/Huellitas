import '../entities/comentario.dart';
import '../entities/grupo.dart';
import '../entities/membresia_grupo.dart';
import '../entities/pagina.dart';
import '../entities/publicacion.dart';
import '../entities/solicitudes_foro.dart';

abstract class ForoRepository {
  Future<Pagina<Publicacion>> obtenerFeed(FiltroPublicaciones filtro);
  Future<Publicacion> obtenerPublicacion(int publicacionId);
  Future<Publicacion> crearPublicacion(CrearPublicacionSolicitud solicitud);
  Future<Publicacion> actualizarPublicacion(
    int publicacionId, {
    String? titulo,
    String? contenido,
    CategoriaPublicacion? categoria,
  });
  Future<void> eliminarPublicacion(int publicacionId);
  Future<Publicacion> cambiarMeGusta(int publicacionId);

  Future<Pagina<Comentario>> obtenerComentarios(
    int publicacionId, {
    String? cursor,
    int limite = 30,
  });
  Future<Comentario> crearComentario(CrearComentarioSolicitud solicitud);
  Future<Comentario> actualizarComentario(int comentarioId, String contenido);
  Future<void> eliminarComentario(int comentarioId);

  Future<Pagina<Grupo>> obtenerGrupos({
    String? busqueda,
    String? cursor,
    int limite = 20,
  });
  Future<List<Grupo>> obtenerMisGrupos();
  Future<Grupo> obtenerGrupo(int grupoId);
  Future<Grupo> crearGrupo(CrearGrupoSolicitud solicitud);
  Future<Grupo> unirseAGrupo(int grupoId);
  Future<Grupo> salirDeGrupo(int grupoId);
  Future<Grupo> solicitarIngresoGrupo(int grupoId);
  Future<void> cancelarSolicitudIngreso(int grupoId);
  Future<List<MembresiaGrupo>> obtenerSolicitudesIngreso(int grupoId);
  Future<List<MembresiaGrupo>> obtenerMiembrosGrupo(int grupoId);
  Future<void> responderSolicitudIngreso({
    required int grupoId,
    required int usuarioId,
    required bool aceptar,
  });
  Future<void> eliminarMiembroGrupo({
    required int grupoId,
    required int usuarioId,
  });
}
