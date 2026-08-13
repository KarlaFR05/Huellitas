import '../../domain/entities/tarjeta.dart';
import '../../domain/repositories/tarjeta_repository.dart';
import '../datasources/tarjeta_remote_datasource.dart';

class TarjetaRepositoryImpl implements TarjetaRepository {
  final TarjetaRemoteDataSource dataSource;

  TarjetaRepositoryImpl(this.dataSource);

  @override
  Future<List<Tarjeta>> obtenerTarjetasUsuario() async {
    return await dataSource.obtenerTarjetasUsuario();
  }

  @override
  Future<Tarjeta> guardarTarjeta({
    required String numeroTarjeta,
    required String titular,
    required String fechaVencimiento,
    required String cvv,
    bool esPredeterminada = false,
  }) async {
    return await dataSource.guardarTarjeta(
      numeroTarjeta: numeroTarjeta,
      titular: titular,
      fechaVencimiento: fechaVencimiento,
      cvv: cvv,
      esPredeterminada: esPredeterminada,
    );
  }

  @override
  Future<void> eliminarTarjeta(int tarjetaId) async {
    await dataSource.eliminarTarjeta(tarjetaId);
  }

  @override
  Future<void> actualizarTarjeta({
    required int tarjetaId,
    String? titular,
    String? fechaVencimiento,
    bool? esPredeterminada,
  }) async {
    await dataSource.actualizarTarjeta(
      tarjetaId: tarjetaId,
      titular: titular,
      fechaVencimiento: fechaVencimiento,
      esPredeterminada: esPredeterminada,
    );
  }

  @override
  Future<void> establecerPredeterminada(int tarjetaId) async {
    await dataSource.establecerPredeterminada(tarjetaId);
  }
}

/*import '../../domain/entities/tarjeta.dart';
import '../../domain/repositories/tarjeta_repository.dart';
import '../datasources/tarjeta_remote_datasource.dart';

class TarjetaRepositoryImpl implements TarjetaRepository {
  final TarjetaRemoteDataSource dataSource;

  TarjetaRepositoryImpl(this.dataSource);

  @override
  Future<List<Tarjeta>> obtenerTarjetasUsuario(/*int usuarioId*/) async {
    return await dataSource.obtenerTarjetas(/*usuarioId*/);
  }

  @override
  Future<Tarjeta> guardarTarjeta({
    required int usuarioId,
    required String numeroTarjeta,
    required String titular,
    required String fechaVencimiento,
    required String cvv,
    bool esPredeterminada = false,
  }) async {
    return await dataSource.guardarTarjeta(
      usuarioId: usuarioId,
      numeroTarjeta: numeroTarjeta,
      titular: titular,
      fechaVencimiento: fechaVencimiento,
      cvv: cvv,
      esPredeterminada: esPredeterminada,
    );
  }

  @override
  Future<void> eliminarTarjeta(int tarjetaId) async {
    await dataSource.eliminarTarjeta(tarjetaId);
  }

  @override
  Future<void> actualizarTarjeta({
    required int tarjetaId,
    String? numeroTarjeta,
    String? titular,
    String? fechaVencimiento,
    String? cvv,
    bool? esPredeterminada,
  }) async {
    await dataSource.actualizarTarjeta(
      tarjetaId: tarjetaId,
      numeroTarjeta: numeroTarjeta,
      titular: titular,
      fechaVencimiento: fechaVencimiento,
      cvv: cvv,
      esPredeterminada: esPredeterminada,
    );
  }

  @override
  Future<void> establecerPredeterminada(int tarjetaId) async {
    await dataSource.actualizarTarjeta(
      tarjetaId: tarjetaId,
      esPredeterminada: true,
    );
  }
}*/
