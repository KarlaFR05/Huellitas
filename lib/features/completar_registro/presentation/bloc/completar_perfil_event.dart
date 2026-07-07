import 'dart:io';

abstract class CompletarPerfilEvent {}

class GuardarDireccionEvent extends CompletarPerfilEvent {
  final String estado;
  final String ciudad;
  final String cp;
  final String colonia;
  final String calle;

  GuardarDireccionEvent({
    required this.estado,
    required this.ciudad,
    required this.cp,
    required this.colonia,
    required this.calle,
  });
}

class SubirFrenteEvent extends CompletarPerfilEvent {
  final File imagen;
  SubirFrenteEvent(this.imagen);
}

class SubirReversoEvent extends CompletarPerfilEvent {
  final File imagen;
  SubirReversoEvent(this.imagen);
}

class SubirSelfieEvent extends CompletarPerfilEvent {
  final File imagen;
  SubirSelfieEvent(this.imagen);
}

class EnviarPerfilEvent extends CompletarPerfilEvent {}
