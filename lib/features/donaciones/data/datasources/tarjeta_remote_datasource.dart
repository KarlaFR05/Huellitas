import 'package:dio/dio.dart';
import '../../domain/entities/tarjeta.dart';

abstract class TarjetaRemoteDataSource {
  Future<List<Tarjeta>> obtenerTarjetasUsuario();

  Future<Tarjeta> guardarTarjeta({
    required String numeroTarjeta,
    required String titular,
    required String fechaVencimiento,
    required String cvv,
    bool esPredeterminada = false,
  });

  Future<void> eliminarTarjeta(int tarjetaId);

  Future<void> actualizarTarjeta({
    required int tarjetaId,
    String? titular,
    String? fechaVencimiento,
    bool? esPredeterminada,
  });

  Future<void> establecerPredeterminada(int tarjetaId);
}

class TarjetaRemoteDataSourceImpl implements TarjetaRemoteDataSource {
  final Dio dio;

  TarjetaRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Tarjeta>> obtenerTarjetasUsuario() async {
    try {
      // El backend extrae el usuario del token, no necesita el ID en la URL
      final response = await dio.get('/tarjetas/usuario/mis-tarjetas');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => _tarjetaFromJson(json)).toList();
      } else {
        throw Exception('Error al obtener tarjetas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexion: ${e.toString()}');
    }
  }

  @override
  Future<Tarjeta> guardarTarjeta({
    required String numeroTarjeta,
    required String titular,
    required String fechaVencimiento,
    required String cvv,
    bool esPredeterminada = false,
  }) async {
    try {
      final payload = {
        'numeroTarjeta': numeroTarjeta,
        'titular': titular.toUpperCase(),
        'fechaVencimiento': fechaVencimiento,
        'cvv': cvv,
        'tipo': Tarjeta.detectarTipo(
          numeroTarjeta,
        ), // Usamos tu función del domain
        'esPredeterminada': esPredeterminada,
      };

      final response = await dio.post('/tarjetas/', data: payload);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _tarjetaFromJson(response.data);
      } else {
        final errorMessage = response.data['detail'] ?? 'Error desconocido';
        throw Exception('Error al guardar tarjeta: $errorMessage');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = e.response?.data['detail'] ?? e.message;
        throw Exception('Error del servidor: $errorMessage');
      }
      throw Exception('Error de conexion: ${e.toString()}');
    }
  }

  @override
  Future<void> eliminarTarjeta(int tarjetaId) async {
    try {
      final response = await dio.delete('/tarjetas/$tarjetaId');
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Error al eliminar tarjeta');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = e.response?.data['detail'] ?? e.message;
        throw Exception('Error del servidor: $errorMessage');
      }
      throw Exception('Error de conexion: ${e.toString()}');
    }
  }

  @override
  Future<void> actualizarTarjeta({
    required int tarjetaId,
    String? titular,
    String? fechaVencimiento,
    bool? esPredeterminada,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (titular != null) payload['titular'] = titular.toUpperCase();
      if (fechaVencimiento != null)
        payload['fechaVencimiento'] = fechaVencimiento;
      if (esPredeterminada != null)
        payload['esPredeterminada'] = esPredeterminada;

      final response = await dio.put('/tarjetas/$tarjetaId', data: payload);

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar tarjeta');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = e.response?.data['detail'] ?? e.message;
        throw Exception('Error del servidor: $errorMessage');
      }
      throw Exception('Error de conexion: ${e.toString()}');
    }
  }

  @override
  Future<void> establecerPredeterminada(int tarjetaId) async {
    try {
      final response = await dio.post('/tarjetas/$tarjetaId/predeterminada');
      if (response.statusCode != 200) {
        throw Exception('Error al establecer tarjeta predeterminada');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = e.response?.data['detail'] ?? e.message;
        throw Exception('Error del servidor: $errorMessage');
      }
      throw Exception('Error de conexion: ${e.toString()}');
    }
  }

  // ==========================================
  // 3. MAPEO DE DATOS
  // ==========================================
  Tarjeta _tarjetaFromJson(Map<String, dynamic> json) {
    return Tarjeta(
      id: json['tarjetaId'] ?? json['tarjeta_id'] ?? 0,
      usuarioId: json['usuarioId'] ?? json['usuario_id'] ?? 0,
      numeroEnmascarado:
          json['numeroEnmascarado'] ?? json['numero_enmascarado'] ?? '',
      numeroCompleto: json['numeroCompleto'] ?? json['numero_completo'] ?? '',
      titular: json['titular'] ?? '',
      fechaVencimiento:
          json['fechaVencimiento'] ?? json['fecha_vencimiento'] ?? '',
      tipo: json['tipo'] ?? 'otro',
      esPredeterminada:
          json['esPredeterminada'] ?? json['es_predeterminada'] ?? false,
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'])
          : (json['fecha_creacion'] != null
                ? DateTime.parse(json['fecha_creacion'])
                : DateTime.now()),
    );
  }
}
/*import '../../domain/entities/tarjeta.dart';

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
}*/