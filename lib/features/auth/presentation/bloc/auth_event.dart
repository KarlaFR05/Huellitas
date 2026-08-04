import '../../domain/entities/usuario.dart';

abstract class AuthEvent {}

class VerificarSesionEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String identificador;
  final String password;

  LoginEvent({required this.identificador, required this.password});
}

class RegisterEvent extends AuthEvent {
  final String correo;
  final String nombreUsuario;
  final String password;
  final String nombre;
  final String apellidos;
  final String numTelefono;
  final DateTime fechaNacimiento;

  RegisterEvent({
    required this.correo,
    required this.nombreUsuario,
    required this.password,
    required this.nombre,
    required this.apellidos,
    required this.numTelefono,
    required this.fechaNacimiento,
  });
}

class LogoutEvent extends AuthEvent {}

class ActualizarUsuarioEvent extends AuthEvent {
  final Usuario usuario;
  ActualizarUsuarioEvent(this.usuario);
}
