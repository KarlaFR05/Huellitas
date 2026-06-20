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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo_animal': tipoAnimalId, // ✅ sin _id al final
      'raza_id': raza, // ✅ temporal, ajusta según tu lógica
      'tipo_reporte': tipoReporteId, // ✅ sin _id al final
      'urgencia_id': urgenciaId,
      'tamano': tamano,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'evidencia': '', // ✅ temporal, ajusta cuando implementes imágenes
      'usuario_id_fk': usuarioId, // ✅ cambia el nombre
    };
  }
}
