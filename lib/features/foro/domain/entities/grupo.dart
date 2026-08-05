enum PrivacidadGrupo { publico, privado }

enum EstadoGrupo { activo, archivado, eliminado }

class Grupo {
  final int id;
  final int? creadorUsuarioId;
  final String nombre;
  final String descripcion;
  final String fotoPerfil;
  final String fotoPortada;
  final String? fotoPerfilLocalPath;
  final String? fotoPortadaLocalPath;
  final PrivacidadGrupo privacidad;
  final EstadoGrupo estado;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final int cantidadMiembros;
  final bool esMiembro;
  final bool esAdministradorActual;
  final bool solicitudPendiente;

  const Grupo({
    required this.id,
    this.creadorUsuarioId,
    required this.nombre,
    required this.descripcion,
    required this.fotoPerfil,
    required this.fotoPortada,
    this.fotoPerfilLocalPath,
    this.fotoPortadaLocalPath,
    this.privacidad = PrivacidadGrupo.publico,
    this.estado = EstadoGrupo.activo,
    this.fechaCreacion,
    this.fechaActualizacion,
    this.cantidadMiembros = 0,
    this.esMiembro = false,
    this.esAdministradorActual = false,
    this.solicitudPendiente = false,
  });

  Grupo copyWith({
    int? id,
    int? creadorUsuarioId,
    String? nombre,
    String? descripcion,
    String? fotoPerfil,
    String? fotoPortada,
    String? fotoPerfilLocalPath,
    String? fotoPortadaLocalPath,
    PrivacidadGrupo? privacidad,
    EstadoGrupo? estado,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    int? cantidadMiembros,
    bool? esMiembro,
    bool? esAdministradorActual,
    bool? solicitudPendiente,
  }) {
    return Grupo(
      id: id ?? this.id,
      creadorUsuarioId: creadorUsuarioId ?? this.creadorUsuarioId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      fotoPortada: fotoPortada ?? this.fotoPortada,
      fotoPerfilLocalPath: fotoPerfilLocalPath ?? this.fotoPerfilLocalPath,
      fotoPortadaLocalPath: fotoPortadaLocalPath ?? this.fotoPortadaLocalPath,
      privacidad: privacidad ?? this.privacidad,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      cantidadMiembros: cantidadMiembros ?? this.cantidadMiembros,
      esMiembro: esMiembro ?? this.esMiembro,
      esAdministradorActual:
          esAdministradorActual ?? this.esAdministradorActual,
      solicitudPendiente: solicitudPendiente ?? this.solicitudPendiente,
    );
  }
}
