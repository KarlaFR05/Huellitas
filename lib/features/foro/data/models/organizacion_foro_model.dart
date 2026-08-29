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

  factory OrganizacionForoModel.fromJson(Map<String, dynamic> json) {
    return OrganizacionForoModel(
      id: json['id'] ?? 0,
      usuarioId: json['usuario_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      fotoPortada: json['foto_portada'] ?? '',
      verificada: json['verificada'] ?? true,
      cantidadSeguidores: json['cantidad_seguidores'] ?? 0,
      esSeguidor: json['es_seguidor'] ?? false,
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