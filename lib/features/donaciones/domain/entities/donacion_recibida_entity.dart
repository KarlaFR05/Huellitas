class DonacionRecibidaEntity {
  final int id;
  final String nombreDonante;
  final DateTime fechaDonacion;
  final double monto;
  final String estado;

  DonacionRecibidaEntity({
    required this.id,
    required this.nombreDonante,
    required this.fechaDonacion,
    required this.monto,
    required this.estado,
  });
}