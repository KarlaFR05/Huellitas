import '../../domain/entities/tarjeta.dart';

abstract class TarjetaRemoteDataSource {
  Future<List<Tarjeta>> obtenerTarjetas(int usuarioId);
  Future<Tarjeta> guardarTarjeta({
    required int usuarioId,
    required String numeroTarjeta,
    required String titular,
    required String fechaVencimiento,
    required String cvv,
    bool esPredeterminada = false,
  });
  Future<void> eliminarTarjeta(int tarjetaId);
  Future<void> actualizarTarjeta({
    required int tarjetaId,
    String? numeroTarjeta,
    String? titular,
    String? fechaVencimiento,
    String? cvv,
    bool? esPredeterminada,
  });
}

class TarjetaRemoteDataSourceMock implements TarjetaRemoteDataSource {
  // Simulación en memoria
  final List<Tarjeta> _tarjetas = [];
  int _nextId = 1;

  @override
  Future<List<Tarjeta>> obtenerTarjetas(int usuarioId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _tarjetas.where((t) => t.usuarioId == usuarioId).toList();
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
    await Future.delayed(const Duration(milliseconds: 500));

    // Si es predeterminada, quitar el estado de las demás
    if (esPredeterminada) {
      for (var t in _tarjetas) {
        if (t.usuarioId == usuarioId) {
          _tarjetas[_tarjetas.indexOf(t)] = Tarjeta(
            id: t.id,
            usuarioId: t.usuarioId,
            numeroEnmascarado: t.numeroEnmascarado,
            numeroCompleto: t.numeroCompleto,
            titular: t.titular,
            fechaVencimiento: t.fechaVencimiento,
            tipo: t.tipo,
            esPredeterminada: false,
            fechaCreacion: t.fechaCreacion,
          );
        }
      }
    }

    final tarjeta = Tarjeta(
      id: _nextId++,
      usuarioId: usuarioId,
      numeroEnmascarado: Tarjeta.enmascararNumero(numeroTarjeta),
      numeroCompleto: numeroTarjeta,
      titular: titular.toUpperCase(),
      fechaVencimiento: fechaVencimiento,
      tipo: Tarjeta.detectarTipo(numeroTarjeta),
      esPredeterminada: esPredeterminada,
      fechaCreacion: DateTime.now(),
    );

    _tarjetas.add(tarjeta);
    return tarjeta;
  }

  @override
  Future<void> eliminarTarjeta(int tarjetaId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _tarjetas.removeWhere((t) => t.id == tarjetaId);
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
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _tarjetas.indexWhere((t) => t.id == tarjetaId);
    if (index == -1) throw Exception('Tarjeta no encontrada');

    final tarjetaActual = _tarjetas[index];

    // Si se establece como predeterminada, quitar de las demás
    if (esPredeterminada == true) {
      for (var i = 0; i < _tarjetas.length; i++) {
        if (_tarjetas[i].usuarioId == tarjetaActual.usuarioId) {
          _tarjetas[i] = Tarjeta(
            id: _tarjetas[i].id,
            usuarioId: _tarjetas[i].usuarioId,
            numeroEnmascarado: _tarjetas[i].numeroEnmascarado,
            numeroCompleto: _tarjetas[i].numeroCompleto,
            titular: _tarjetas[i].titular,
            fechaVencimiento: _tarjetas[i].fechaVencimiento,
            tipo: _tarjetas[i].tipo,
            esPredeterminada: false,
            fechaCreacion: _tarjetas[i].fechaCreacion,
          );
        }
      }
    }

    _tarjetas[index] = Tarjeta(
      id: tarjetaActual.id,
      usuarioId: tarjetaActual.usuarioId,
      numeroEnmascarado: numeroTarjeta != null
          ? Tarjeta.enmascararNumero(numeroTarjeta)
          : tarjetaActual.numeroEnmascarado,
      numeroCompleto: numeroTarjeta ?? tarjetaActual.numeroCompleto,
      titular: titular?.toUpperCase() ?? tarjetaActual.titular,
      fechaVencimiento: fechaVencimiento ?? tarjetaActual.fechaVencimiento,
      tipo: numeroTarjeta != null
          ? Tarjeta.detectarTipo(numeroTarjeta)
          : tarjetaActual.tipo,
      esPredeterminada: esPredeterminada ?? tarjetaActual.esPredeterminada,
      fechaCreacion: tarjetaActual.fechaCreacion,
    );
  }
}