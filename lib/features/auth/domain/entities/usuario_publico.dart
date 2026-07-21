class UsuarioPublico {
  final int usuarioIdPk;
  final String nombre;
  final String apellidos;
  final String nombreUsuario;
  final String correo;
  final String numTelefono;
  final String? fotoPerfil;
  final bool verificado;

  const UsuarioPublico({
    required this.usuarioIdPk,
    required this.nombre,
    required this.apellidos,
    required this.nombreUsuario,
    required this.correo,
    required this.numTelefono,
    this.fotoPerfil,
    required this.verificado,
  });

  factory UsuarioPublico.fromJson(Map<String, dynamic> json) {
    return UsuarioPublico(
      usuarioIdPk: json['usuario_id_pk'],
      nombre: json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      nombreUsuario: json['nombre_usuario'] ?? '',
      correo: json['correo'] ?? '',
      numTelefono: json['num_telefono'] ?? '',
      fotoPerfil: json['foto_perfil'],
      verificado: json['verificado'] ?? false,
    );
  }
}
