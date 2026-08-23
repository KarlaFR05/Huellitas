import 'package:dio/dio.dart';
import '../../domain/entities/donacion.dart';

abstract class HistorialRemoteDataSource {
  Future<List<Donacion>> obtenerDonacionesUsuario();
}

class HistorialRemoteDataSourceImpl implements HistorialRemoteDataSource {
  final Dio dio;

  HistorialRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Donacion>> obtenerDonacionesUsuario() async {
    final response = await dio.get('/donaciones/usuario/mis-donaciones');
    final List<dynamic> data = response.data;
    return data.map((json) => _donacionFromJson(json)).toList();
  }

  Donacion _donacionFromJson(Map<String, dynamic> json) {
    return Donacion(
      id: json['id'] ?? 0,
      usuarioId: json['usuario_id'] ?? json['usuarioId'] ?? json['usuario_id_pk'] ?? 0,
      organizacionId: json['organizacion_id'] ?? json['organizacionId'] ?? 0,
      monto: json['monto'] is num
          ? (json['monto'] as num).toDouble()
          : double.tryParse(json['monto']?.toString() ?? '') ?? 0.0,
      tarjetaId: json['tarjeta_id'] ?? json['tarjetaId'] ?? 0,
      metodoPago: json['metodo_pago'] ?? json['metodoPago'] ?? 'tarjeta',
      fechaDonacion:
          DateTime.tryParse(json['fecha_donacion']?.toString() ?? '') ??
              DateTime.now(),
      estado: json['estado'] ?? 'completada',
    );
  }
}

class HistorialRemoteDataSourceMock implements HistorialRemoteDataSource {
  @override
  Future<List<Donacion>> obtenerDonacionesUsuario() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final ahora = DateTime.now();

    return [
      Donacion(
        id: 1,
        usuarioId: 1,
        organizacionId: 1,
        monto: 150,
        tarjetaId: 1,
        metodoPago: 'tarjeta',
        fechaDonacion: ahora.subtract(const Duration(days: 2)),
        estado: 'completada',
      ),
      Donacion(
        id: 2,
        usuarioId: 1,
        organizacionId: 2,
        monto: 75.5,
        tarjetaId: 1,
        metodoPago: 'tarjeta',
        fechaDonacion: ahora.subtract(const Duration(days: 6)),
        estado: 'completada',
      ),
      Donacion(
        id: 3,
        usuarioId: 1,
        organizacionId: 3,
        monto: 300,
        tarjetaId: 2,
        metodoPago: 'tarjeta',
        fechaDonacion: ahora.subtract(const Duration(days: 12)),
        estado: 'completada',
      ),
      Donacion(
        id: 4,
        usuarioId: 1,
        organizacionId: 4,
        monto: 20,
        tarjetaId: 2,
        metodoPago: 'tarjeta',
        fechaDonacion: ahora.subtract(const Duration(days: 20)),
        estado: 'completada',
      ),
      Donacion(
        id: 5,
        usuarioId: 1,
        organizacionId: 5,
        monto: 500,
        tarjetaId: 1,
        metodoPago: 'tarjeta',
        fechaDonacion: ahora.subtract(const Duration(days: 35)),
        estado: 'completada',
      ),
    ];
  }
}
