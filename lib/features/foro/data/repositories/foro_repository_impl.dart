import '../../domain/entities/comentario.dart';
import '../../domain/entities/grupo.dart';
import '../../domain/entities/membresia_grupo.dart';
import '../../domain/entities/pagina.dart';
import '../../domain/entities/publicacion.dart';
import '../../domain/entities/solicitudes_foro.dart';
import '../../domain/repositories/foro_repository.dart';
import '../datasources/foro_remote_datasource.dart';

class ForoRepositoryImpl implements ForoRepository {
  final ForoRemoteDataSource remote;
  ForoRepositoryImpl(this.remote);

  // ============ PUBLICACIONES ============

  @override
  Future<Pagina<Publicacion>> obtenerFeed(FiltroPublicaciones filtro) async {
    final pagina = await remote.obtenerFeed(
      categoria: filtro.categoria?.name,
      grupoId: filtro.grupoId,
      cursor: filtro.cursor,
      limite: filtro.limite,
    );
    return Pagina(
      elementos: pagina.elementos.map((m) => m.toEntity()).toList(),
      siguienteCursor: pagina.siguienteCursor,
      hayMas: pagina.hayMas,
    );
  }

  @override
  Future<Publicacion> obtenerPublicacion(int publicacionId) async {
    final model = await remote.obtenerPublicacion(publicacionId);
    return model.toEntity();
  }

  @override
  Future<Publicacion> crearPublicacion(
    CrearPublicacionSolicitud solicitud,
  ) async {
    final model = await remote.crearPublicacion(
      titulo: solicitud.titulo,
      contenido: solicitud.contenido,
      categoria: solicitud.categoria.name,
      grupoId: solicitud.grupoId,
      imagenPath: solicitud.imagenLocalPath,
    );
    return model.toEntity();
  }

  @override
  Future<Publicacion> actualizarPublicacion(
    int publicacionId, {
    String? titulo,
    String? contenido,
    CategoriaPublicacion? categoria,
    String? imagenLocalPath,
  }) async {
    final model = await remote.actualizarPublicacion(
      publicacionId,
      titulo: titulo,
      contenido: contenido,
      categoria: categoria?.name,
      imagenPath: imagenLocalPath,
    );
    return model.toEntity();
  }

  @override
  Future<void> eliminarPublicacion(int publicacionId) async {
    await remote.eliminarPublicacion(publicacionId);
  }

  @override
  Future<Publicacion> cambiarMeGusta(int publicacionId) async {
    final model = await remote.toggleMeGusta(publicacionId);
    return model.toEntity();
  }

  // ============ COMENTARIOS ============

  @override
  Future<Pagina<Comentario>> obtenerComentarios(
    int publicacionId, {
    String? cursor,
    int limite = 30,
  }) async {
    final pagina = await remote.obtenerComentarios(
      publicacionId,
      cursor: cursor,
      limite: limite,
    );
    return Pagina(
      elementos: pagina.elementos.map((m) => m.toEntity()).toList(),
      siguienteCursor: pagina.siguienteCursor,
      hayMas: pagina.hayMas,
    );
  }

  @override
  Future<Comentario> crearComentario(CrearComentarioSolicitud solicitud) async {
    final model = await remote.crearComentario(
      publicacionId: solicitud.publicacionId,
      contenido: solicitud.contenido,
      comentarioPadreId: solicitud.comentarioPadreId,
    );
    return model.toEntity();
  }

  @override
  Future<Comentario> actualizarComentario(
    int comentarioId,
    String contenido,
  ) async {
    final model = await remote.actualizarComentario(comentarioId, contenido);
    return model.toEntity();
  }

  @override
  Future<void> eliminarComentario(int comentarioId) async {
    await remote.eliminarComentario(comentarioId);
  }

  // ============ GRUPOS ============

  @override
  Future<Pagina<Grupo>> obtenerGrupos({
    String? busqueda,
    String? cursor,
    int limite = 20,
  }) async {
    // El backend devuelve List, lo envolvemos en Pagina sin cursor
    final lista = await remote.obtenerGrupos(
      busqueda: busqueda,
      cursor: cursor,
      limite: limite,
    );
    return Pagina(
      elementos: lista.map((m) => m.toEntity()).toList(),
      siguienteCursor: lista.length >= limite ? lista.last.id.toString() : null,
      hayMas: lista.length >= limite,
    );
  }

  @override
  Future<List<Grupo>> obtenerMisGrupos() async {
    final lista = await remote.obtenerMisGrupos();
    return lista.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Grupo> obtenerGrupo(int grupoId) async {
    final model = await remote.obtenerGrupo(grupoId);
    return model.toEntity();
  }

  @override
  Future<Grupo> crearGrupo(CrearGrupoSolicitud solicitud) async {
    final model = await remote.crearGrupo(
      nombre: solicitud.nombre,
      descripcion: solicitud.descripcion,
      privacidad: solicitud.privacidad.name,
      fotoPerfilPath: solicitud.fotoPerfilLocalPath,
      fotoPortadaPath: solicitud.fotoPortadaLocalPath,
    );
    return model.toEntity();
  }

  @override
  Future<Grupo> unirseAGrupo(int grupoId) async {
    final model = await remote.unirseAGrupo(grupoId);
    return model.toEntity();
  }

  @override
  Future<Grupo> salirDeGrupo(int grupoId) async {
    final model = await remote.salirDeGrupo(grupoId);
    return model.toEntity();
  }

  @override
  Future<void> eliminarGrupo(int grupoId) => remote.eliminarGrupo(grupoId);

  @override
  Future<Grupo> solicitarIngresoGrupo(int grupoId) async {
    final model = await remote.solicitarIngreso(grupoId);
    return model.toEntity();
  }

  @override
  Future<void> cancelarSolicitudIngreso(int grupoId) async {
    await remote.cancelarSolicitud(grupoId);
  }

  @override
  Future<List<MembresiaGrupo>> obtenerSolicitudesIngreso(int grupoId) async {
    final lista = await remote.obtenerSolicitudes(grupoId);
    return lista.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<MembresiaGrupo>> obtenerMiembrosGrupo(int grupoId) async {
    final lista = await remote.obtenerMiembros(grupoId);
    return lista.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> responderSolicitudIngreso({
    required int grupoId,
    required int usuarioId,
    required bool aceptar,
  }) async {
    await remote.responderSolicitud(
      grupoId: grupoId,
      usuarioId: usuarioId,
      aceptar: aceptar,
    );
  }

  @override
  Future<void> eliminarMiembroGrupo({
    required int grupoId,
    required int usuarioId,
  }) async {
    await remote.eliminarMiembro(grupoId: grupoId, usuarioId: usuarioId);
  }

  @override
  Future<Grupo> actualizarGrupo(
    int grupoId, {
    String? nombre,
    String? descripcion,
    PrivacidadGrupo? privacidad,
    String? fotoPerfilLocalPath,
    String? fotoPortadaLocalPath,
  }) async {
    final model = await remote.actualizarGrupo(
      grupoId,
      nombre: nombre,
      descripcion: descripcion,
      privacidad: privacidad?.name,
      fotoPerfilPath: fotoPerfilLocalPath,
      fotoPortadaPath: fotoPortadaLocalPath,
    );
    return model.toEntity();
  }
}
