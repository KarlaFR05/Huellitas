enum EstadoComentario { activo, oculto, eliminado }

class Comentario {
  final int id;
  final int publicacionId;
  final int? usuarioId;
  final int? comentarioPadreId;
  final String nombreUsuario;
  final String? fotoUsuarioUrl;
  final String contenido;
  final EstadoComentario estado;
  final DateTime fechaCreacion;
  final DateTime? fechaEdicion;
  final DateTime? fechaEliminacion;
  final int cantidadMeGusta;
  final bool leGustaAlUsuario;

  const Comentario({
    required this.id,
    required this.publicacionId,
    this.usuarioId,
    this.comentarioPadreId,
    required this.nombreUsuario,
    this.fotoUsuarioUrl,
    required this.contenido,
    this.estado = EstadoComentario.activo,
    required this.fechaCreacion,
    this.fechaEdicion,
    this.fechaEliminacion,
    this.cantidadMeGusta = 0,
    this.leGustaAlUsuario = false,
  });

  Comentario copyWith({
    String? contenido,
    EstadoComentario? estado,
    DateTime? fechaEdicion,
    DateTime? fechaEliminacion,
    int? cantidadMeGusta,
    bool? leGustaAlUsuario,
  }) {
    return Comentario(
      id: id,
      publicacionId: publicacionId,
      usuarioId: usuarioId,
      comentarioPadreId: comentarioPadreId,
      nombreUsuario: nombreUsuario,
      fotoUsuarioUrl: fotoUsuarioUrl,
      contenido: contenido ?? this.contenido,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion,
      fechaEdicion: fechaEdicion ?? this.fechaEdicion,
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
      cantidadMeGusta: cantidadMeGusta ?? this.cantidadMeGusta,
      leGustaAlUsuario: leGustaAlUsuario ?? this.leGustaAlUsuario,
    );
  }
}
