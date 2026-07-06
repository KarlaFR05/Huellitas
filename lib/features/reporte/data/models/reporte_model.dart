import '../../domain/entities/reporte.dart';

class ReporteModel extends Reporte {
  ReporteModel({
    super.id,
    required super.tipoAnimalId,
    required super.tipoReporteId,
    required super.urgenciaId,
    required super.tamano,
    required super.descripcion,
    required super.ubicacion,
    required super.usuarioId,
    required super.raza,
    required super.evidencia,
    required super.latitud,
    required super.longitud,
  });

  factory ReporteModel.fromEntity(Reporte reporte) {
    return ReporteModel(
      id: reporte.id,
      tipoAnimalId: reporte.tipoAnimalId,
      tipoReporteId: reporte.tipoReporteId,
      urgenciaId: reporte.urgenciaId,
      tamano: reporte.tamano,
      descripcion: reporte.descripcion,
      ubicacion: reporte.ubicacion,
      usuarioId: reporte.usuarioId,
      raza: reporte.raza,
      evidencia: reporte.evidencia,
      latitud: reporte.latitud,
      longitud: reporte.longitud,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id !=null)'id':id,
      'tipo_animal': tipoAnimalId,
      'raza_id': raza,
      'tipo_reporte': tipoReporteId,
      'urgencia_id': urgenciaId,
      'tamano': tamano,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'evidencia': evidencia,
      'usuario_id_fk': usuarioId,
      'latitud': latitud,
      'longitud': longitud,
    };
  }

  factory ReporteModel.fromJson(Map<String, dynamic> json) {
    return ReporteModel(
      id: json['id'],
      tipoAnimalId: json['tipo_animal'] ?? 0,
      tipoReporteId: json['tipo_reporte'] ?? 0,
      urgenciaId: json['urgencia_id'] ?? 0,
      tamano: json['tamano'] ?? '',
      descripcion: json['descripcion'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      usuarioId: json['usuario_id_fk'] ?? 0,
      raza: json['raza_id'] ?? '',
      evidencia: json['evidencia'] ?? '',
      latitud: (json['latitud'] ?? 0).toDouble(),
      longitud: (json['longitud'] ?? 0).toDouble(),
    );
  }
}
