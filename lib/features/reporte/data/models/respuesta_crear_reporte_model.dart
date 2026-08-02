import '../../domain/entities/respuesta_crear_reporte.dart';
import 'candidato_duplicado_model.dart';
import 'reporte_model.dart';

class RespuestaCrearReporteModel extends RespuestaCrearReporte {
  RespuestaCrearReporteModel({
    required super.posibleDuplicado,
    super.candidatos,
    super.reporte,
  });

  factory RespuestaCrearReporteModel.fromJson(Map<String, dynamic> json) {
    final candidatosJson = json['candidatos'] as List<dynamic>?;
    final reporteJson = json['reporte'] as Map<String, dynamic>?;

    return RespuestaCrearReporteModel(
      posibleDuplicado: json['posible_duplicado'] ?? false,
      candidatos: candidatosJson
          ?.map((c) => CandidatoDuplicadoModel.fromJson(c))
          .toList(),
      reporte: reporteJson != null ? ReporteModel.fromJson(reporteJson) : null,
    );
  }
}
