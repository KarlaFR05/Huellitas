// lib/domain/usecases/actualizar_grupo.dart
import '../entities/grupo.dart';
import '../repositories/foro_repository.dart';

class ActualizarGrupo {
  final ForoRepository repository;
  const ActualizarGrupo(this.repository);
  Future<Grupo> call(
    int grupoId, {
    String? nombre,
    String? descripcion,
    PrivacidadGrupo? privacidad,
    String? fotoPerfilLocalPath,
    String? fotoPortadaLocalPath,
  }) => repository.actualizarGrupo(
    grupoId,
    nombre: nombre,
    descripcion: descripcion,
    privacidad: privacidad,
    fotoPerfilLocalPath: fotoPerfilLocalPath,
    fotoPortadaLocalPath: fotoPortadaLocalPath,
  );
}
