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
    final monto = json['monto'];
    return DonacionRecibidaModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombreDonante: json['nombre_donante']?.toString() ?? 'Donante anónimo',
      fechaDonacion:
          DateTime.tryParse(json['fecha_donacion']?.toString() ?? '') ??
          DateTime.now(),
      monto: monto is num
          ? monto.toDouble()
          : double.tryParse(monto?.toString() ?? '') ?? 0,
      estado: json['estado']?.toString() ?? 'completada',
    );
  }
}
