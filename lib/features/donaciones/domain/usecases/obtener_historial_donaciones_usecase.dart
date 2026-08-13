import '../../../donaciones/domain/entities/donacion.dart';
import '../repositories/historial_repository.dart';

class ObtenerHistorialDonacionesUseCase {
  final HistorialRepository repository;

  ObtenerHistorialDonacionesUseCase(this.repository);

  Future<List<Donacion>> call() async {
    return await repository.obtenerDonacionesUsuario();
  }
}