import '../../domain/entities/estadisticas_organizacion_entity.dart';
import 'donacion_recibida_model.dart';

class EstadisticasOrganizacionModel extends EstadisticasOrganizacionEntity {
  EstadisticasOrganizacionModel({
    required super.metaMensual,
    required super.recaudadoMensual,
    required super.donacionesRecientes,
  });

  factory EstadisticasOrganizacionModel.fromJson(Map<String, dynamic> json) {
    final donacionesJson = json['donaciones_recientes'] as List? ?? [];
    final donaciones = donacionesJson
        .map((j) => DonacionRecibidaModel.fromJson(j as Map<String, dynamic>))
        .toList();

    return EstadisticasOrganizacionModel(
      metaMensual: (json['meta_mensual'] as num?)?.toDouble() ?? 0.0,
      recaudadoMensual: (json['recaudado_mensual'] as num?)?.toDouble() ?? 0.0,
      donacionesRecientes: donaciones,
    );
  }
}