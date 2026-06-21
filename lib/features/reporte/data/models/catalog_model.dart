import '../../domain/entities/catalog.dart';

class CatalogModel extends Catalog {
  CatalogModel({required super.id, required super.nombre});

  factory CatalogModel.fromJson(Map<String, dynamic> json) {
    return CatalogModel(
      id:
          json['id'] ??
          json['tipo_animal'] ??
          json['tipo_reporte'] ??
          json['urgencia_id'],
      nombre: json['nombre'] ?? json['clasificacion'] ?? json['estado'],
    );
  }
}