import '../entities/categoria_organizacion.dart';
class Organizacion {
  final int id;
  final String nombre;
  final String descripcion;
  final String logoUrl;
  final CategoriaOrganizacion categoria;
  final String cuentaBancaria;

  const Organizacion({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.logoUrl,
    required this.categoria,
    required this.cuentaBancaria,
  });
}