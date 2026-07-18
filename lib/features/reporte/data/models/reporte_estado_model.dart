import '../../domain/entities/reporte_estado.dart';
import '../../domain/entities/fase_reporte.dart';
import '../../domain/entities/tipo_urgencia.dart';
import '../../domain/entities/tipo_animal.dart';
import '../../domain/entities/tipo_reporte.dart';

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
    super.comentarios,  
  });

  factory ReporteEstadoModel.fromJson(Map<String, dynamic> json) {
    // Función auxiliar para extraer strings de forma segura (evita el error de Map)
    String _safeString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString(); // Convierte Maps o números a texto sin crashear
    }

    // Función auxiliar para extraer enteros de forma segura
    int _safeInt(dynamic value, int defaultValue) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return ReporteEstadoModel(
      reporteId: _safeInt(json['reporteId'], 0),
      faseActual: FaseReporte.fromId(_safeInt(json['faseActual'], 1)),
      
      // Usamos _safeInt para asegurar que fromId reciba un número
      nivelUrgencia: TipoUrgencia.fromId(_safeInt(json['nivelUrgencia'], 1)),
      tipoReporte: TipoReporte.fromId(_safeInt(json['tipoReporte'], 1)),
      tipoAnimal: TipoAnimal.fromId(_safeInt(json['tipoAnimal'], 1)),
      
      descripcion: _safeString(json['descripcion']),
      ubicacion: _safeString(json['ubicacion']),
      raza: _safeString(json['raza']),
      tamano: _safeString(json['tamano']),
      evidenciaUrl: _safeString(json['evidenciaUrl']),
      
      historialFases: json['historialFases'] is List 
          ? (json['historialFases'] as List).map((e) => _safeString(e)).toList()
          : [],
          
      comentarios: json['comentarios'] == null ? null : _safeString(json['comentarios']),
    );
  }
}