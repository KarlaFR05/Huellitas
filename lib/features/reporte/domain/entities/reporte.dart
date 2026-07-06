class Reporte {
  final int? id;
  final int tipoAnimalId;
  final int tipoReporteId;
  final int urgenciaId;
  final String tamano;
  final String descripcion;
  final String ubicacion;
  final int usuarioId;
  final String raza;
  final String evidencia;
  final double latitud;
  final double longitud;

  Reporte({
    this.id,
    required this.tipoAnimalId,
    required this.tipoReporteId,
    required this.urgenciaId,
    required this.tamano,
    required this.descripcion,
    required this.ubicacion,
    required this.usuarioId,
    required this.raza,
    required this.evidencia,
    required this.latitud,
    required this.longitud,
  });
}