import '../../domain/entities/reporte_estado.dart';
import '../../domain/entities/fase_reporte.dart';

class ReporteEstadoModel extends ReporteEstado {
  const ReporteEstadoModel({
    required super.reporteId,
    required super.faseActual,
    required super.nivelUrgencia,
    required super.tipoReporte,
    required super.descripcion,
    required super.ubicacion,
    required super.tipoAnimal,
    required super.raza,
    required super.tamano,
    required super.evidenciaUrl,
    required super.historialFases,
  });

  factory ReporteEstadoModel.fromJson(Map<String, dynamic> json) {
    return ReporteEstadoModel(
      reporteId: json['reporteId'] ?? 0,
      faseActual: FaseReporte.fromId(json['faseActual'] ?? 1),
      nivelUrgencia: json['nivelUrgencia'] ?? '',
      tipoReporte: json['tipoReporte'] ?? '',
      descripcion: json['descripcion'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      tipoAnimal: json['tipoAnimal'] ?? '',
      raza: json['raza'] ?? '',
      tamano: json['tamano'] ?? '',
      evidenciaUrl: json['evidenciaUrl'] ?? '',
      historialFases: List<String>.from(json['historialFases'] ?? []),
    );
  }
}