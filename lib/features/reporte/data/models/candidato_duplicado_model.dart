import '../../domain/entities/candidato_duplicado.dart';

class CandidatoDuplicadoModel extends CandidatoDuplicado {
  CandidatoDuplicadoModel({
    required super.reporteId,
    super.scoreTexto,
    super.scoreImagen,
    required super.distanciaKm,
    super.descripcion,
    super.evidenciaUrl,
    super.tipoAnimal,
    super.tamano,
  });

  factory CandidatoDuplicadoModel.fromJson(Map<String, dynamic> json) {
    final detalle = json['detalle'] as Map<String, dynamic>?;

    return CandidatoDuplicadoModel(
      reporteId: json['reporte_id'],
      scoreTexto: (json['score_texto'] as num?)?.toDouble(),
      scoreImagen: (json['score_imagen'] as num?)?.toDouble(),
      distanciaKm: (json['distancia_km'] as num).toDouble(),
      descripcion: detalle?['descripcion'],
      evidenciaUrl: detalle?['evidencia'],
      tipoAnimal: detalle?['tipo_animal'],
      tamano: detalle?['tamano'],
    );
  }
}
