class CrearAdopcionSolicitud {
  final String nombre;
  final String especie;
  final String edad;
  final String tamano;
  final String ciudad;
  final String sexo;
  final String vacunas;
  final String descripcion;
  final String? imagenLocalPath;
  final List<String> preguntas;

  const CrearAdopcionSolicitud({
    required this.nombre,
    required this.especie,
    required this.edad,
    required this.tamano,
    required this.ciudad,
    required this.sexo,
    required this.vacunas,
    required this.descripcion,
    this.imagenLocalPath,
    this.preguntas = const [],
  });
}