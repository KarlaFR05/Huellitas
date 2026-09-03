/*import 'package:dio/dio.dart';
import '../../domain/entities/organizacion_foro.dart';

abstract class OrganizacionForoDataSource {
  Future<OrganizacionForo?> obtenerMiOrganizacion(int usuarioId);
  Future<List<OrganizacionForo>> obtenerOrganizacionesVerificadas();
}

class OrganizacionForoDataSourceImpl implements OrganizacionForoDataSource {
  final Dio dio;
  OrganizacionForoDataSourceImpl(this.dio);

  @override
  Future<OrganizacionForo?> obtenerMiOrganizacion(int usuarioId) async {
    final response = await dio.get('/organizaciones/mi-organizacion');
    if (response.data == null) return null;
    return _fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<OrganizacionForo>> obtenerOrganizacionesVerificadas() async {
    final response = await dio.get('/organizaciones/verificadas');
    final List<dynamic> data = response.data;
    return data.map((json) => _fromMap(json as Map<String, dynamic>)).toList();
  }

  OrganizacionForo _fromMap(Map<String, dynamic> json) {
    return OrganizacionForo(
      id: json['id'] ?? 0,
      usuarioId: json['usuario_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      fotoPortada: json['foto_portada'] ?? '',
      verificada: json['verificada'] ?? true,
      cantidadSeguidores: json['cantidad_seguidores'] ?? 0,
      esSeguidor: json['es_seguidor'] ?? false,
      tiposAnimales: json['tipos_animales'],
      telefonoEmergencia: json['telefono_emergencia'],
      correoInstitucional: json['correo_institucional'],
      registroLegal: json['registro_legal'],
      fechaFundacion: DateTime.tryParse(json['fecha_fundacion']?.toString() ?? ''),
      metaMensual: (json['meta_mensual'] as num?)?.toDouble() ?? 0,
      recaudadoMensual: (json['recaudado_mensual'] as num?)?.toDouble() ?? 0,
    );
  }
}

class OrganizacionForoDataSourceMock implements OrganizacionForoDataSource {
  @override
  Future<OrganizacionForo?> obtenerMiOrganizacion(int usuarioId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return OrganizacionForo(
      id: 1,
      usuarioId: usuarioId,
      nombre: 'Patitas Felices A.C.',
      descripcion:
          'Refugio dedicado al rescate y rehabilitación de perritos en situación de calle. ¡Gracias por apoyarnos!',
      verificada: true,
        cantidadSeguidores: 128,
        esSeguidor: false,
      tiposAnimales: 'Perros y gatos',
      telefonoEmergencia: '2221234567',
      correoInstitucional: 'contacto@patitasfelices.org',
      metaMensual: 20000,
      recaudadoMensual: 15850,
    );
  }

  @override
  Future<List<OrganizacionForo>> obtenerOrganizacionesVerificadas() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      OrganizacionForo(
        id: 1,
        usuarioId: 101,
        nombre: 'Patitas Felices A.C.',
        descripcion: 'Refugio y rehabilitación de perritos en situación de calle.',
        verificada: true,
        cantidadSeguidores: 180,
        esSeguidor: false,
        metaMensual: 20000,
        recaudadoMensual: 15850,
      ),
      OrganizacionForo(
        id: 2,
        usuarioId: 102,
        nombre: 'Mascotas Aesthe',
        descripcion: 'Comparte fotos de tu mascota en su mood más aesthetic ✨',
        verificada: true,
        cantidadSeguidores: 1528,
        esSeguidor: false,
        metaMensual: 20000,
        recaudadoMensual: 15850,
      ),
      OrganizacionForo(
        id: 3,
        usuarioId: 103,
        nombre: 'Rescate Animal MX',
        descripcion: 'Red nacional de rescate y adopción responsable.',
        verificada: true,
        cantidadSeguidores: 1328,
        esSeguidor: false,
        metaMensual: 50000,
        recaudadoMensual: 31200,
      ),
    ];
  }
}*/

import 'package:dio/dio.dart';
import '../models/organizacion_foro_model.dart';

abstract class OrganizacionForoRemoteDataSource {
  Future<OrganizacionForoModel?> obtenerMiOrganizacion();
  Future<List<OrganizacionForoModel>> obtenerOrganizacionesVerificadas();
  Future<dynamic> toggleSeguir(int organizacionId);
}

class OrganizacionForoRemoteDataSourceImpl
    implements OrganizacionForoRemoteDataSource {
  final Dio dio;

  OrganizacionForoRemoteDataSourceImpl(this.dio);

  @override
  Future<OrganizacionForoModel?> obtenerMiOrganizacion() async {
    final response = await dio.get('/organizaciones/mi-organizacion');
    if (response.data == null) return null;
    return OrganizacionForoModel.fromJson(response.data);
  }

  @override
  Future<List<OrganizacionForoModel>> obtenerOrganizacionesVerificadas() async {
    final response = await dio.get('/organizaciones/verificadas');
    final List<dynamic> data = response.data;
    return data
        .map(
          (json) =>
              OrganizacionForoModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<dynamic> toggleSeguir(int organizacionId) async {
    final response = await dio.post('/organizaciones/$organizacionId/seguir');
    return response.data;
  }
}
