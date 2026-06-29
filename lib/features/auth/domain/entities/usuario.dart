class Usuario {
  final int usuarioIdPk;
  final String correo;
  final String nombre;
  final String apellidos;
  final String numTelefono;
  final DateTime fechaNacimiento;
  final bool verificado;
  final DateTime fechaRegistroUsuario;
  final String rolUsuario;

  Usuario({
    required this.usuarioIdPk,
    required this.correo,
    required this.nombre,
    required this.apellidos,
    required this.numTelefono,
    required this.fechaNacimiento,
    required this.verificado,
    required this.fechaRegistroUsuario,
    required this.rolUsuario,
  });
}