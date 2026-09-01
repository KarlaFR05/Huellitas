import '../../domain/entities/adopcion.dart';
import '../../domain/repositories/crear_adopcion_solicitud.dart';
import '../datasources/adopciones_remote_datasource.dart';
import 'dart:io';

abstract class AdopcionesRepository {
  Future<List<Adopcion>> obtenerAdopciones();

  Future<Adopcion> crearAdopcion(CrearAdopcionSolicitud solicitud);

  Future<Adopcion> actualizarAdopcion(CrearAdopcionSolicitud solicitud);

  Future<void> eliminarAdopcion(int adopcionId);

  Future<List<String>> sugerirPreguntas({
    required String especie,
    required String edad,
    required String tamano,
    String? descripcion,
  });

  Future<void> crearPostulacion({
    required int adopcionId,
    required int usuarioId,
    required Map<int, String> respuestas,
  });

  Future<List<Map<String, dynamic>>> obtenerPostulaciones(int adopcionId);

  Future<List<Map<String, dynamic>>> calcularRanking(int adopcionId);

  Future<bool> yaPostulado(int adopcionId);
  Future<int> contarSolicitudes(int adopcionId);
  Future<void> aprobarPostulacion(int adopcionId, int postulacionId);
  Future<String> subirImagen(File imagen);
}

class AdopcionesRepositoryImpl implements AdopcionesRepository {
  final AdopcionesRemoteDataSource dataSource;

  AdopcionesRepositoryImpl(this.dataSource);

  @override
  Future<String> subirImagen(File imagen) => dataSource.subirImagen(imagen);

  @override
  Future<void> aprobarPostulacion(int adopcionId, int postulacionId) =>
      dataSource.aprobarPostulacion(adopcionId, postulacionId);

  @override
  Future<bool> yaPostulado(int adopcionId) =>
      dataSource.yaPostulado(adopcionId);

  @override
  Future<int> contarSolicitudes(int adopcionId) =>
      dataSource.contarSolicitudes(adopcionId);

  @override
  Future<List<Adopcion>> obtenerAdopciones() => dataSource.obtenerAdopciones();

  @override
  Future<Adopcion> crearAdopcion(CrearAdopcionSolicitud solicitud) =>
      dataSource.crearAdopcion(solicitud);

  @override
  Future<Adopcion> actualizarAdopcion(CrearAdopcionSolicitud solicitud) {
    throw UnimplementedError(
      'Falta el endpoint PUT /adopciones/{id} en el backend todavía.',
    );
  }

  @override
  Future<void> eliminarAdopcion(int adopcionId) =>
      dataSource.eliminarAdopcion(adopcionId);

  @override
  Future<List<String>> sugerirPreguntas({
    required String especie,
    required String edad,
    required String tamano,
    String? descripcion,
  }) => dataSource.sugerirPreguntas(
    especie: especie,
    edad: edad,
    tamano: tamano,
    descripcion: descripcion,
  );

  @override
  Future<void> crearPostulacion({
    required int adopcionId,
    required int usuarioId,
    required Map<int, String> respuestas,
  }) => dataSource.crearPostulacion(
    adopcionId: adopcionId,
    usuarioId: usuarioId,
    respuestas: respuestas,
  );

  @override
  Future<List<Map<String, dynamic>>> obtenerPostulaciones(int adopcionId) =>
      dataSource.obtenerPostulaciones(adopcionId);

  @override
  Future<List<Map<String, dynamic>>> calcularRanking(int adopcionId) =>
      dataSource.calcularRanking(adopcionId);
}
