class CrearAdopcionSolicitud {
  const CrearAdopcionSolicitud({
    required this.nombre,
    required this.especie,
    required this.edad,
    required this.tamano,
    required this.ciudad,
    required this.sexo,
    required this.vacunas,
    required this.descripcion,
    required this.preguntas,
    this.imagenLocalPath,
    this.imagenExistenteUrl,
    this.id,
    this.usuarioId,
    this.nombreUsuario,
  });

  final int? id;
  final int? usuarioId;
  final String? nombreUsuario;

  final String nombre;
  final String especie;
  final String edad;
  final String tamano;
  final String ciudad;
  final String sexo;
  final String vacunas;
  final String descripcion;

  final String? imagenLocalPath;
  final String? imagenExistenteUrl;

  final List<String> preguntas;
}
