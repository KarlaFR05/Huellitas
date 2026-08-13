import 'package:dio/dio.dart';
import '../../domain/entities/organizacion.dart';
import '../../domain/entities/donacion.dart';
import '../../domain/entities/categoria_organizacion.dart';

abstract class DonacionRemoteDataSource {
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

class DonacionRemoteDataSourceImpl implements DonacionRemoteDataSource {
  final Dio dio;

  DonacionRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Organizacion>> obtenerOrganizaciones(
    CategoriaOrganizacion categoria,
  ) async {
    try {
      final response = await dio.get(
        '/donaciones/organizaciones/categoria',
        queryParameters: {'categoria': categoria.name},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => _organizacionFromJson(json)).toList();
      } else {
        throw Exception(
          'Error al obtener organizaciones: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexion: ${e.toString()}');
    }
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
    try {
      final payload = {
        'usuarioId': usuarioId,
        'organizacionId': organizacionId,
        'monto': monto,
        /*'numeroTarjeta': numeroTarjeta,
        'titularTarjeta': titularTarjeta,
        'cvv': cvv,
        'fechaVencimiento': fechaVencimiento,*/
        'tarjetaId': tarjetaId,
        'metodoPago': metodoPago,
      };

      print('Enviando donacion:');
      print('   - Usuario ID: $usuarioId');
      print('   - Organizacion ID: $organizacionId');
      print('   - Monto: \$$monto');
      print('   - Payload completo: $payload');

      final response = await dio.post('/donaciones/', data: payload);

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Donacion creada exitosamente');

        final data = response.data;
        if (data is List && data.isNotEmpty) {
          return _donacionFromJson(data[0]);
        } else if (data is Map<String, dynamic>) {
          return _donacionFromJson(data);
        } else {
          throw Exception('Formato de respuesta inesperado');
        }
      } else {
        final errorMessage = response.data['detail'] ?? 'Error desconocido';
        print('Error del servidor: $errorMessage');
        throw Exception('Error al crear donacion: $errorMessage');
      }
    } catch (e) {
      print('Excepcion capturada: $e');
      if (e is DioException && e.response != null) {
        print('DioException - Status: ${e.response?.statusCode}');
        print('Response error: ${e.response?.data}');
        final errorMessage = e.response?.data['detail'] ?? e.message;
        throw Exception('Error del servidor: $errorMessage');
      }
      throw Exception('Error de conexion: ${e.toString()}');
    }
  }

  Organizacion _organizacionFromJson(Map<String, dynamic> json) {
    return Organizacion(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'] ?? '',
      logoUrl: json['logoUrl'] ?? json['logo_url'] ?? '',
      categoria: CategoriaOrganizacion.values.firstWhere(
        (e) => e.name == json['categoria'],
        orElse: () => CategoriaOrganizacion.sinFinesLucro,
      ),
      cuentaBancaria: json['cuentaBancaria'] ?? json['cuenta_bancaria'] ?? '',
    );
  }

  Donacion _donacionFromJson(Map<String, dynamic> json) {
    print('Mapeando donacion con ID: ${json['id']}');
    return Donacion(
      id: json['id'] ?? 0,
      usuarioId: json['usuario_id'] ?? json['usuarioId'] ?? 0,
      organizacionId: json['organizacion_id'] ?? json['organizacionId'] ?? 0,
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      /*numeroTarjeta: json['numero_tarjeta'] ?? json['numeroTarjeta'] ?? '',
      titularTarjeta: json['titular_tarjeta'] ?? json['titularTarjeta'] ?? '',
      cvv: json['cvv'] ?? '',
      fechaVencimiento: json['fecha_vencimiento'] ?? json['fechaVencimiento'] ?? '',*/
      tarjetaId: json['tarjeta_id'] ?? json['tarjetaId'] ?? 0,
      metodoPago: json['metodo_pago'] ?? json['metodoPago'] ?? 'tarjeta',
      fechaDonacion: json['fecha_donacion'] != null
          ? DateTime.parse(json['fecha_donacion'])
          : (json['fechaDonacion'] != null
                ? DateTime.parse(json['fechaDonacion'])
                : DateTime.now()),
      estado: json['estado'] ?? 'pendiente',
    );
  }
}
