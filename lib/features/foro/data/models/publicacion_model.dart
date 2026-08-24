import '../../domain/entities/publicacion.dart';

class PublicacionModel {
  final int id;
  final int? usuarioId;
  final int? grupoId;
  final String titulo;
  final String nombreUsuario;
  final String? fotoUsuarioUrl;
  final String contenido;
  final String? imagenUrl;
  final String? categoria;
  final String estado;
  final String? nombreGrupo;
  final DateTime fecha;
  final DateTime? fechaActualizacion;
  final DateTime? fechaEliminacion;
  final int meGusta;
  final int comentarios;
  final bool leGustaAlUsuario;

  PublicacionModel({
    required this.id,
    this.usuarioId,
    this.grupoId,
    required this.titulo,
    required this.nombreUsuario,
    this.fotoUsuarioUrl,
    required this.contenido,
    this.imagenUrl,
    this.categoria,
    required this.estado,
    this.nombreGrupo,
    required this.fecha,
    this.fechaActualizacion,
    this.fechaEliminacion,
    required this.meGusta,
    required this.comentarios,
    required this.leGustaAlUsuario,
  });

  factory PublicacionModel.fromJson(Map<String, dynamic> json) {
    final usuario = json['usuario'] is Map
        ? Map<String, dynamic>.from(json['usuario'] as Map)
        : const <String, dynamic>{};
    final adopcion = json['datos_adopcion'] is Map
        ? Map<String, dynamic>.from(json['datos_adopcion'] as Map)
        : json;
    final esAdopcion = json['categoria'] == 'adopcion';
    final nombreMascota = adopcion['nombre_mascota'] ?? adopcion['mascota_nombre'];
    return PublicacionModel(
      id: json['publicacion_id'] as int,
      usuarioId: _enteroOpcional(
        json['usuario_id'] ??
            json['usuario_id_fk'] ??
            json['autor_id'] ??
            usuario['usuario_id_pk'] ??
            usuario['usuario_id'] ??
            usuario['id'],
      ),
      grupoId: json['grupo_id_fk'] as int?,
      titulo: json['titulo'] as String,
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
      imagenUrl: json['imagen_url'] as String?,
      categoria: json['categoria'] as String?,
      estado: json['estado'] as String,
      nombreGrupo: json['nombre_grupo'] as String?,
      fecha: DateTime.parse(json['fecha_publicacion'] as String),
      fechaActualizacion: json['fecha_actualizacion'] != null
          ? DateTime.parse(json['fecha_actualizacion'] as String)
          : null,
      fechaEliminacion: json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'] as String)
          : null,
      meGusta: json['me_gusta'] as int? ?? 0,
      comentarios: json['comentarios'] as int? ?? 0,
      leGustaAlUsuario: json['le_gusta_al_usuario'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'publicacion_id': id,
    'usuario_id': usuarioId,
    'grupo_id_fk': grupoId,
    'titulo': titulo,
    'contenido': contenido,
    'categoria': categoria,
  };

  Publicacion toEntity() => Publicacion(
    id: id,
    usuarioId: usuarioId,
    grupoId: grupoId,
    titulo: titulo,
    nombreUsuario: nombreUsuario,
    fotoUsuarioUrl: fotoUsuarioUrl,
    contenido: contenido,
    imagenUrl: imagenUrl,
    categoria: _parseCategoria(categoria),
    estado: _parseEstado(estado),
    nombreGrupo: nombreGrupo,
    fecha: fecha,
    fechaActualizacion: fechaActualizacion,
    fechaEliminacion: fechaEliminacion,
    meGusta: meGusta,
    comentarios: comentarios,
    leGustaAlUsuario: leGustaAlUsuario,
  );

  static CategoriaPublicacion _parseCategoria(String? c) {
    if (c == null) return CategoriaPublicacion.cuidado;
    return CategoriaPublicacion.values.firstWhere(
      (e) => e.name == c,
      orElse: () => CategoriaPublicacion.cuidado,
    );
  }

  static EstadoPublicacion _parseEstado(String e) {
    return EstadoPublicacion.values.firstWhere(
      (x) => x.name == e,
      orElse: () => EstadoPublicacion.activa,
    );
  }

  static String? _textoOpcional(Object? valor) {
    final texto = valor?.toString().trim();
    return texto == null || texto.isEmpty ? null : texto;
  }

  static int? _enteroOpcional(Object? valor) {
    if (valor is int) return valor;
    return int.tryParse(valor?.toString() ?? '');
  }
}
