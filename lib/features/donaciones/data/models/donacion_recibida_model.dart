import '../../domain/entities/donacion_recibida_entity.dart';

class DonacionRecibidaModel extends DonacionRecibidaEntity {
  DonacionRecibidaModel({
    required super.id,
    required super.nombreDonante,
    required super.fechaDonacion,
    required super.monto,
    required super.estado,
  });

  factory DonacionRecibidaModel.fromJson(Map<String, dynamic> json) {
    return DonacionRecibidaModel(
      id: json['id'] ?? 0,
      nombreDonante: json['nombre_donante'] ?? 'Donante Anónimo',
      fechaDonacion: DateTime.parse(json['fecha_donacion']),
      monto: (json['monto'] as num).toDouble(),
      estado: json['estado'] ?? 'completada',
    );
  }
}