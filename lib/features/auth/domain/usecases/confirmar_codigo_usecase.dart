import '../repositories/auth_repository.dart';

class ConfirmarCodigoUseCase {
  final AuthRepository repository;
  ConfirmarCodigoUseCase(this.repository);

  Future<void> call(String correo, String codigo) =>
      repository.confirmarCodigo(correo, codigo);
}
