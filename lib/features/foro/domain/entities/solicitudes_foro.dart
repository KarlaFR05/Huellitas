import 'grupo.dart';
import 'publicacion.dart';

class FiltroPublicaciones {
  final CategoriaPublicacion? categoria;
  final int? grupoId;
  final int? organizacionId;
  final int? usuarioId;
  final bool soloGruposDelUsuario;
  final String? cursor;
  final int limite;

  const FiltroPublicaciones({
    this.categoria,
    this.grupoId,
    this.organizacionId,
    this.usuarioId,
    this.soloGruposDelUsuario = false,
    this.cursor,
    this.limite = 20,
  });
}

class CrearPublicacionSolicitud {
  final String titulo;
  final String contenido;
  final CategoriaPublicacion categoria;
  final int? grupoId;
  final int? organizacionId;
  final String? imagenLocalPath;

  const CrearPublicacionSolicitud({
    required this.titulo,
    required this.contenido,
    required this.categoria,
    this.grupoId,
    this.organizacionId,
    this.imagenLocalPath,
  });
}

class CrearComentarioSolicitud {
  final int publicacionId;
  final String contenido;
  final int? comentarioPadreId;

  const CrearComentarioSolicitud({
    required this.publicacionId,
    required this.contenido,
    this.comentarioPadreId,
  });
}

class CrearGrupoSolicitud {
  final String nombre;
  final String descripcion;
  final String? fotoPerfilLocalPath;
  final String? fotoPortadaLocalPath;
  final PrivacidadGrupo privacidad;

  const CrearGrupoSolicitud({
    required this.nombre,
    required this.descripcion,
    this.fotoPerfilLocalPath,
    this.fotoPortadaLocalPath,
    this.privacidad = PrivacidadGrupo.publico,
  });
}