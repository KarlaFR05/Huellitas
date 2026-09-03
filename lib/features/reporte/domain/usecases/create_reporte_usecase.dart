import 'dart:io';
import '../entities/reporte.dart';
import '../entities/respuesta_crear_reporte.dart';
import '../repositories/reporte_repository.dart';

/// Incluye la evidencia subida para permitir reintentos sin volver a cargarla.
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

    // En los reintentos se reutiliza la evidencia ya subida.
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
