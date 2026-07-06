import '../../domain/entities/insignia.dart';
import '../../domain/entities/categoria_insignia.dart';
import '../../domain/repositories/insignia_repository.dart';
import '../datasources/insignia_remote_datasource.dart';

class InsigniaRepositoryImpl implements InsigniaRepository {
  final InsigniaRemoteDataSource remoteDataSource;

  InsigniaRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<CategoriaInsignia, List<Insignia>>> obtenerTodasLasInsignias(int usuarioId) async {
    final insignias = await remoteDataSource.obtenerInsignias(usuarioId);
    
    return {
      CategoriaInsignia.rescate: insignias.where((i) => i.categoria == CategoriaInsignia.rescate).toList(),
      CategoriaInsignia.donacion: insignias.where((i) => i.categoria == CategoriaInsignia.donacion).toList(),
      CategoriaInsignia.reporte: insignias.where((i) => i.categoria == CategoriaInsignia.reporte).toList(),
    };
  }
}