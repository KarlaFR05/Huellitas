import '../../domain/entities/adopcion.dart';
import '../../domain/entities/mi_postulacion_adopcion.dart';
import '../../domain/repositories/crear_adopcion_solicitud.dart';
import '../datasources/adopciones_remote_datasource.dart';
import 'dart:io';

abstract class AdopcionesRepository {
  Future<List<Adopcion>> obtenerAdopciones();
  Future<Adopcion> obtenerAdopcion(int adopcionId);

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
    required String contacto,
    required Map<int, String> respuestas,
  });

  Future<List<Map<String, dynamic>>> obtenerPostulaciones(int adopcionId);

  Future<List<Map<String, dynamic>>> calcularRanking(int adopcionId);

  Future<MiPostulacionAdopcion> obtenerMiPostulacion(int adopcionId);
  Future<int> contarSolicitudes(int adopcionId);
  Future<void> aprobarPostulacion(
    int adopcionId,
    int postulacionId,
    String contactoResponsable,
  );
  Future<String> subirImagen(File imagen);
}

/// Implementación local conservada para pantallas o pruebas que todavía la
/// inyecten explícitamente. La aplicación usa [AdopcionesRepositoryImpl].
class AdopcionesRepositoryMemoria implements AdopcionesRepository {
  final List<Adopcion> _adopciones = [];
  var _siguienteId = 1;

  @override
  Future<List<Adopcion>> obtenerAdopciones() async =>
      List.unmodifiable(_adopciones.reversed);

  @override
  Future<Adopcion> obtenerAdopcion(int adopcionId) async =>
      _adopciones.firstWhere((adopcion) => adopcion.id == adopcionId);

  @override
  Future<Adopcion> crearAdopcion(CrearAdopcionSolicitud solicitud) async {
    final adopcion = _desdeSolicitud(solicitud, id: _siguienteId++);
    _adopciones.add(adopcion);
    return adopcion;
  }

  @override
  Future<Adopcion> actualizarAdopcion(CrearAdopcionSolicitud solicitud) async {
    final id = solicitud.id;
    final indice = id == null
        ? -1
        : _adopciones.indexWhere((adopcion) => adopcion.id == id);
    if (indice < 0) throw StateError('No se encontró la adopción.');
    final anterior = _adopciones[indice];
    final actualizada = _desdeSolicitud(
      solicitud,
      id: anterior.id,
      fecha: anterior.fecha,
      imagenUrl: anterior.imagenUrl,
    );
    _adopciones[indice] = actualizada;
    return actualizada;
  }

  @override
  Future<void> eliminarAdopcion(int adopcionId) async {
    _adopciones.removeWhere((adopcion) => adopcion.id == adopcionId);
  }

  Adopcion _desdeSolicitud(
    CrearAdopcionSolicitud solicitud, {
    required int id,
    DateTime? fecha,
    String? imagenUrl,
  }) => Adopcion(
    id: id,
    usuarioId: solicitud.usuarioId,
    nombre: solicitud.nombre.isEmpty ? 'Sin nombre' : solicitud.nombre,
    especie: solicitud.especie,
    edad: solicitud.edad,
    tamano: solicitud.tamano,
    ciudad: solicitud.ciudad,
    sexo: solicitud.sexo,
    vacunas: solicitud.vacunas,
    descripcion: solicitud.descripcion,
    estado: 'activa',
    nombreUsuario: solicitud.nombreUsuario ?? 'Usuario',
    imagenPath: solicitud.imagenLocalPath,
    imagenUrl: solicitud.imagenExistenteUrl ?? imagenUrl,
    preguntas: solicitud.preguntas,
    fecha: fecha,
  );

  @override
  Future<List<String>> sugerirPreguntas({
    required String especie,
    required String edad,
    required String tamano,
    String? descripcion,
  }) async => const [];

  @override
  Future<void> crearPostulacion({
    required int adopcionId,
    required int usuarioId,
    required String contacto,
    required Map<int, String> respuestas,
  }) async {}

  @override
  Future<List<Map<String, dynamic>>> obtenerPostulaciones(
    int adopcionId,
  ) async => const [];

  @override
  Future<List<Map<String, dynamic>>> calcularRanking(int adopcionId) async =>
      const [];

  @override
  Future<MiPostulacionAdopcion> obtenerMiPostulacion(int adopcionId) async =>
      const MiPostulacionAdopcion.noPostulado();

  @override
  Future<int> contarSolicitudes(int adopcionId) async => 0;

  @override
  Future<void> aprobarPostulacion(
    int adopcionId,
    int postulacionId,
    String contactoResponsable,
  ) async {}

  @override
  Future<String> subirImagen(File imagen) async => imagen.path;
}

class AdopcionesRepositoryImpl implements AdopcionesRepository {
  final AdopcionesRemoteDataSource dataSource;

  AdopcionesRepositoryImpl(this.dataSource);

  @override
  Future<String> subirImagen(File imagen) => dataSource.subirImagen(imagen);

  @override
  Future<void> aprobarPostulacion(
    int adopcionId,
    int postulacionId,
    String contactoResponsable,
  ) => dataSource.aprobarPostulacion(
    adopcionId,
    postulacionId,
    contactoResponsable,
  );

  @override
  Future<MiPostulacionAdopcion> obtenerMiPostulacion(int adopcionId) =>
      dataSource.obtenerMiPostulacion(adopcionId);

  @override
  Future<int> contarSolicitudes(int adopcionId) =>
      dataSource.contarSolicitudes(adopcionId);

  @override
  Future<List<Adopcion>> obtenerAdopciones() => dataSource.obtenerAdopciones();

  @override
  Future<Adopcion> obtenerAdopcion(int adopcionId) =>
      dataSource.obtenerAdopcion(adopcionId);

  @override
  Future<Adopcion> crearAdopcion(CrearAdopcionSolicitud solicitud) =>
      dataSource.crearAdopcion(solicitud);

  @override
  Future<Adopcion> actualizarAdopcion(CrearAdopcionSolicitud solicitud) {
    return dataSource.actualizarAdopcion(solicitud);
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
    required String contacto,
    required Map<int, String> respuestas,
  }) => dataSource.crearPostulacion(
    adopcionId: adopcionId,
    usuarioId: usuarioId,
    contacto: contacto,
    respuestas: respuestas,
  );

  @override
  Future<List<Map<String, dynamic>>> obtenerPostulaciones(int adopcionId) =>
      dataSource.obtenerPostulaciones(adopcionId);

  @override
  Future<List<Map<String, dynamic>>> calcularRanking(int adopcionId) =>
      dataSource.calcularRanking(adopcionId);
}
