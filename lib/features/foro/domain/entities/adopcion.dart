import 'pregunta_adopcion.dart';

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
  final String estado;
  final int? adoptanteId;
  final String? contactoResponsable;
  final String? contactoAdoptante;
  final String nombreUsuario;
  final DateTime fecha;
  final String? imagenUrl;
  final String? imagenPath;
  final List<PreguntaAdopcion> preguntas;

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
    this.estado = 'activa',
    this.adoptanteId,
    this.contactoResponsable,
    this.contactoAdoptante,
    this.nombreUsuario = 'Usuario',
    DateTime? fecha,
    this.imagenUrl,
    this.imagenPath,
    this.preguntas = const [],
  }) : fecha = fecha ?? DateTime.now();

  bool get estaCompletada {
    final valor = estado.trim().toLowerCase();
    return const {
      'completada',
      'completado',
      'cerrada',
      'cerrado',
      'adoptada',
      'adoptado',
      'finalizada',
      'finalizado',
    }.contains(valor);
  }

  bool esVisiblePara(int usuarioId) {
    return !estaCompletada ||
        this.usuarioId == usuarioId ||
        adoptanteId == usuarioId;
  }
}
