import '../../domain/entities/catalog.dart';

class CatalogModel extends Catalog {
  CatalogModel({required super.id, required super.nombre});

  factory CatalogModel.fromJson(Map<String, dynamic> json) {
    return CatalogModel(id: json['id'], nombre: json['nombre']);
  }
}
