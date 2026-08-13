import '../../domain/entities/organizacion.dart';
import '../../domain/entities/donacion.dart';
import '../../domain/entities/categoria_organizacion.dart';
import '../../domain/repositories/donacion_repository.dart';
import '../datasources/donacion_remote_datasource.dart';

class DonacionRepositoryImpl implements DonacionRepository {
  final DonacionRemoteDataSource dataSource;

  DonacionRepositoryImpl(this.dataSource);

  @override
  Future<List<Organizacion>> obtenerOrganizaciones(
    CategoriaOrganizacion categoria,
  ) async {
    return await dataSource.obtenerOrganizaciones(categoria);
  }

  @override
  Future<Donacion> crearDonacion({
    required int usuarioId,
    required int organizacionId,
    required double monto,
    /*required String numeroTarjeta,
    required String titularTarjeta,
    required String cvv,
    required String fechaVencimiento,*/
    required int tarjetaId,
    String metodoPago = 'tarjeta',
  }) async {
    return await dataSource.crearDonacion(
      usuarioId: usuarioId,
      organizacionId: organizacionId,
      monto: monto,
      /*numeroTarjeta: numeroTarjeta,
      titularTarjeta: titularTarjeta,
      cvv: cvv,
      fechaVencimiento: fechaVencimiento,*/
      tarjetaId: tarjetaId,
      metodoPago: metodoPago,
    );
  }
}
