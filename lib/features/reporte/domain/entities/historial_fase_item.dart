class HistorialFaseItem {
  final String faseNombre;
  final DateTime fechaCambio;
  final String? evidenciaUrl;
  final String? comentarios;
  final String? usuarioNombre;

  const HistorialFaseItem({
    required this.faseNombre,
    required this.fechaCambio,
    this.evidenciaUrl,
    this.comentarios,
    this.usuarioNombre,
  });

  factory HistorialFaseItem.fromJson(Map<String, dynamic> json) {
    return HistorialFaseItem(
      faseNombre: json['fase_nombre'] ?? '',
      fechaCambio: DateTime.parse('${json['fecha_cambio']}Z'),
      evidenciaUrl: json['evidencia_url'],
      comentarios: json['comentarios'],
      usuarioNombre: json['usuario_nombre'],
    );
  }
}
