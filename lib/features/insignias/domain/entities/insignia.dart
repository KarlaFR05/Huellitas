import 'categoria_insignia.dart';

class Insignia {
  final int id;
  final String nombre;
  final int nivel;
  final CategoriaInsignia categoria;
  final String descripcion;
  final String? imagenUrl;
  final bool obtenida;
  final DateTime? fechaObtencion;

  const Insignia({
    required this.id,
    required this.nombre,
    required this.nivel,
    required this.categoria,
    required this.descripcion,
    this.imagenUrl,
    required this.obtenida,
    this.fechaObtencion,
  });
}