import 'dart:io';
import '../entities/reporte.dart';
import '../repositories/reporte_repository.dart';

class CreateReporteUseCase {
  final ReporteRepository repository;

  CreateReporteUseCase(this.repository);

  Future<void> call(Reporte reporte, List<File> imagenes) async {
    String evidenciaUrl = '';

    if (imagenes.isNotEmpty) {
      evidenciaUrl = await repository.subirEvidencia(imagenes.first);
    }
    final reporteConEvidencia = Reporte(
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
    return repository.crearReporte(reporteConEvidencia);
  }
}