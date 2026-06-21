import '../../domain/entities/reporte.dart';

class ReporteModel extends Reporte {
  ReporteModel({
    required super.tipoAnimalId,
    required super.tipoReporteId,
    required super.urgenciaId,
    required super.tamano,
    required super.descripcion,
    required super.ubicacion,
    required super.usuarioId,
    required super.raza,
    super.latitud,
    super.longitud,
    super.evidencia,
  });

  factory ReporteModel.fromEntity(Reporte reporte) {
    return ReporteModel(
      tipoAnimalId: reporte.tipoAnimalId,
      tipoReporteId: reporte.tipoReporteId,
      urgenciaId: reporte.urgenciaId,
      tamano: reporte.tamano,
      descripcion: reporte.descripcion,
      ubicacion: reporte.ubicacion,
      usuarioId: reporte.usuarioId,
      raza: reporte.raza,
      latitud: reporte.latitud,
      longitud: reporte.longitud,
      evidencia: reporte.evidencia,
    );
  }

  // =========================
  // 🔥 FROM JSON (SAFE READ)
  // =========================
  factory ReporteModel.fromJson(Map<String, dynamic> json) {
    return ReporteModel(
      tipoAnimalId: _readInt(json, ['tipo_animal']),
      tipoReporteId: _readInt(json, ['tipo_reporte']),
      urgenciaId: _readInt(json, ['urgencia_id']),
      tamano: _readString(json, ['tamano']),
      descripcion: _readString(json, ['descripcion']),
      ubicacion: _readString(json, ['ubicacion']),
      usuarioId: _readInt(json, ['usuario_id_fk']),
      raza: _readString(json, ['raza_id']),
      latitud: _readDouble(json, ['latitud']),
      longitud: _readDouble(json, ['longitud']),
      evidencia: _readString(json, ['evidencia']),
    );
  }

  // =========================
  // 🔥 TO JSON (FIX REAL)
  // =========================
  Map<String, dynamic> toJson() {
    return {
      "tipo_animal": tipoAnimalId,
      "tipo_reporte": tipoReporteId,
      "urgencia_id": urgenciaId,
      "raza_id": raza,
      "tamano": tamano,
      "descripcion": descripcion,
      "ubicacion": ubicacion,
      "usuario_id_fk": usuarioId,
      "evidencia": (evidencia != null && evidencia!.isNotEmpty)
          ? evidencia
          : null,
      "latitud": latitud,
      "longitud": longitud,
    }..removeWhere((key, value) => value == null);
  }

  // =========================
  // 🔥 SAFE PARSERS
  // =========================
  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  static double? _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
    }
    return null;
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value == null) continue;

      if (value is Map<String, dynamic>) {
        return (value['nombre'] ?? value['name'] ?? '').toString();
      }

      return value.toString();
    }
    return '';
  }
}