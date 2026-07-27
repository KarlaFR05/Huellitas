import 'package:dio/dio.dart';
import '../../domain/entities/organizacion.dart';
import '../../domain/entities/donacion.dart';
import '../../domain/entities/categoria_organizacion.dart';

abstract class DonacionRemoteDataSource {
  Future<List<Organizacion>> obtenerOrganizaciones(CategoriaOrganizacion categoria);
  
  Future<Donacion> crearDonacion({
    required int usuarioId,
    required int organizacionId,
    required double monto,
    required String numeroTarjeta,
    required String titularTarjeta,
    required String cvv,
    required String fechaVencimiento,
  });
}

class DonacionRemoteDataSourceImpl implements DonacionRemoteDataSource {
  final Dio dio;

  DonacionRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Organizacion>> obtenerOrganizaciones(CategoriaOrganizacion categoria) async {
    try {
      final response = await dio.get(
        '/donaciones/organizaciones/categoria',
        queryParameters: {'categoria': categoria.name},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => _organizacionFromJson(json)).toList();
      } else {
        throw Exception('Error al obtener organizaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Donacion> crearDonacion({
    required int usuarioId,
    required int organizacionId,
    required double monto,
    required String numeroTarjeta,
    required String titularTarjeta,
    required String cvv,
    required String fechaVencimiento,
  }) async {
    try {
      final payload = {
        'usuarioId': usuarioId,
        'organizacionId': organizacionId,
        'monto': monto,
        'numeroTarjeta': numeroTarjeta,
        'titularTarjeta': titularTarjeta,
        'cvv': cvv,
        'fechaVencimiento': fechaVencimiento,
      };

      final response = await dio.post('/donaciones/', data: payload);

      if (response.statusCode == 201) {
        return _donacionFromJson(response.data);
      } else {
        final errorMessage = response.data['detail'] ?? 'Error desconocido';
        throw Exception('Error al crear donación: $errorMessage');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = e.response?.data['detail'] ?? e.message;
        throw Exception('Error del servidor: $errorMessage');
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // --- Métodos auxiliares de mapeo ---
  Organizacion _organizacionFromJson(Map<String, dynamic> json) {
    return Organizacion(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      logoUrl: json['logoUrl'],
      categoria: CategoriaOrganizacion.values.firstWhere(
        (e) => e.name == json['categoria'],
        orElse: () => CategoriaOrganizacion.sinFinesLucro,
      ),
      cuentaBancaria: json['cuentaBancaria'],
    );
  }

  Donacion _donacionFromJson(Map<String, dynamic> json) {
    return Donacion(
      id: json['id'],
      usuarioId: json['usuarioId'],
      organizacionId: json['organizacionId'],
      monto: (json['monto'] as num).toDouble(),
      numeroTarjeta: json['numeroTarjeta'],
      titularTarjeta: json['titularTarjeta'],
      cvv: json['cvv'],
      fechaVencimiento: json['fechaVencimiento'],
      fechaDonacion: DateTime.parse(json['fechaDonacion']),
      estado: json['estado'],
    );
  }
}