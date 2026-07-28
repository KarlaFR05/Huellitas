import '../entities/usuario_publico.dart';
import '../repositories/auth_repository.dart';

class ObtenerPerfilPublicoUseCase {
  final AuthRepository repository;

  ObtenerPerfilPublicoUseCase(this.repository);

  Future<UsuarioPublico> call(int usuarioId) {
    return repository.obtenerPerfilPublico(usuarioId);
  }
}
