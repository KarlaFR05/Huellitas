import 'dart:io';

abstract class CompletarPerfilState {}

class CompletarPerfilInitial extends CompletarPerfilState {}

class CompletarPerfilLoading extends CompletarPerfilState {}

class CompletarPerfilLoaded extends CompletarPerfilState {
  final String? estado;
  final String? ciudad;
  final String? cp;
  final String? colonia;
  final String? calle;
  final File? frente;
  final File? reverso;
  final File? selfie;

  CompletarPerfilLoaded({
    this.estado,
    this.ciudad,
    this.cp,
    this.colonia,
    this.calle,
    this.frente,
    this.reverso,
    this.selfie,
  });

  CompletarPerfilLoaded copyWith({
    String? estado,
    String? ciudad,
    String? cp,
    String? colonia,
    String? calle,
    File? frente,
    File? reverso,
    File? selfie,
  }) {
    return CompletarPerfilLoaded(
      estado: estado ?? this.estado,
      ciudad: ciudad ?? this.ciudad,
      cp: cp ?? this.cp,
      colonia: colonia ?? this.colonia,
      calle: calle ?? this.calle,
      frente: frente ?? this.frente,
      reverso: reverso ?? this.reverso,
      selfie: selfie ?? this.selfie,
    );
  }

  bool get datosCompletos =>
      estado != null &&
      ciudad != null &&
      cp != null &&
      colonia != null &&
      calle != null &&
      frente != null &&
      reverso != null &&
      selfie != null;
}

class CompletarPerfilSuccess extends CompletarPerfilState {}

class CompletarPerfilError extends CompletarPerfilState {
  final String mensaje;
  CompletarPerfilError(this.mensaje);
}
