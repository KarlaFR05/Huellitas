class Reporte {
  final int tipoAnimalId;
  final int tipoReporteId;
  final int urgenciaId;
  final String tamano;
  final String descripcion;
  final String ubicacion;
  final int usuarioId;
  final String raza;
  final double? latitud;
  final double? longitud;
  final String? evidencia;

  Reporte({
    required this.tipoAnimalId,
    required this.tipoReporteId,
    required this.urgenciaId,
    required this.tamano,
    required this.descripcion,
    required this.ubicacion,
    required this.usuarioId,
    required this.raza,
    this.latitud,
    this.longitud,
    this.evidencia,
  });
}
