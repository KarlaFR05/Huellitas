import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Usuario> call({
    required String correo,
    required String password,
    required String nombre,
    required String apellidos,
    required String nombreUsuario,
    required String numTelefono,
    required DateTime fechaNacimiento,
    String? calle,
    String? colonia,
    String? cp,
    String? ciudad,
    Map<String, dynamic>? organizacion, 
  }) async {
    final usuario = Usuario(
      usuarioIdPk: 0,
      correo: correo,
      nombreUsuario: nombreUsuario,
      nombre: nombre,
      apellidos: apellidos,
      numTelefono: numTelefono,
      fechaNacimiento: fechaNacimiento,
      verificado: false,
      fechaRegistroUsuario: DateTime.now(),
      rolUsuario: organizacion != null ? 'organizacion' : 'usuario', 
    );

    return await repository.register(
      usuario,
      password,
      organizacion: organizacion, 
    );
  }
}