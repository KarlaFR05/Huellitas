abstract class AuthEvent {}

class LoginPressed extends AuthEvent {
  final String email;
  final String password;

  LoginPressed({
    required this.email,
    required this.password,
  });
}

class RegisterPressed extends AuthEvent {
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;

  RegisterPressed({
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
  });
}