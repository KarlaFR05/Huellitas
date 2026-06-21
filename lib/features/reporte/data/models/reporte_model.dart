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

  factory ReporteModel.fromJson(Map<String, dynamic> json) {
    return ReporteModel(
      tipoAnimalId: _readAnimalId(json, ['tipo_animal', 'tipo_animal_id', 'tipoAnimalId']),
      tipoReporteId: _readInt(json, ['tipo_reporte', 'tipo_reporte_id', 'tipoReporteId']),
      urgenciaId: _readUrgencyId(json, ['urgencia_id', 'nivel_urgencia', 'urgenciaId']),
      tamano: _readString(json, ['tamano', 'tamaño']),
      descripcion: _readString(json, ['descripcion', 'descripcion_reporte']),
      ubicacion: _readString(json, ['ubicacion', 'direccion']),
      usuarioId: _readInt(json, ['usuario_id_fk', 'usuario_id', 'usuarioId']),
      raza: _readString(json, ['raza_id', 'raza']),
      latitud: _readDouble(json, ['latitud', 'latitude', 'lat']),
      longitud: _readDouble(json, ['longitud', 'longitude', 'lng', 'lon']),
      evidencia: _readString(json, ['evidencia', 'foto', 'foto_url', 'imageUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo_animal': tipoAnimalId,
      'raza_id': raza,
      'tipo_reporte': tipoReporteId,
      'urgencia_id': urgenciaId,
      'tamano': tamano,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'evidencia': evidencia ?? '',
      'usuario_id_fk': usuarioId,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
    };
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is Map<String, dynamic>) {
        final id = value['id'];
        if (id is int) return id;
        if (id is num) return id.toInt();
        if (id is String) return int.tryParse(id) ?? 0;
      }
    }
    return 0;
  }

  static int _readAnimalId(Map<String, dynamic> json, List<String> keys) {
    final value = _readRawValue(json, keys);
    final id = _toInt(value);
    if (id != 0) return id;

    final text = value.toString().toLowerCase();
    if (text.contains('perro')) return 1;
    if (text.contains('gato')) return 2;
    return 0;
  }

  static int _readUrgencyId(Map<String, dynamic> json, List<String> keys) {
    final value = _readRawValue(json, keys);
    final id = _toInt(value);
    if (id != 0) return id;

    final text = value.toString().toLowerCase();
    if (text.contains('baja')) return 1;
    if (text.contains('media')) return 2;
    if (text.contains('alta')) return 3;
    if (text.contains('critica') || text.contains('crítica')) return 4;
    return 0;
  }

  static dynamic _readRawValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) return value;
    }
    return null;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is Map<String, dynamic>) return _toInt(value['id']);
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
        return (value['nombre'] ?? value['name'] ?? value['label'] ?? '').toString();
      }
      return value.toString();
    }
    return '';
  }
}
