/*import '../../domain/entities/organizacion_foro.dart';
import '../../domain/repositories/organizacion_foro_repository.dart';
import '../datasources/organizacion_foro_datasource.dart';

class OrganizacionForoRepositoryImpl implements OrganizacionForoRepository {
  final OrganizacionForoDataSource dataSource;
  OrganizacionForoRepositoryImpl(this.dataSource);

  @override
  Future<OrganizacionForo?> obtenerMiOrganizacion(int usuarioId) =>
      dataSource.obtenerMiOrganizacion(usuarioId);

  @override
  Future<List<OrganizacionForo>> obtenerOrganizacionesVerificadas() =>
      dataSource.obtenerOrganizacionesVerificadas();
}*/
import '../../domain/entities/organizacion_foro.dart';
import '../../domain/repositories/organizacion_foro_repository.dart';
import '../datasources/organizacion_foro_datasource.dart';

class OrganizacionForoRepositoryImpl implements OrganizacionForoRepository {
  final OrganizacionForoRemoteDataSource remoteDataSource;

  OrganizacionForoRepositoryImpl(this.remoteDataSource);

  @override
  Future<OrganizacionForo?> obtenerMiOrganizacion() async {
    return await remoteDataSource.obtenerMiOrganizacion();
  }

  @override
  Future<List<OrganizacionForo>> obtenerOrganizacionesVerificadas() async {
    return await remoteDataSource.obtenerOrganizacionesVerificadas();
  }

  @override
  Future<ResultadoSeguimientoOrganizacion> toggleSeguir(
    int organizacionId,
  ) async {
    final respuesta = await remoteDataSource.toggleSeguir(organizacionId);
    if (respuesta is! Map) {
      return const ResultadoSeguimientoOrganizacion();
    }

    final siguiendo =
        _parseBool(
          respuesta['siguiendo'] ??
              respuesta['es_seguidor'] ??
              respuesta['seguido'] ??
              respuesta['following'],
        ) ??
        _parseMensajeSeguimiento(
          respuesta['mensaje'] ?? respuesta['message'] ?? respuesta['detail'],
        );
    final cantidadSeguidores = _parseInt(
      respuesta['cantidad_seguidores'] ?? respuesta['cantidadSeguidores'],
    );

    return ResultadoSeguimientoOrganizacion(
      siguiendo: siguiendo,
      cantidadSeguidores: cantidadSeguidores,
    );
  }

  bool? _parseBool(dynamic valor) {
    if (valor is bool) return valor;
    if (valor is num) return valor != 0;
    if (valor is String) {
      final normalizado = valor.toLowerCase();
      if (normalizado == 'true' || normalizado == '1') return true;
      if (normalizado == 'false' || normalizado == '0') return false;
    }
    return null;
  }

  int? _parseInt(dynamic valor) {
    if (valor is num) return valor.toInt();
    return int.tryParse(valor?.toString() ?? '');
  }

  bool? _parseMensajeSeguimiento(dynamic valor) {
    if (valor is! String) return null;

    final mensaje = valor.toLowerCase();
    if (mensaje.contains('dejaste de seguir') ||
        mensaje.contains('dejado de seguir') ||
        mensaje.contains('ya no sigues') ||
        mensaje.contains('unfollow')) {
      return false;
    }
    if (mensaje.contains('ahora sigues') ||
        mensaje.contains('comenzaste a seguir') ||
        mensaje.contains('seguida exitosamente') ||
        mensaje.contains('followed')) {
      return true;
    }
    return null;
  }
}
