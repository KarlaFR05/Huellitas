import '../entities/token.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Token> call(String correo, String password) async {
    return await repository.login(correo, password);
  }
}