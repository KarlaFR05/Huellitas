import 'dart:io';
import '../entities/reporte.dart';
import '../entities/respuesta_crear_reporte.dart';
import '../repositories/reporte_repository.dart';

/// Resultado del caso de uso: incluye el reporte final (ya con la
/// evidencia subida) junto con la respuesta del backend. El reporte
/// final es necesario para poder reintentar con forzarCreacion=true
/// sin volver a subir la imagen.
class CrearReporteResult {
  final Reporte reporteConEvidencia;
  final RespuestaCrearReporte respuesta;

  CrearReporteResult({
    required this.reporteConEvidencia,
    required this.respuesta,
  });
}

class CreateReporteUseCase {
  final ReporteRepository repository;

  CreateReporteUseCase(this.repository);

  Future<CrearReporteResult> call(
    Reporte reporte,
    List<File> imagenes, {
    bool forzarCreacion = false,
  }) async {
    String evidenciaUrl = reporte.evidencia;

    // Solo subimos evidencia si aún no la tiene (evita re-subir la imagen
    // cuando el usuario reintenta con forzarCreacion=true).
    if (imagenes.isNotEmpty && evidenciaUrl.isEmpty) {
      evidenciaUrl = await repository.subirEvidencia(imagenes.first);
    }

    final reporteConEvidencia = Reporte(
      id: reporte.id,
      tipoAnimalId: reporte.tipoAnimalId,
      tipoReporteId: reporte.tipoReporteId,
      urgenciaId: reporte.urgenciaId,
      tamano: reporte.tamano,
      descripcion: reporte.descripcion,
      ubicacion: reporte.ubicacion,
      usuarioId: reporte.usuarioId,
      raza: reporte.raza,
      evidencia: evidenciaUrl,
      latitud: reporte.latitud,
      longitud: reporte.longitud,
    );

    final respuesta = await repository.crearReporte(
      reporteConEvidencia,
      forzarCreacion: forzarCreacion,
    );

    return CrearReporteResult(
      reporteConEvidencia: reporteConEvidencia,
      respuesta: respuesta,
    );
  }
}
