class Reporte {
  final int tipoAnimalId;
  final int tipoReporteId;
  final int urgenciaId;
  final String tamano;
  final String descripcion;
  final String ubicacion;
  final int usuarioId;
  final String raza;

  Reporte({
    required this.tipoAnimalId,
    required this.tipoReporteId,
    required this.urgenciaId,
    required this.tamano,
    required this.descripcion,
    required this.ubicacion,
    required this.usuarioId,
    required this.raza,
  });
}
