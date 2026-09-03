class PreguntaAdopcion {
  static const textoMedioContacto =
      '¿Cuál es tu medio de contacto para comunicarnos contigo si eres seleccionado?';

  final int? id;
  final String texto;
  final String? criterioEsperado;

  const PreguntaAdopcion({this.id, required this.texto, this.criterioEsperado});

  bool get esMedioContacto {
    final normalizado = texto.trim().toLowerCase();
    return normalizado == textoMedioContacto.toLowerCase() ||
        normalizado.contains('medio de contacto');
  }

  static const medioContacto = PreguntaAdopcion(
    texto: textoMedioContacto,
    criterioEsperado:
        'Dato informativo; no debe influir en el nivel de aptitud',
  );

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
