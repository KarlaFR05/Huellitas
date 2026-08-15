class Notificacion {
  final int id;
  final String tipo; // reporte_tomado, reporte_cercano, donacion, reporte_exitoso, reaccion, comentario, nuevo_miembro, aprobar_miembro
  final String titulo;
  final String mensaje;
  final Map<String, dynamic>? data;
  final bool leida;
  final DateTime creadaEn;

  const Notificacion({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    this.data,
    required this.leida,
    required this.creadaEn,
  });
}