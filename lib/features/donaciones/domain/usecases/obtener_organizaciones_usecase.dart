import '../entities/organizacion.dart';
import '../repositories/donacion_repository.dart';
import '../entities/categoria_organizacion.dart';

class ObtenerOrganizacionesUseCase {
  final DonacionRepository repository;

  ObtenerOrganizacionesUseCase(this.repository);

  Future<List<Organizacion>> call(CategoriaOrganizacion categoria) async {
    return await repository.obtenerOrganizaciones(categoria);
  }
}