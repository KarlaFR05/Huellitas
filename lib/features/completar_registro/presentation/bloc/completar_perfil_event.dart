import 'dart:io';

abstract class CompletarPerfilEvent {}

class GuardarDireccionEvent extends CompletarPerfilEvent {
  final String estado;
  final String municipio;
  final String codigoPostal;
  final String colonia;
  final String calle;
  final String numeroExterior;
  final String? numeroInterior;
  final String? referencias;

  GuardarDireccionEvent({
    required this.estado,
    required this.municipio,
    required this.codigoPostal,
    required this.colonia,
    required this.calle,
    required this.numeroExterior,
    this.numeroInterior,
    this.referencias,
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