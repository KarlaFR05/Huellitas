enum TipoMultimedia { imagen, video }

class MultimediaPublicacion {
  final int id;
  final int publicacionId;
  final TipoMultimedia tipo;
  final String url;
  final int orden;
  final DateTime fechaCreacion;

  const MultimediaPublicacion({
    required this.id,
    required this.publicacionId,
    required this.tipo,
    required this.url,
    this.orden = 0,
    required this.fechaCreacion,
  });
}
