enum RolMiembroGrupo { administrador, miembro }

enum EstadoMembresiaGrupo { activa, pendiente, bloqueada, abandonada }

class MembresiaGrupo {
  final int grupoId;
  final int usuarioId;
  final RolMiembroGrupo rol;
  final EstadoMembresiaGrupo estado;
  final DateTime fechaSolicitud;
  final DateTime? fechaIngreso;
  final DateTime? fechaSalida;
  final String? nombreUsuario;
  final String? fotoUsuarioUrl;

  const MembresiaGrupo({
    required this.grupoId,
    required this.usuarioId,
    this.rol = RolMiembroGrupo.miembro,
    this.estado = EstadoMembresiaGrupo.activa,
    required this.fechaSolicitud,
    this.fechaIngreso,
    this.fechaSalida,
    this.nombreUsuario,
    this.fotoUsuarioUrl,
  });

  bool get esAdministrador => rol == RolMiembroGrupo.administrador;
  bool get estaPendiente => estado == EstadoMembresiaGrupo.pendiente;
}
