import '../../domain/entities/reporte.dart';

class ReporteModel extends Reporte {
  ReporteModel({
    required super.tipoAnimalId,
    required super.tipoReporteId,
    required super.urgenciaId,
    required super.tamano,
    required super.descripcion,
    required super.ubicacion,
    required super.usuarioId,
    required super.raza,
    required super.evidencia,
  });

  factory ReporteModel.fromEntity(Reporte reporte) {
    return ReporteModel(
      tipoAnimalId: reporte.tipoAnimalId,
      tipoReporteId: reporte.tipoReporteId,
      urgenciaId: reporte.urgenciaId,
      tamano: reporte.tamano,
      descripcion: reporte.descripcion,
      ubicacion: reporte.ubicacion,
      usuarioId: reporte.usuarioId,
      raza: reporte.raza,
      evidencia: reporte.evidencia,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo_animal': tipoAnimalId,
      'raza_id': raza,
      'tipo_reporte': tipoReporteId,
      'urgencia_id': urgenciaId,
      'tamano': tamano,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'evidencia': evidencia,
      'usuario_id_fk': usuarioId,
    };
  }
}
