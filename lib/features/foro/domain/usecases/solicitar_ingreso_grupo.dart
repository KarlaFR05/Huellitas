import '../entities/grupo.dart';
import '../repositories/foro_repository.dart';

class SolicitarIngresoGrupo {
  final ForoRepository repository;
  const SolicitarIngresoGrupo(this.repository);
  Future<Grupo> call(int grupoId) => repository.solicitarIngresoGrupo(grupoId);
}
