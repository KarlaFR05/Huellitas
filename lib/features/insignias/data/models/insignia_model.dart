import '../../domain/entities/insignia.dart';
import '../../domain/entities/categoria_insignia.dart';

class InsigniaModel extends Insignia {
  const InsigniaModel({
    required super.id,
    required super.nombre,
    required super.nivel,
    required super.categoria,
    required super.descripcion,
    super.imagenUrl,
    required super.obtenida,
    super.fechaObtencion,
  });

  factory InsigniaModel.fromJson(Map<String, dynamic> json) {
    return InsigniaModel(
      id: json['id'] ?? json['id_insignias'] ?? 0,
      nombre: json['nombre'] ?? '',
      nivel: json['nivel'] ?? 1,
      categoria: _parseCategoria(json['categoria']),
      descripcion: json['descripcion'] ?? '',
      imagenUrl: json['imagen_url'] ?? json['imagen'],
      obtenida: json['obtenida'] ?? false,
      fechaObtencion: json['fecha_obtencion'] != null
          ? DateTime.parse(json['fecha_obtencion'])
          : null,
    );
  }

  static CategoriaInsignia _parseCategoria(String? categoria) {
    switch (categoria?.toLowerCase()) {
      case 'rescate':
        return CategoriaInsignia.rescate;
      case 'donacion':
        return CategoriaInsignia.donacion;
      case 'reporte':
        return CategoriaInsignia.reporte;
      default:
        return CategoriaInsignia.reporte;
    }
  }
}