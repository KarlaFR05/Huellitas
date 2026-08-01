import '../entities/grupo.dart';
import '../repositories/foro_repository.dart';

class UnirseAGrupo {
  final ForoRepository repository;
  const UnirseAGrupo(this.repository);
  Future<Grupo> call(int grupoId) => repository.unirseAGrupo(grupoId);
}