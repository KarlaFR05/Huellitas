import '../../domain/entities/reporte_estado.dart';
import '../../domain/entities/fase_reporte.dart';
import '../../domain/entities/tipo_urgencia.dart';
import '../../domain/entities/tipo_animal.dart';
import '../../domain/entities/tipo_reporte.dart';
import '../../domain/entities/historial_fase_item.dart';

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
    required super.usuarioRescateId,
    required super.usuarioRescateNombre,
    required super.historialFases,
  });

  factory ReporteEstadoModel.fromJson(Map<String, dynamic> json) {
    return ReporteEstadoModel(
      reporteId: json['reporteId'] ?? 0,
      faseActual: FaseReporte.fromId(json['faseActual'] ?? 1),
      nivelUrgencia: TipoUrgencia.fromId(json['nivelUrgencia']),
      tipoReporte: TipoReporte.fromId(json['tipoReporte']),
      descripcion: json['descripcion'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      tipoAnimal: TipoAnimal.fromId(json['tipoAnimal']),
      raza: json['raza'] ?? '',
      tamano: json['tamano'] ?? '',
      evidenciaUrl: json['evidenciaUrl'] ?? '',
      usuarioRescateId: json['usuarioRescateId'],
      usuarioRescateNombre: json['usuarioRescateNombre'],
      historialFases: (json['historialFases'] as List<dynamic>? ?? [])
          .map((e) => HistorialFaseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
