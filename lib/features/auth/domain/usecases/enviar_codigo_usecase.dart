import '../repositories/auth_repository.dart';

class EnviarCodigoUseCase {
  final AuthRepository repository;
  EnviarCodigoUseCase(this.repository);

  Future<void> call(String correo) => repository.enviarCodigo(correo);
}
