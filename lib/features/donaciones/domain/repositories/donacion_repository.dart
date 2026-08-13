import '../entities/organizacion.dart';
import '../entities/donacion.dart';
import '../entities/categoria_organizacion.dart';

abstract class DonacionRepository {
  Future<List<Organizacion>> obtenerOrganizaciones(
    CategoriaOrganizacion categoria,
  );
  Future<Donacion> crearDonacion({
    required int usuarioId,
    required int organizacionId,
    required double monto,
    /*required String numeroTarjeta,
    required String titularTarjeta,
    required String cvv,
    required String fechaVencimiento,*/
    required int tarjetaId,
    String metodoPago,
  });
}
