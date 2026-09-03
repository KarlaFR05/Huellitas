import '../../domain/entities/organizacion_foro.dart';

class OrganizacionForoModel extends OrganizacionForo {
  OrganizacionForoModel({
    required super.id,
    required super.usuarioId,
    required super.nombre,
    super.descripcion,
    super.logoUrl,
    super.fotoPortada,
    super.verificada,
    super.cantidadSeguidores,
    super.esSeguidor,
    super.tiposAnimales,
    super.telefonoEmergencia,
    super.correoInstitucional,
    super.registroLegal,
    super.fechaFundacion,
    super.metaMensual,
    super.recaudadoMensual,
  });

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalizado = value.toLowerCase();
      return normalizado == 'true' || normalizado == '1';
    }
    return false;
  }

  static int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  factory OrganizacionForoModel.fromJson(Map<String, dynamic> json) {
    return OrganizacionForoModel(
      id: json['id'] ?? 0,
      usuarioId: json['usuario_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      fotoPortada: json['foto_portada'] ?? '',
      verificada: json['verificada'] ?? true,
      cantidadSeguidores: _parseInt(
        json['cantidad_seguidores'] ?? json['cantidadSeguidores'],
      ),
      esSeguidor: _parseBool(json['es_seguidor'] ?? json['esSeguidor']),
      tiposAnimales: json['tipos_animales'],
      telefonoEmergencia: json['telefono_emergencia'],
      correoInstitucional: json['correo_institucional'],
      registroLegal: json['registro_legal'],
      fechaFundacion: json['fecha_fundacion'] != null
          ? DateTime.tryParse(json['fecha_fundacion'].toString())
          : null,
      metaMensual: (json['meta_mensual'] as num?)?.toDouble() ?? 0.0,
      recaudadoMensual: (json['recaudado_mensual'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
