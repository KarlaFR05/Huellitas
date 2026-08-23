import '../../domain/entities/adopcion.dart';
import '../../domain/repositories/crear_adopcion_solicitud.dart';

abstract class AdopcionesRepository {
  Future<List<Adopcion>> obtenerAdopciones();

  Future<Adopcion> crearAdopcion(
    CrearAdopcionSolicitud solicitud,
  );

  Future<Adopcion> actualizarAdopcion(
    CrearAdopcionSolicitud solicitud,
  );

  Future<void> eliminarAdopcion(
    int adopcionId,
  );
}

/// Almacenamiento temporal para el módulo mientras se conecta su API.
class AdopcionesRepositoryMemoria implements AdopcionesRepository {
  final List<Adopcion> _adopciones = [];
  int _siguienteId = 1;

  @override
  Future<List<Adopcion>> obtenerAdopciones() async =>
      List.unmodifiable(_adopciones.reversed);

  @override
  Future<Adopcion> crearAdopcion(CrearAdopcionSolicitud solicitud) async {
    final adopcion = _desdeSolicitud(solicitud, id: _siguienteId++);
    _adopciones.add(adopcion);
    return adopcion;
  }

  @override
  Future<Adopcion> actualizarAdopcion(CrearAdopcionSolicitud solicitud) async {
    final id = solicitud.id;
    if (id == null) throw ArgumentError('La adopción a actualizar no tiene id.');
    final indice = _adopciones.indexWhere((adopcion) => adopcion.id == id);
    if (indice == -1) throw StateError('No se encontró la adopción.');
    final anterior = _adopciones[indice];
    final actualizada = _desdeSolicitud(solicitud,
        id: id, fecha: anterior.fecha, imagenUrl: anterior.imagenUrl);
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
    nombreUsuario: solicitud.nombreUsuario ?? 'Usuario',
    imagenPath: solicitud.imagenLocalPath,
    imagenUrl: solicitud.imagenExistenteUrl ?? imagenUrl,
    preguntas: solicitud.preguntas,
    fecha: fecha,
  );
}
