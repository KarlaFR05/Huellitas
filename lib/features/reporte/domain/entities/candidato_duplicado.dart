class CandidatoDuplicado {
  final int reporteId;
  final double? scoreTexto;
  final double? scoreImagen;
  final double distanciaKm;

  // Campos que vienen dentro de "detalle" en la respuesta del backend
  final String? descripcion;
  final String? evidenciaUrl;
  final int? tipoAnimal;
  final String? tamano;

  CandidatoDuplicado({
    required this.reporteId,
    this.scoreTexto,
    this.scoreImagen,
    required this.distanciaKm,
    this.descripcion,
    this.evidenciaUrl,
    this.tipoAnimal,
    this.tamano,
  });
}
