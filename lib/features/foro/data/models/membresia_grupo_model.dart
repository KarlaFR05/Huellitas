import '../../domain/entities/membresia_grupo.dart';

class MembresiaGrupoModel {
  final int miembroId;
  final int grupoId;
  final int usuarioId;
  final String rol;
  final String estado;
  final DateTime fechaSolicitud;
  final DateTime? fechaIngreso;
  final String? nombreUsuario;
  final String? fotoUsuarioUrl;

  MembresiaGrupoModel({
    required this.miembroId,
    required this.grupoId,
    required this.usuarioId,
    required this.rol,
    required this.estado,
    required this.fechaSolicitud,
    this.fechaIngreso,
    this.nombreUsuario,
    this.fotoUsuarioUrl,
  });

  factory MembresiaGrupoModel.fromJson(Map<String, dynamic> json) {
    return MembresiaGrupoModel(
      miembroId: json['miembro_id'] as int? ?? 0,
      grupoId: json['grupo_id_fk'] as int? ?? 0,
      usuarioId: json['usuario_id_fk'] as int,
      rol: json['rol'] as String? ?? 'miembro',
      estado: json['estado'] as String? ?? 'activa',
      fechaSolicitud: DateTime.parse(json['fecha_solicitud'] as String),
      fechaIngreso: json['fecha_ingreso'] != null
          ? DateTime.parse(json['fecha_ingreso'] as String)
          : null,
      nombreUsuario: json['nombre_usuario'] as String?,
      fotoUsuarioUrl: json['foto_usuario'] as String?,
    );
  }

  MembresiaGrupo toEntity() => MembresiaGrupo(
        grupoId: grupoId,
        usuarioId: usuarioId,
        rol: RolMiembroGrupo.values.firstWhere(
          (e) => e.name == rol,
          orElse: () => RolMiembroGrupo.miembro,
        ),
        estado: EstadoMembresiaGrupo.values.firstWhere(
          (e) => e.name == estado,
          orElse: () => EstadoMembresiaGrupo.activa,
        ),
        fechaSolicitud: fechaSolicitud,
        fechaIngreso: fechaIngreso,
        nombreUsuario: nombreUsuario,
        fotoUsuarioUrl: fotoUsuarioUrl,
      );
}