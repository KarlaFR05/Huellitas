import '../../domain/entities/donacion.dart';
import '../../domain/repositories/historial_repository.dart';
import '../datasources/historial_remote_datasource.dart';

class HistorialRepositoryImpl implements HistorialRepository {
  final HistorialRemoteDataSource dataSource;

  HistorialRepositoryImpl(this.dataSource);

  @override
  Future<List<Donacion>> obtenerDonacionesUsuario() async {
    return await dataSource.obtenerDonacionesUsuario();
  }
}