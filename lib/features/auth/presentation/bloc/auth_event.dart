abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String correo;
  final String password;

  LoginEvent({
    required this.correo,
    required this.password,
  });
}

class RegisterEvent extends AuthEvent {
  final String correo;
  final String password;
  final String nombre;
  final String apellidos;
  final String numTelefono;
  final DateTime fechaNacimiento;

  RegisterEvent({
    required this.correo,
    required this.password,
    required this.nombre,
    required this.apellidos,
    required this.numTelefono,
    required this.fechaNacimiento,
  });
}