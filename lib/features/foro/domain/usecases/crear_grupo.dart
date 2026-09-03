import '../entities/grupo.dart';
import '../entities/solicitudes_foro.dart';
import '../repositories/foro_repository.dart';

class CrearGrupo {
  final ForoRepository repository;
  const CrearGrupo(this.repository);
  Future<Grupo> call(CrearGrupoSolicitud solicitud) =>
      repository.crearGrupo(solicitud);
}
