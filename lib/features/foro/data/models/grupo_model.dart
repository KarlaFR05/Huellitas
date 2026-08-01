import '../../domain/entities/grupo.dart';

class GrupoModel {
  final int id;
  final int? creadorUsuarioId;
  final String nombre;
  final String descripcion;
  final String fotoPerfil;
  final String fotoPortada;
  final String privacidad;
  final String estado;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final int cantidadMiembros;
  final bool esMiembro;
  final bool esAdministradorActual;
  final bool solicitudPendiente;

  GrupoModel({
    required this.id,
    this.creadorUsuarioId,
    required this.nombre,
    required this.descripcion,
    required this.fotoPerfil,
    required this.fotoPortada,
    required this.privacidad,
    required this.estado,
    this.fechaCreacion,
    this.fechaActualizacion,
    required this.cantidadMiembros,
    required this.esMiembro,
    required this.esAdministradorActual,
    required this.solicitudPendiente,
  });

  factory GrupoModel.fromJson(Map<String, dynamic> json) {
    return GrupoModel(
      id: json['grupo_id'] as int,
      creadorUsuarioId: json['creador_usuario'] as int?,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      fotoPerfil: json['foto_perfil'] as String? ?? '',
      fotoPortada: json['foto_portada'] as String? ?? '',
      privacidad: json['privacidad'] as String? ?? 'publico',
      estado: json['estado'] as String? ?? 'activo',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : null,
      fechaActualizacion: json['fecha_actualizacion'] != null
          ? DateTime.parse(json['fecha_actualizacion'] as String)
          : null,
      cantidadMiembros: json['cantidad_miembros'] as int? ?? 0,
      esMiembro: json['es_miembro'] as bool? ?? false,
      esAdministradorActual: json['es_administrador_actual'] as bool? ?? false,
      solicitudPendiente: json['solicitud_pendiente'] as bool? ?? false,
    );
  }

  Grupo toEntity() => Grupo(
        id: id,
        creadorUsuarioId: creadorUsuarioId,
        nombre: nombre,
        descripcion: descripcion,
        fotoPerfil: fotoPerfil,
        fotoPortada: fotoPortada,
        privacidad: PrivacidadGrupo.values.firstWhere(
          (e) => e.name == privacidad,
          orElse: () => PrivacidadGrupo.publico,
        ),
        estado: EstadoGrupo.values.firstWhere(
          (e) => e.name == estado,
          orElse: () => EstadoGrupo.activo,
        ),
        fechaCreacion: fechaCreacion,
        fechaActualizacion: fechaActualizacion,
        cantidadMiembros: cantidadMiembros,
        esMiembro: esMiembro,
        esAdministradorActual: esAdministradorActual,
        solicitudPendiente: solicitudPendiente,
      );
}