import 'donacion_recibida_entity.dart';

class EstadisticasOrganizacionEntity {
  final double metaMensual;
  final double recaudadoMensual;
  final List<DonacionRecibidaEntity> donacionesRecientes;

  EstadisticasOrganizacionEntity({
    required this.metaMensual,
    required this.recaudadoMensual,
    required this.donacionesRecientes,
  });
}