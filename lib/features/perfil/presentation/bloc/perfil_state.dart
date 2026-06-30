import '../../../auth/domain/entities/usuario.dart';

abstract class PerfilState {}

class PerfilInitial extends PerfilState {}

class PerfilLoading extends PerfilState {}

class PerfilLoaded extends PerfilState {
  final Usuario usuario;

  PerfilLoaded(this.usuario);
}

class PerfilError extends PerfilState {
  final String message;

  PerfilError(this.message);
}

class PerfilLogout extends PerfilState {}