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
    final usuario = json['usuario'] is Map
        ? Map<String, dynamic>.from(json['usuario'] as Map)
        : const <String, dynamic>{};
    return MembresiaGrupoModel(
      miembroId: json['miembro_id'] as int? ?? 0,
      grupoId: json['grupo_id_fk'] as int? ?? 0,
      usuarioId: json['usuario_id_fk'] as int,
      rol: json['rol'] as String? ?? 'miembro',
      estado: json['estado'] as String? ?? 'activa',
      fechaSolicitud:
          _fechaOpcional(json['fecha_solicitud']) ??
          _fechaOpcional(json['fecha_ingreso']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      fechaIngreso: _fechaOpcional(json['fecha_ingreso']),
      nombreUsuario:
          (json['nombre_usuario'] ??
                  usuario['nombre_usuario'] ??
                  usuario['nombreUsuario'] ??
                  usuario['nombre'])
              ?.toString(),
      fotoUsuarioUrl: _textoOpcional(
        json['foto_usuario'] ??
            json['foto_perfil'] ??
            usuario['foto_perfil'] ??
            usuario['fotoPerfil'],
      ),
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

  static String? _textoOpcional(Object? valor) {
    final texto = valor?.toString().trim();
    return texto == null || texto.isEmpty ? null : texto;
  }

  static DateTime? _fechaOpcional(Object? valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString());
  }
}
