import 'dart:io';

abstract class CompletarPerfilState {}

class CompletarPerfilInitial extends CompletarPerfilState {}

class CompletarPerfilLoading extends CompletarPerfilState {}

class CompletarPerfilLoaded extends CompletarPerfilState {
  final File? frente;
  final File? reverso;
  final File? selfie;

  CompletarPerfilLoaded({
    this.frente,
    this.reverso,
    this.selfie,
  });
}

class CompletarPerfilSuccess extends CompletarPerfilState {}

class CompletarPerfilError extends CompletarPerfilState {
  final String mensaje;

  CompletarPerfilError(this.mensaje);
}