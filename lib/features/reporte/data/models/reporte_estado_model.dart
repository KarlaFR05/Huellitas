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
    super.comentarios,
  });

  factory ReporteEstadoModel.fromJson(Map<String, dynamic> json) {
    String _safeString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString();
    }

    int _safeInt(dynamic value, int defaultValue) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return ReporteEstadoModel(
      reporteId: _safeInt(json['reporteId'], 0),
      faseActual: FaseReporte.fromId(_safeInt(json['faseActual'], 1)),
      nivelUrgencia: TipoUrgencia.fromId(json['nivelUrgencia']),
      tipoReporte: TipoReporte.fromId(json['tipoReporte']),
      tipoAnimal: TipoAnimal.fromId(json['tipoAnimal']),
      descripcion: _safeString(json['descripcion']),
      ubicacion: _safeString(json['ubicacion']),
      raza: _safeString(json['raza']),
      tamano: _safeString(json['tamano']),
      evidenciaUrl: _safeString(json['evidenciaUrl']),
      usuarioRescateId: json['usuarioRescateId'],
      usuarioRescateNombre: json['usuarioRescateNombre'] != null
          ? _safeString(json['usuarioRescateNombre'])
          : null,
      historialFases: (json['historialFases'] as List<dynamic>? ?? [])
          .map((e) => HistorialFaseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      comentarios: json['comentarios'] == null
          ? null
          : _safeString(json['comentarios']),
    );
  }
}
