enum CategoriaPublicacion {
  adopcion,
  vacunacion,
  salud,
  extraviados,
  alimentacion,
  entrenamiento,
  cuidado,
}

enum EstadoPublicacion { activa, oculta, eliminada }

class Publicacion {
  final int id;
  final int? usuarioId;
  final int? grupoId;
  final String titulo;
  final String nombreUsuario;
  final String? fotoUsuarioUrl;
  final String contenido;
  final String? imagenUrl;
  final String? imagenPath;
  final CategoriaPublicacion categoria;
  final EstadoPublicacion estado;
  final String? nombreGrupo;
  final DateTime fecha;
  final DateTime? fechaActualizacion;
  final DateTime? fechaEliminacion;
  final int meGusta;
  final int comentarios;
  final bool leGustaAlUsuario;

  const Publicacion({
    required this.id,
    this.usuarioId,
    this.grupoId,
    required this.titulo,
    required this.nombreUsuario,
    this.fotoUsuarioUrl,
    required this.contenido,
    this.imagenUrl,
    this.imagenPath,
    this.categoria = CategoriaPublicacion.cuidado,
    this.estado = EstadoPublicacion.activa,
    this.nombreGrupo,
    required this.fecha,
    this.fechaActualizacion,
    this.fechaEliminacion,
    this.meGusta = 0,
    this.comentarios = 0,
    this.leGustaAlUsuario = false,
  });

  Publicacion copyWith({
    int? id,
    int? usuarioId,
    int? grupoId,
    String? titulo,
    String? nombreUsuario,
    String? fotoUsuarioUrl,
    String? contenido,
    String? imagenUrl,
    String? imagenPath,
    CategoriaPublicacion? categoria,
    EstadoPublicacion? estado,
    String? nombreGrupo,
    DateTime? fecha,
    DateTime? fechaActualizacion,
    DateTime? fechaEliminacion,
    int? meGusta,
    int? comentarios,
    bool? leGustaAlUsuario,
  }) {
    return Publicacion(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      grupoId: grupoId ?? this.grupoId,
      titulo: titulo ?? this.titulo,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      fotoUsuarioUrl: fotoUsuarioUrl ?? this.fotoUsuarioUrl,
      contenido: contenido ?? this.contenido,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      imagenPath: imagenPath ?? this.imagenPath,
      categoria: categoria ?? this.categoria,
      estado: estado ?? this.estado,
      nombreGrupo: nombreGrupo ?? this.nombreGrupo,
      fecha: fecha ?? this.fecha,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
      meGusta: meGusta ?? this.meGusta,
      comentarios: comentarios ?? this.comentarios,
      leGustaAlUsuario: leGustaAlUsuario ?? this.leGustaAlUsuario,
    );
  }
}
