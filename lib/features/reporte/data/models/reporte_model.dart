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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo_animal_id': tipoAnimalId,
      'tipo_reporte_id': tipoReporteId,
      'urgencia_id': urgenciaId,
      'tamano': tamano,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
    };
  }
}
