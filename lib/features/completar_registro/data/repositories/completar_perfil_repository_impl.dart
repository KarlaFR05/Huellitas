import 'dart:io';
import '../../domain/repositories/completar_perfil_repository.dart';
import '../datasources/completar_perfil_remote_datasource.dart';

class CompletarPerfilRepositoryImpl implements CompletarPerfilRepository {
  final CompletarPerfilRemoteDataSourceImpl remoteDataSource;
  CompletarPerfilRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> completarPerfil({
    required String calle,
    required String colonia,
    required String cp,
    required String ciudad,
    required String estado,
    required File frontal,
    required File trasera,
    required File selfie,
  }) {
    return remoteDataSource.completarPerfil(
      calle: calle,
      colonia: colonia,
      cp: cp,
      ciudad: ciudad,
      estado: estado,
      frontal: frontal,
      trasera: trasera,
      selfie: selfie,
    );
  }
}
