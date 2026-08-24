class PostulacionAdopcion {
  const PostulacionAdopcion({
    required this.nombre,
    required this.respuestas,
    this.porcentajeAptitud = 0,
    this.estado = 'En evaluación',
    this.entrevistaCompletada = false,
    this.usuarioId,
    this.fechaRegistro,
    this.ubicacion,
    this.insigniasRescate = 0,
    this.insigniasReporte = 0,
    this.insigniasDonacion = 0,
    this.fotoPerfil,
  });

  final String nombre;
  final Map<String, String> respuestas;

  /// Porcentaje de aptitud para adoptar.
  final int porcentajeAptitud;

  /// Ejemplo:
  /// "Muy apta"
  /// "Apta"
  /// "En evaluación"
  final String estado;

  /// Indica si ya completó la entrevista.
  final bool entrevistaCompletada;
  final int? usuarioId;
  final DateTime? fechaRegistro;
  final String? ubicacion;
  final int insigniasRescate;
  final int insigniasReporte;
  final int insigniasDonacion;
  final String? fotoPerfil;
}

/// Almacenamiento temporal mientras se habilita el endpoint de postulaciones.
class PostulacionesAdopcionStore {
  static final Map<int, List<PostulacionAdopcion>> _datos = {};

  static List<PostulacionAdopcion> deAdopcion(int id) =>
      List.unmodifiable(_datos[id] ?? const []);

  static void agregar(
    int id,
    PostulacionAdopcion postulacion,
  ) =>
      _datos.putIfAbsent(id, () => []).add(postulacion);

  static bool tienePostulacion(
    int id,
    String nombre,
  ) =>
      (_datos[id] ?? const []).any(
        (postulacion) => postulacion.nombre == nombre,
      );
}
