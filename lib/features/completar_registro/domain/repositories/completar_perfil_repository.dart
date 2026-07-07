import 'dart:io';

abstract class CompletarPerfilRepository {
  Future<void> completarPerfil({
    required String calle,
    required String colonia,
    required String cp,
    required String ciudad,
    required String estado,
    required File frontal,
    required File trasera,
    required File selfie,
  });
}
