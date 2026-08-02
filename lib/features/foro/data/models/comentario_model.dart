import '../../domain/entities/comentario.dart';

class ComentarioModel {
  final int id;
  final int publicacionId;
  final int? usuarioId;
  final int? comentarioPadreId;
  final String nombreUsuario;
  final String? fotoUsuarioUrl;
  final String contenido;
  final String estado;
  final DateTime fechaCreacion;
  final DateTime? fechaEdicion;
  final DateTime? fechaEliminacion;
  final int cantidadMeGusta;
  final bool leGustaAlUsuario;

  ComentarioModel({
    required this.id,
    required this.publicacionId,
    this.usuarioId,
    this.comentarioPadreId,
    required this.nombreUsuario,
    this.fotoUsuarioUrl,
    required this.contenido,
    required this.estado,
    required this.fechaCreacion,
    this.fechaEdicion,
    this.fechaEliminacion,
    required this.cantidadMeGusta,
    required this.leGustaAlUsuario,
  });

  factory ComentarioModel.fromJson(Map<String, dynamic> json) {
    final usuario = json['usuario'] is Map
        ? Map<String, dynamic>.from(json['usuario'] as Map)
        : const <String, dynamic>{};
    return ComentarioModel(
      id: json['comentario_id'] as int,
      publicacionId: json['publicacion_id_fk'] as int,
      usuarioId: json['usuario_id_fk'] as int?,
      comentarioPadreId: json['comentario_padre_id'] as int?,
      nombreUsuario:
          (json['nombre_usuario'] ??
                  usuario['nombre_usuario'] ??
                  usuario['nombreUsuario'] ??
                  usuario['nombre'] ??
                  'Usuario')
              .toString(),
      fotoUsuarioUrl: _textoOpcional(
        json['foto_usuario'] ??
            json['foto_perfil'] ??
            usuario['foto_perfil'] ??
            usuario['fotoPerfil'],
      ),
      contenido: json['contenido'] as String,
      estado: json['estado'] as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      fechaEdicion: json['fecha_edicion'] != null
          ? DateTime.parse(json['fecha_edicion'] as String)
          : null,
      fechaEliminacion: json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'] as String)
          : null,
      cantidadMeGusta: json['cantidad_me_gusta'] as int? ?? 0,
      leGustaAlUsuario: json['le_gusta_al_usuario'] as bool? ?? false,
    );
  }

  Comentario toEntity() => Comentario(
    id: id,
    publicacionId: publicacionId,
    usuarioId: usuarioId,
    comentarioPadreId: comentarioPadreId,
    nombreUsuario: nombreUsuario,
    fotoUsuarioUrl: fotoUsuarioUrl,
    contenido: contenido,
    estado: EstadoComentario.values.firstWhere(
      (e) => e.name == estado,
      orElse: () => EstadoComentario.activo,
    ),
    fechaCreacion: fechaCreacion,
    fechaEdicion: fechaEdicion,
    fechaEliminacion: fechaEliminacion,
    cantidadMeGusta: cantidadMeGusta,
    leGustaAlUsuario: leGustaAlUsuario,
  );

  static String? _textoOpcional(Object? valor) {
    final texto = valor?.toString().trim();
    return texto == null || texto.isEmpty ? null : texto;
  }
}
