class Adopcion {
  final int id;
  final int? usuarioId;
  final String nombre;
  final String especie;
  final String edad;
  final String tamano;
  final String ciudad;
  final String sexo;
  final String vacunas;
  final String descripcion;
  final String nombreUsuario;
  final DateTime fecha;
  final String? imagenUrl;
  final String? imagenPath;
  final List<String> preguntas;
  /// Una publicación puede representar una camada o más de una mascota.
  /// En ese caso el responsable puede aceptar a más de un postulante.
  final bool sonVariasMascotas;

  Adopcion({
    required this.id,
    this.usuarioId,
    required this.nombre,
    required this.especie,
    required this.edad,
    required this.tamano,
    required this.ciudad,
    required this.sexo,
    required this.vacunas,
    required this.descripcion,
    this.nombreUsuario = 'Usuario',
    DateTime? fecha,
    this.imagenUrl,
    this.imagenPath,
    this.preguntas = const [],
    this.sonVariasMascotas = false,
  }) : fecha = fecha ?? DateTime.now();
}
