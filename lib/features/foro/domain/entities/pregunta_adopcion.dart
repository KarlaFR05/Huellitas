class PreguntaAdopcion {
  final int? id;
  final String texto;
  final String? criterioEsperado;

  const PreguntaAdopcion({this.id, required this.texto, this.criterioEsperado});

  factory PreguntaAdopcion.fromJson(Map<String, dynamic> json) {
    return PreguntaAdopcion(
      id: json['pregunta_id'] as int?,
      texto: json['texto'] as String,
      criterioEsperado: json['criterio_esperado'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'texto': texto,
    'criterio_esperado': criterioEsperado,
  };
}
