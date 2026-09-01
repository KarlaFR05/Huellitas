/*import '../../domain/entities/organizacion_perfil_entity.dart';

class OrganizacionPerfilModel extends OrganizacionPerfilEntity {
  OrganizacionPerfilModel({
    required super.id,
    required super.nombre,
    super.descripcion,
    super.categoria,
    super.cuentaBancaria,
    super.banco,
    super.titular,
    super.logoUrl,
  });

  factory OrganizacionPerfilModel.fromJson(Map<String, dynamic> json) {
    return OrganizacionPerfilModel(
      id: json['id'] ?? json['organizacion_id_pk'] ?? 0, // Ajusta según tu PK en Supabase
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      cuentaBancaria: json['cuenta_bancaria'],
      banco: json['banco'],
      titular: json['titular'],
      logoUrl: json['logo_url'],
    );
  }
}*/

import '../../domain/entities/organizacion_perfil_entity.dart';

class OrganizacionPerfilModel extends OrganizacionPerfilEntity {
  OrganizacionPerfilModel({
    required super.id,
    required super.usuarioId,
    required super.nombre,
    super.descripcion,
    super.registroLegal,
    super.categoria,
    super.tiposAnimales,
    super.telefonoEmergencia,
    super.correoInstitucional,
    super.fechaFundacion,
    super.logoUrl,
    super.fotoPortada,
    super.cuentaBancaria,
    super.banco,
    super.titular,
    super.verificada,
    super.cantidadSeguidores,
    super.metaMensual,
    super.recaudadoMensual,
  });

  factory OrganizacionPerfilModel.fromJson(Map<String, dynamic> json) {
    return OrganizacionPerfilModel(
      id: json['id'] ?? 0,
      usuarioId: json['usuario_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      registroLegal: json['registro_legal'],
      categoria: json['categoria'],
      tiposAnimales: json['tipos_animales'],
      telefonoEmergencia: json['telefono_emergencia'],
      correoInstitucional: json['correo_institucional'],
      fechaFundacion: json['fecha_fundacion'],
      logoUrl: json['logo_url'],
      fotoPortada: json['foto_portada'],
      cuentaBancaria: json['cuenta_bancaria'],
      banco: json['banco'],
      titular: json['titular'],
      verificada: json['verificada'] ?? true,
      cantidadSeguidores: json['cantidad_seguidores'] ?? 0,
      metaMensual: (json['meta_mensual'] as num?)?.toDouble() ?? 0.0,
      recaudadoMensual: (json['recaudado_mensual'] as num?)?.toDouble() ?? 0.0,
    );
  }
}