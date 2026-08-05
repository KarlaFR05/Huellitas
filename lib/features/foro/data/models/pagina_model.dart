class PaginaModel<T> {
  final List<T> elementos;
  final String? siguienteCursor;
  final bool hayMas;

  PaginaModel({
    required this.elementos,
    this.siguienteCursor,
    required this.hayMas,
  });

  factory PaginaModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginaModel(
      elementos: (json['elementos'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      siguienteCursor: json['siguiente_cursor'] as String?,
      hayMas: json['hay_mas'] as bool,
    );
  }
}
